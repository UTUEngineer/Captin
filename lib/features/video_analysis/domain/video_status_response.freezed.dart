// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_status_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoStatusResponse {

 String get videoId; String get status; int get progressPercent; String? get message; String? get jobId;
/// Create a copy of VideoStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoStatusResponseCopyWith<VideoStatusResponse> get copyWith => _$VideoStatusResponseCopyWithImpl<VideoStatusResponse>(this as VideoStatusResponse, _$identity);

  /// Serializes this VideoStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoStatusResponse&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.message, message) || other.message == message)&&(identical(other.jobId, jobId) || other.jobId == jobId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,status,progressPercent,message,jobId);

@override
String toString() {
  return 'VideoStatusResponse(videoId: $videoId, status: $status, progressPercent: $progressPercent, message: $message, jobId: $jobId)';
}


}

/// @nodoc
abstract mixin class $VideoStatusResponseCopyWith<$Res>  {
  factory $VideoStatusResponseCopyWith(VideoStatusResponse value, $Res Function(VideoStatusResponse) _then) = _$VideoStatusResponseCopyWithImpl;
@useResult
$Res call({
 String videoId, String status, int progressPercent, String? message, String? jobId
});




}
/// @nodoc
class _$VideoStatusResponseCopyWithImpl<$Res>
    implements $VideoStatusResponseCopyWith<$Res> {
  _$VideoStatusResponseCopyWithImpl(this._self, this._then);

  final VideoStatusResponse _self;
  final $Res Function(VideoStatusResponse) _then;

/// Create a copy of VideoStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoId = null,Object? status = null,Object? progressPercent = null,Object? message = freezed,Object? jobId = freezed,}) {
  return _then(_self.copyWith(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoStatusResponse].
extension VideoStatusResponsePatterns on VideoStatusResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoStatusResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _VideoStatusResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _VideoStatusResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String videoId,  String status,  int progressPercent,  String? message,  String? jobId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoStatusResponse() when $default != null:
return $default(_that.videoId,_that.status,_that.progressPercent,_that.message,_that.jobId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String videoId,  String status,  int progressPercent,  String? message,  String? jobId)  $default,) {final _that = this;
switch (_that) {
case _VideoStatusResponse():
return $default(_that.videoId,_that.status,_that.progressPercent,_that.message,_that.jobId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String videoId,  String status,  int progressPercent,  String? message,  String? jobId)?  $default,) {final _that = this;
switch (_that) {
case _VideoStatusResponse() when $default != null:
return $default(_that.videoId,_that.status,_that.progressPercent,_that.message,_that.jobId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _VideoStatusResponse extends VideoStatusResponse {
  const _VideoStatusResponse({required this.videoId, required this.status, this.progressPercent = 0, this.message, this.jobId}): super._();
  factory _VideoStatusResponse.fromJson(Map<String, dynamic> json) => _$VideoStatusResponseFromJson(json);

@override final  String videoId;
@override final  String status;
@override@JsonKey() final  int progressPercent;
@override final  String? message;
@override final  String? jobId;

/// Create a copy of VideoStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoStatusResponseCopyWith<_VideoStatusResponse> get copyWith => __$VideoStatusResponseCopyWithImpl<_VideoStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoStatusResponse&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.message, message) || other.message == message)&&(identical(other.jobId, jobId) || other.jobId == jobId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,status,progressPercent,message,jobId);

@override
String toString() {
  return 'VideoStatusResponse(videoId: $videoId, status: $status, progressPercent: $progressPercent, message: $message, jobId: $jobId)';
}


}

/// @nodoc
abstract mixin class _$VideoStatusResponseCopyWith<$Res> implements $VideoStatusResponseCopyWith<$Res> {
  factory _$VideoStatusResponseCopyWith(_VideoStatusResponse value, $Res Function(_VideoStatusResponse) _then) = __$VideoStatusResponseCopyWithImpl;
@override @useResult
$Res call({
 String videoId, String status, int progressPercent, String? message, String? jobId
});




}
/// @nodoc
class __$VideoStatusResponseCopyWithImpl<$Res>
    implements _$VideoStatusResponseCopyWith<$Res> {
  __$VideoStatusResponseCopyWithImpl(this._self, this._then);

  final _VideoStatusResponse _self;
  final $Res Function(_VideoStatusResponse) _then;

/// Create a copy of VideoStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoId = null,Object? status = null,Object? progressPercent = null,Object? message = freezed,Object? jobId = freezed,}) {
  return _then(_VideoStatusResponse(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
