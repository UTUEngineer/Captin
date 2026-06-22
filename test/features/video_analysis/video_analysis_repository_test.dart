import 'dart:convert';

import 'package:captain/core/network/api_client.dart';
import 'package:captain/core/network/video_analysis_failure.dart';
import 'package:captain/features/video_analysis/data/remote_video_analysis_repository.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/analysis_result_mapper.dart';
import 'package:captain/features/video_analysis/domain/calibration_point.dart';
import 'package:captain/features/video_analysis/domain/video_processing_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('RemoteVideoAnalysisRepository', () {
    late Dio dio;
    late DioAdapter adapter;
    late RemoteVideoAnalysisRepository repository;

    setUp(() {
      dio = createApiClient(baseUrl: 'http://localhost:8000');
      adapter = DioAdapter(dio: dio);
      repository = RemoteVideoAnalysisRepository(dio);
    });

    test('submitYoutubeUrl parses upload response', () async {
      adapter.onPost(
        '/api/v1/videos/from-youtube',
        (server) => server.reply(
          200,
          {
            'video_id': 'abc-123',
            'status': 'uploaded',
            'duration_seconds': 42.5,
          },
        ),
        data: {'url': 'https://youtube.com/watch?v=test'},
      );

      final result = await repository.submitYoutubeUrl(
        'https://youtube.com/watch?v=test',
      );

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.videoId, 'abc-123');
      expect(result.valueOrNull?.durationSeconds, 42.5);
    });

    test('getVideoStatus maps processing status', () async {
      adapter.onGet(
        '/api/v1/videos/abc-123/status',
        (server) => server.reply(
          200,
          {
            'video_id': 'abc-123',
            'status': 'needs_calibration',
            'progress_percent': 70,
            'message': 'Calibration required',
          },
        ),
      );

      final result = await repository.getVideoStatus('abc-123');

      expect(result.isSuccess, isTrue);
      expect(
        result.valueOrNull?.processingStatus,
        VideoProcessingStatus.needsCalibration,
      );
      expect(result.valueOrNull?.progressPercent, 70);
    });

    test('getResult parses tracks into Player-compatible coordinates', () async {
      adapter.onGet(
        '/api/v1/videos/abc-123/result',
        (server) => server.reply(
          200,
          {
            'video_id': 'abc-123',
            'duration_seconds': 10,
            'tracks': [
              {
                'track_id': 7,
                'positions': [
                  {'x': 0.2, 'y': 0.3, 'timestamp_seconds': 0.0, 'frame': 0},
                  {'x': 0.4, 'y': 0.5, 'timestamp_seconds': 2.0, 'frame': 10},
                ],
              },
            ],
            'players': [
              {
                'track_id': 7,
                'distance_km': 1.2,
                'sprint_count': 2,
                'max_speed_kmh': 24.5,
                'heatmap': [
                  [0.1, 0.2],
                ],
              },
            ],
            'possession_zones': {
              'team_a': {
                'defensive': 0.3,
                'middle': 0.4,
                'attacking': 0.3,
              },
            },
          },
        ),
        queryParameters: {'resolution': 'medium'},
      );

      final result = await repository.getResult('abc-123');
      expect(result.isSuccess, isTrue);

      final analysis = result.valueOrNull!;
      expect(analysis.tracks, hasLength(1));
      expect(analysis.players.first.distanceKm, 1.2);

      final players = analysis.playersAt(1.0);
      expect(players, hasLength(1));
      expect(players.first.x, closeTo(0.3, 0.001));
      expect(players.first.y, closeTo(0.4, 0.001));
    });

    test('submitCalibration sends pixel and pitch pairs', () async {
      adapter.onPost(
        '/api/v1/videos/abc-123/calibrate',
        (server) => server.reply(200, {'status': 'calibrated'}),
        data: {
          'points': [
            {
              'pixel': [100.0, 200.0],
              'pitch': [0.0, 0.0],
            },
          ],
        },
      );

      final result = await repository.submitCalibration(
        'abc-123',
        const [
          CalibrationPoint(pixel: [100, 200], pitch: [0, 0]),
        ],
      );

      expect(result.isSuccess, isTrue);
    });

    test('checkBackendHealth returns true when status is ok', () async {
      adapter.onGet(
        '/health',
        (server) => server.reply(200, {'status': 'ok'}),
      );

      final result = await repository.checkBackendHealth();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isTrue);
    });

    test('deleteVideo calls DELETE endpoint', () async {
      adapter.onDelete(
        '/api/v1/videos/abc-123',
        (server) => server.reply(204, null),
      );

      final result = await repository.deleteVideo('abc-123');
      expect(result.isSuccess, isTrue);
    });

    test('deleteVideo treats 404 as success', () async {
      adapter.onDelete(
        '/api/v1/videos/missing',
        (server) => server.reply(404, {'detail': 'not found'}),
      );

      final result = await repository.deleteVideo('missing');
      expect(result.isSuccess, isTrue);
    });

    test('maps invalid youtube url to InvalidUrlError', () async {
      adapter.onPost(
        '/api/v1/videos/from-youtube',
        (server) => server.reply(
          400,
          {'detail': 'Invalid youtube url'},
        ),
        data: {'url': 'not-a-url'},
      );

      final result = await repository.submitYoutubeUrl('not-a-url');
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<InvalidUrlError>());
    });
  });

  group('AnalysisResult JSON', () {
    test('fromJson accepts backend field names', () {
      final json = jsonDecode('''
        {
          "video_id": "vid-1",
          "duration_seconds": 90,
          "tracks": [],
          "players": [],
          "possession_zones": {
            "team_a": {"defensive": 0.2, "middle": 0.5, "attacking": 0.3}
          }
        }
      ''') as Map<String, dynamic>;

      final result = AnalysisResult.fromJson(json);
      expect(result.videoId, 'vid-1');
      expect(result.possessionZones?.teamA?.middle, 0.5);
    });
  });
}
