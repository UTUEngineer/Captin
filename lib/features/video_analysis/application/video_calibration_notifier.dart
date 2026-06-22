import 'dart:typed_data';
import 'dart:ui';

import 'package:captain/features/video_analysis/application/video_processing_failure_messages.dart';
import 'package:captain/features/video_analysis/domain/calibration_point.dart';
import 'package:captain/features/video_analysis/domain/standard_penalty_box_calibration.dart';
import 'package:captain/features/video_analysis/domain/video_analysis_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacedCalibrationPin {
  const PlacedCalibrationPin({
    required this.index,
    required this.normalizedX,
    required this.normalizedY,
  });

  final int index;
  final double normalizedX;
  final double normalizedY;

  List<double> pixelCoordinates(int imageWidth, int imageHeight) {
    return [
      normalizedX * imageWidth,
      normalizedY * imageHeight,
    ];
  }

  Offset displayPosition(Size layoutSize) {
    return Offset(
      normalizedX * layoutSize.width,
      normalizedY * layoutSize.height,
    );
  }

  PlacedCalibrationPin movedTo({
    required Offset normalizedPosition,
  }) {
    return PlacedCalibrationPin(
      index: index,
      normalizedX: normalizedPosition.dx.clamp(0, 1),
      normalizedY: normalizedPosition.dy.clamp(0, 1),
    );
  }
}

class VideoCalibrationState {
  const VideoCalibrationState({
    this.isLoadingFrame = true,
    this.frameBytes,
    this.imageWidth = 0,
    this.imageHeight = 0,
    this.pins = const [],
    this.loadError,
    this.submitError,
    this.isSubmitting = false,
    this.submitSucceeded = false,
  });

  final bool isLoadingFrame;
  final Uint8List? frameBytes;
  final int imageWidth;
  final int imageHeight;
  final List<PlacedCalibrationPin> pins;
  final String? loadError;
  final String? submitError;
  final bool isSubmitting;
  final bool submitSucceeded;

  bool get canSubmit => pins.length == StandardPenaltyBoxCalibration.pitchCorners.length;

  String get nextStepLabel {
    if (pins.length >= StandardPenaltyBoxCalibration.instructionSteps.length) {
      return 'All four points placed. Confirm when ready.';
    }
    return StandardPenaltyBoxCalibration.instructionSteps[pins.length];
  }

  VideoCalibrationState copyWith({
    bool? isLoadingFrame,
    Uint8List? frameBytes,
    int? imageWidth,
    int? imageHeight,
    List<PlacedCalibrationPin>? pins,
    String? loadError,
    String? submitError,
    bool? isSubmitting,
    bool? submitSucceeded,
    bool clearSubmitError = false,
  }) {
    return VideoCalibrationState(
      isLoadingFrame: isLoadingFrame ?? this.isLoadingFrame,
      frameBytes: frameBytes ?? this.frameBytes,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      pins: pins ?? this.pins,
      loadError: loadError,
      submitError:
          clearSubmitError ? null : (submitError ?? this.submitError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
    );
  }
}

class VideoCalibrationNotifier extends StateNotifier<VideoCalibrationState> {
  VideoCalibrationNotifier({
    required this.videoId,
    required VideoAnalysisRepository repository,
  })  : _repository = repository,
        super(const VideoCalibrationState()) {
    loadFrame();
  }

  final String videoId;
  final VideoAnalysisRepository _repository;

  Future<void> loadFrame() async {
    state = state.copyWith(isLoadingFrame: true, loadError: null);
    final result = await _repository.getFirstFrame(videoId);
    if (result.isFailure) {
      state = state.copyWith(
        isLoadingFrame: false,
        loadError: videoProcessingFailureMessage(result.failureOrNull!),
      );
      return;
    }

    final bytes = result.valueOrNull!;
    final dimensions = await _decodeImageDimensions(bytes);
    state = state.copyWith(
      isLoadingFrame: false,
      frameBytes: bytes,
      imageWidth: dimensions.$1,
      imageHeight: dimensions.$2,
    );
  }

  Future<(int, int)> _decodeImageDimensions(Uint8List bytes) async {
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final width = image.width;
    final height = image.height;
    image.dispose();
    return (width, height);
  }

  void addPinAtNormalized(Offset normalizedPosition) {
    if (state.pins.length >= StandardPenaltyBoxCalibration.pitchCorners.length) {
      return;
    }

    final pin = PlacedCalibrationPin(
      index: state.pins.length,
      normalizedX: normalizedPosition.dx.clamp(0, 1),
      normalizedY: normalizedPosition.dy.clamp(0, 1),
    );

    state = state.copyWith(
      pins: [...state.pins, pin],
      clearSubmitError: true,
    );
  }

  void movePin(int index, Offset normalizedPosition) {
    state = state.copyWith(
      pins: [
        for (final pin in state.pins)
          if (pin.index == index)
            pin.movedTo(normalizedPosition: normalizedPosition)
          else
            pin,
      ],
      clearSubmitError: true,
    );
  }

  void resetPins() {
    state = state.copyWith(pins: [], clearSubmitError: true);
  }

  Future<void> submitCalibration() async {
    if (!state.canSubmit || state.imageWidth == 0 || state.imageHeight == 0) {
      return;
    }

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);

    final pixels = state.pins
        .map(
          (pin) => pin.pixelCoordinates(state.imageWidth, state.imageHeight),
        )
        .toList();
    final points = buildCalibrationPoints(pixels: pixels);

    final result = await _repository.submitCalibration(videoId, points);
    if (result.isFailure) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: videoProcessingFailureMessage(result.failureOrNull!),
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: false,
      submitSucceeded: true,
    );
  }
}
