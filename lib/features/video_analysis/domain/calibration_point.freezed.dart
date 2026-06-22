// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calibration_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalibrationPoint {

 List<double> get pixel; List<double> get pitch;
/// Create a copy of CalibrationPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalibrationPointCopyWith<CalibrationPoint> get copyWith => _$CalibrationPointCopyWithImpl<CalibrationPoint>(this as CalibrationPoint, _$identity);

  /// Serializes this CalibrationPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalibrationPoint&&const DeepCollectionEquality().equals(other.pixel, pixel)&&const DeepCollectionEquality().equals(other.pitch, pitch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pixel),const DeepCollectionEquality().hash(pitch));

@override
String toString() {
  return 'CalibrationPoint(pixel: $pixel, pitch: $pitch)';
}


}

/// @nodoc
abstract mixin class $CalibrationPointCopyWith<$Res>  {
  factory $CalibrationPointCopyWith(CalibrationPoint value, $Res Function(CalibrationPoint) _then) = _$CalibrationPointCopyWithImpl;
@useResult
$Res call({
 List<double> pixel, List<double> pitch
});




}
/// @nodoc
class _$CalibrationPointCopyWithImpl<$Res>
    implements $CalibrationPointCopyWith<$Res> {
  _$CalibrationPointCopyWithImpl(this._self, this._then);

  final CalibrationPoint _self;
  final $Res Function(CalibrationPoint) _then;

/// Create a copy of CalibrationPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pixel = null,Object? pitch = null,}) {
  return _then(_self.copyWith(
pixel: null == pixel ? _self.pixel : pixel // ignore: cast_nullable_to_non_nullable
as List<double>,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [CalibrationPoint].
extension CalibrationPointPatterns on CalibrationPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalibrationPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalibrationPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalibrationPoint value)  $default,){
final _that = this;
switch (_that) {
case _CalibrationPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalibrationPoint value)?  $default,){
final _that = this;
switch (_that) {
case _CalibrationPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<double> pixel,  List<double> pitch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalibrationPoint() when $default != null:
return $default(_that.pixel,_that.pitch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<double> pixel,  List<double> pitch)  $default,) {final _that = this;
switch (_that) {
case _CalibrationPoint():
return $default(_that.pixel,_that.pitch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<double> pixel,  List<double> pitch)?  $default,) {final _that = this;
switch (_that) {
case _CalibrationPoint() when $default != null:
return $default(_that.pixel,_that.pitch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalibrationPoint implements CalibrationPoint {
  const _CalibrationPoint({required final  List<double> pixel, required final  List<double> pitch}): _pixel = pixel,_pitch = pitch;
  factory _CalibrationPoint.fromJson(Map<String, dynamic> json) => _$CalibrationPointFromJson(json);

 final  List<double> _pixel;
@override List<double> get pixel {
  if (_pixel is EqualUnmodifiableListView) return _pixel;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pixel);
}

 final  List<double> _pitch;
@override List<double> get pitch {
  if (_pitch is EqualUnmodifiableListView) return _pitch;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pitch);
}


/// Create a copy of CalibrationPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalibrationPointCopyWith<_CalibrationPoint> get copyWith => __$CalibrationPointCopyWithImpl<_CalibrationPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalibrationPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalibrationPoint&&const DeepCollectionEquality().equals(other._pixel, _pixel)&&const DeepCollectionEquality().equals(other._pitch, _pitch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pixel),const DeepCollectionEquality().hash(_pitch));

@override
String toString() {
  return 'CalibrationPoint(pixel: $pixel, pitch: $pitch)';
}


}

/// @nodoc
abstract mixin class _$CalibrationPointCopyWith<$Res> implements $CalibrationPointCopyWith<$Res> {
  factory _$CalibrationPointCopyWith(_CalibrationPoint value, $Res Function(_CalibrationPoint) _then) = __$CalibrationPointCopyWithImpl;
@override @useResult
$Res call({
 List<double> pixel, List<double> pitch
});




}
/// @nodoc
class __$CalibrationPointCopyWithImpl<$Res>
    implements _$CalibrationPointCopyWith<$Res> {
  __$CalibrationPointCopyWithImpl(this._self, this._then);

  final _CalibrationPoint _self;
  final $Res Function(_CalibrationPoint) _then;

/// Create a copy of CalibrationPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pixel = null,Object? pitch = null,}) {
  return _then(_CalibrationPoint(
pixel: null == pixel ? _self._pixel : pixel // ignore: cast_nullable_to_non_nullable
as List<double>,pitch: null == pitch ? _self._pitch : pitch // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

// dart format on
