// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'highlight_circle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HighlightCircle {

 String get id; double get centerX; double get centerY; double get radiusX; double get radiusY; int get colorValue; bool get locked; int get zIndex;
/// Create a copy of HighlightCircle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HighlightCircleCopyWith<HighlightCircle> get copyWith => _$HighlightCircleCopyWithImpl<HighlightCircle>(this as HighlightCircle, _$identity);

  /// Serializes this HighlightCircle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HighlightCircle&&(identical(other.id, id) || other.id == id)&&(identical(other.centerX, centerX) || other.centerX == centerX)&&(identical(other.centerY, centerY) || other.centerY == centerY)&&(identical(other.radiusX, radiusX) || other.radiusX == radiusX)&&(identical(other.radiusY, radiusY) || other.radiusY == radiusY)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,centerX,centerY,radiusX,radiusY,colorValue,locked,zIndex);

@override
String toString() {
  return 'HighlightCircle(id: $id, centerX: $centerX, centerY: $centerY, radiusX: $radiusX, radiusY: $radiusY, colorValue: $colorValue, locked: $locked, zIndex: $zIndex)';
}


}

/// @nodoc
abstract mixin class $HighlightCircleCopyWith<$Res>  {
  factory $HighlightCircleCopyWith(HighlightCircle value, $Res Function(HighlightCircle) _then) = _$HighlightCircleCopyWithImpl;
@useResult
$Res call({
 String id, double centerX, double centerY, double radiusX, double radiusY, int colorValue, bool locked, int zIndex
});




}
/// @nodoc
class _$HighlightCircleCopyWithImpl<$Res>
    implements $HighlightCircleCopyWith<$Res> {
  _$HighlightCircleCopyWithImpl(this._self, this._then);

  final HighlightCircle _self;
  final $Res Function(HighlightCircle) _then;

/// Create a copy of HighlightCircle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? centerX = null,Object? centerY = null,Object? radiusX = null,Object? radiusY = null,Object? colorValue = null,Object? locked = null,Object? zIndex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,centerX: null == centerX ? _self.centerX : centerX // ignore: cast_nullable_to_non_nullable
as double,centerY: null == centerY ? _self.centerY : centerY // ignore: cast_nullable_to_non_nullable
as double,radiusX: null == radiusX ? _self.radiusX : radiusX // ignore: cast_nullable_to_non_nullable
as double,radiusY: null == radiusY ? _self.radiusY : radiusY // ignore: cast_nullable_to_non_nullable
as double,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HighlightCircle].
extension HighlightCirclePatterns on HighlightCircle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HighlightCircle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HighlightCircle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HighlightCircle value)  $default,){
final _that = this;
switch (_that) {
case _HighlightCircle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HighlightCircle value)?  $default,){
final _that = this;
switch (_that) {
case _HighlightCircle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double centerX,  double centerY,  double radiusX,  double radiusY,  int colorValue,  bool locked,  int zIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HighlightCircle() when $default != null:
return $default(_that.id,_that.centerX,_that.centerY,_that.radiusX,_that.radiusY,_that.colorValue,_that.locked,_that.zIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double centerX,  double centerY,  double radiusX,  double radiusY,  int colorValue,  bool locked,  int zIndex)  $default,) {final _that = this;
switch (_that) {
case _HighlightCircle():
return $default(_that.id,_that.centerX,_that.centerY,_that.radiusX,_that.radiusY,_that.colorValue,_that.locked,_that.zIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double centerX,  double centerY,  double radiusX,  double radiusY,  int colorValue,  bool locked,  int zIndex)?  $default,) {final _that = this;
switch (_that) {
case _HighlightCircle() when $default != null:
return $default(_that.id,_that.centerX,_that.centerY,_that.radiusX,_that.radiusY,_that.colorValue,_that.locked,_that.zIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HighlightCircle implements HighlightCircle {
  const _HighlightCircle({required this.id, required this.centerX, required this.centerY, required this.radiusX, required this.radiusY, required this.colorValue, this.locked = false, this.zIndex = 0});
  factory _HighlightCircle.fromJson(Map<String, dynamic> json) => _$HighlightCircleFromJson(json);

@override final  String id;
@override final  double centerX;
@override final  double centerY;
@override final  double radiusX;
@override final  double radiusY;
@override final  int colorValue;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  int zIndex;

/// Create a copy of HighlightCircle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HighlightCircleCopyWith<_HighlightCircle> get copyWith => __$HighlightCircleCopyWithImpl<_HighlightCircle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HighlightCircleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HighlightCircle&&(identical(other.id, id) || other.id == id)&&(identical(other.centerX, centerX) || other.centerX == centerX)&&(identical(other.centerY, centerY) || other.centerY == centerY)&&(identical(other.radiusX, radiusX) || other.radiusX == radiusX)&&(identical(other.radiusY, radiusY) || other.radiusY == radiusY)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,centerX,centerY,radiusX,radiusY,colorValue,locked,zIndex);

@override
String toString() {
  return 'HighlightCircle(id: $id, centerX: $centerX, centerY: $centerY, radiusX: $radiusX, radiusY: $radiusY, colorValue: $colorValue, locked: $locked, zIndex: $zIndex)';
}


}

/// @nodoc
abstract mixin class _$HighlightCircleCopyWith<$Res> implements $HighlightCircleCopyWith<$Res> {
  factory _$HighlightCircleCopyWith(_HighlightCircle value, $Res Function(_HighlightCircle) _then) = __$HighlightCircleCopyWithImpl;
@override @useResult
$Res call({
 String id, double centerX, double centerY, double radiusX, double radiusY, int colorValue, bool locked, int zIndex
});




}
/// @nodoc
class __$HighlightCircleCopyWithImpl<$Res>
    implements _$HighlightCircleCopyWith<$Res> {
  __$HighlightCircleCopyWithImpl(this._self, this._then);

  final _HighlightCircle _self;
  final $Res Function(_HighlightCircle) _then;

/// Create a copy of HighlightCircle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? centerX = null,Object? centerY = null,Object? radiusX = null,Object? radiusY = null,Object? colorValue = null,Object? locked = null,Object? zIndex = null,}) {
  return _then(_HighlightCircle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,centerX: null == centerX ? _self.centerX : centerX // ignore: cast_nullable_to_non_nullable
as double,centerY: null == centerY ? _self.centerY : centerY // ignore: cast_nullable_to_non_nullable
as double,radiusX: null == radiusX ? _self.radiusX : radiusX // ignore: cast_nullable_to_non_nullable
as double,radiusY: null == radiusY ? _self.radiusY : radiusY // ignore: cast_nullable_to_non_nullable
as double,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
