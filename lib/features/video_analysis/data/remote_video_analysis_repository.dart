import 'dart:io';
import 'dart:typed_data';

import 'package:captain/core/network/result.dart';
import 'package:captain/core/network/video_analysis_failure.dart';
import 'package:captain/features/video_analysis/data/video_analysis_error_mapper.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/calibration_point.dart';
import 'package:captain/features/video_analysis/domain/video_analysis_repository.dart';
import 'package:captain/features/video_analysis/domain/video_status_response.dart';
import 'package:captain/features/video_analysis/domain/video_upload_response.dart';
import 'package:dio/dio.dart';

class RemoteVideoAnalysisRepository implements VideoAnalysisRepository {
  RemoteVideoAnalysisRepository(this._dio);

  final Dio _dio;

  static const _videosBase = '/api/v1/videos';

  @override
  Future<Result<VideoUploadResponse>> uploadVideo(
    String filePath, {
    UploadProgressCallback? onSendProgress,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const Failure(
          UnknownVideoAnalysisError('Selected video file was not found.'),
        );
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '$_videosBase/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
      );

      return Success(_parseUploadResponse(response.data));
    } on DioException catch (error) {
      return failureFromDio(error);
    } catch (error) {
      return Failure(UnknownVideoAnalysisError(error.toString()));
    }
  }

  @override
  Future<Result<VideoUploadResponse>> submitYoutubeUrl(String url) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_videosBase/from-youtube',
        data: {'url': url},
      );
      return Success(_parseUploadResponse(response.data));
    } on DioException catch (error) {
      return failureFromDio(error);
    } catch (error) {
      return Failure(UnknownVideoAnalysisError(error.toString()));
    }
  }

  @override
  Future<Result<VideoStatusResponse>> getVideoStatus(String videoId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_videosBase/$videoId/status',
      );
      return Success(VideoStatusResponse.fromJson(response.data!));
    } on DioException catch (error) {
      return failureFromDio(error);
    } catch (error) {
      return Failure(UnknownVideoAnalysisError(error.toString()));
    }
  }

  @override
  Future<Result<Uint8List>> getFirstFrame(String videoId) async {
    try {
      final response = await _dio.get<List<int>>(
        '$_videosBase/$videoId/first-frame',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        return const Failure(
          UnknownVideoAnalysisError('First frame response was empty.'),
        );
      }
      return Success(Uint8List.fromList(bytes));
    } on DioException catch (error) {
      return failureFromDio(error);
    } catch (error) {
      return Failure(UnknownVideoAnalysisError(error.toString()));
    }
  }

  @override
  Future<Result<void>> submitCalibration(
    String videoId,
    List<CalibrationPoint> points,
  ) async {
    try {
      await _dio.post<void>(
        '$_videosBase/$videoId/calibrate',
        data: {
          'points': points
              .map(
                (point) => {
                  'pixel': point.pixel,
                  'pitch': point.pitch,
                },
              )
              .toList(),
        },
      );
      return const Success(null);
    } on DioException catch (error) {
      return failureFromDio(error);
    } catch (error) {
      return Failure(UnknownVideoAnalysisError(error.toString()));
    }
  }

  @override
  Future<Result<void>> startProcessing(String videoId) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '$_videosBase/$videoId/process',
      );
      return const Success(null);
    } on DioException catch (error) {
      return failureFromDio(error);
    } catch (error) {
      return Failure(UnknownVideoAnalysisError(error.toString()));
    }
  }

  @override
  Future<Result<AnalysisResult>> getResult(
    String videoId, {
    String resolution = 'medium',
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_videosBase/$videoId/result',
        queryParameters: {'resolution': resolution},
      );
      return Success(AnalysisResult.fromJson(response.data!));
    } on DioException catch (error) {
      return failureFromDio(error);
    } catch (error) {
      return Failure(UnknownVideoAnalysisError(error.toString()));
    }
  }

  @override
  Future<Result<bool>> checkBackendHealth() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/health');
      return Success(response.data?['status'] == 'ok');
    } on DioException catch (error) {
      return failureFromDio(error);
    } catch (error) {
      return Failure(UnknownVideoAnalysisError(error.toString()));
    }
  }

  @override
  Future<Result<void>> deleteVideo(String videoId) async {
    try {
      await _dio.delete<void>('$_videosBase/$videoId');
      return const Success(null);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const Success(null);
      }
      return failureFromDio(error);
    } catch (error) {
      return Failure(UnknownVideoAnalysisError(error.toString()));
    }
  }

  @override
  Future<Result<bool>> checkAnalysisQuota() async {
    return const Success(true);
  }

  VideoUploadResponse _parseUploadResponse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const FormatException('Upload response body was empty.');
    }
    return VideoUploadResponse.fromJson(data);
  }
}
