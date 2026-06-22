// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_upload_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoUploadResponse {

 String get videoId; String get status; double get durationSeconds;
/// Create a copy of VideoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoUploadResponseCopyWith<VideoUploadResponse> get copyWith => _$VideoUploadResponseCopyWithImpl<VideoUploadResponse>(this as VideoUploadResponse, _$identity);

  /// Serializes this VideoUploadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoUploadResponse&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.status, status) || other.status == status)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,status,durationSeconds);

@override
String toString() {
  return 'VideoUploadResponse(videoId: $videoId, status: $status, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $VideoUploadResponseCopyWith<$Res>  {
  factory $VideoUploadResponseCopyWith(VideoUploadResponse value, $Res Function(VideoUploadResponse) _then) = _$VideoUploadResponseCopyWithImpl;
@useResult
$Res call({
 String videoId, String status, double durationSeconds
});




}
/// @nodoc
class _$VideoUploadResponseCopyWithImpl<$Res>
    implements $VideoUploadResponseCopyWith<$Res> {
  _$VideoUploadResponseCopyWithImpl(this._self, this._then);

  final VideoUploadResponse _self;
  final $Res Function(VideoUploadResponse) _then;

/// Create a copy of VideoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoId = null,Object? status = null,Object? durationSeconds = null,}) {
  return _then(_self.copyWith(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoUploadResponse].
extension VideoUploadResponsePatterns on VideoUploadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoUploadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoUploadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoUploadResponse value)  $default,){
final _that = this;
switch (_that) {
case _VideoUploadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoUploadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _VideoUploadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String videoId,  String status,  double durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoUploadResponse() when $default != null:
return $default(_that.videoId,_that.status,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String videoId,  String status,  double durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _VideoUploadResponse():
return $default(_that.videoId,_that.status,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String videoId,  String status,  double durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _VideoUploadResponse() when $default != null:
return $default(_that.videoId,_that.status,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _VideoUploadResponse implements VideoUploadResponse {
  const _VideoUploadResponse({required this.videoId, required this.status, required this.durationSeconds});
  factory _VideoUploadResponse.fromJson(Map<String, dynamic> json) => _$VideoUploadResponseFromJson(json);

@override final  String videoId;
@override final  String status;
@override final  double durationSeconds;

/// Create a copy of VideoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoUploadResponseCopyWith<_VideoUploadResponse> get copyWith => __$VideoUploadResponseCopyWithImpl<_VideoUploadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoUploadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoUploadResponse&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.status, status) || other.status == status)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,status,durationSeconds);

@override
String toString() {
  return 'VideoUploadResponse(videoId: $videoId, status: $status, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$VideoUploadResponseCopyWith<$Res> implements $VideoUploadResponseCopyWith<$Res> {
  factory _$VideoUploadResponseCopyWith(_VideoUploadResponse value, $Res Function(_VideoUploadResponse) _then) = __$VideoUploadResponseCopyWithImpl;
@override @useResult
$Res call({
 String videoId, String status, double durationSeconds
});




}
/// @nodoc
class __$VideoUploadResponseCopyWithImpl<$Res>
    implements _$VideoUploadResponseCopyWith<$Res> {
  __$VideoUploadResponseCopyWithImpl(this._self, this._then);

  final _VideoUploadResponse _self;
  final $Res Function(_VideoUploadResponse) _then;

/// Create a copy of VideoUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoId = null,Object? status = null,Object? durationSeconds = null,}) {
  return _then(_VideoUploadResponse(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
