// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Zone {

 String get id; double get x; double get y; double get width; double get height; int get colorValue; bool get locked; int get zIndex; double get rotation;
/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneCopyWith<Zone> get copyWith => _$ZoneCopyWithImpl<Zone>(this as Zone, _$identity);

  /// Serializes this Zone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Zone&&(identical(other.id, id) || other.id == id)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex)&&(identical(other.rotation, rotation) || other.rotation == rotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,x,y,width,height,colorValue,locked,zIndex,rotation);

@override
String toString() {
  return 'Zone(id: $id, x: $x, y: $y, width: $width, height: $height, colorValue: $colorValue, locked: $locked, zIndex: $zIndex, rotation: $rotation)';
}


}

/// @nodoc
abstract mixin class $ZoneCopyWith<$Res>  {
  factory $ZoneCopyWith(Zone value, $Res Function(Zone) _then) = _$ZoneCopyWithImpl;
@useResult
$Res call({
 String id, double x, double y, double width, double height, int colorValue, bool locked, int zIndex, double rotation
});




}
/// @nodoc
class _$ZoneCopyWithImpl<$Res>
    implements $ZoneCopyWith<$Res> {
  _$ZoneCopyWithImpl(this._self, this._then);

  final Zone _self;
  final $Res Function(Zone) _then;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? colorValue = null,Object? locked = null,Object? zIndex = null,Object? rotation = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Zone].
extension ZonePatterns on Zone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Zone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Zone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Zone value)  $default,){
final _that = this;
switch (_that) {
case _Zone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Zone value)?  $default,){
final _that = this;
switch (_that) {
case _Zone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double x,  double y,  double width,  double height,  int colorValue,  bool locked,  int zIndex,  double rotation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that.id,_that.x,_that.y,_that.width,_that.height,_that.colorValue,_that.locked,_that.zIndex,_that.rotation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double x,  double y,  double width,  double height,  int colorValue,  bool locked,  int zIndex,  double rotation)  $default,) {final _that = this;
switch (_that) {
case _Zone():
return $default(_that.id,_that.x,_that.y,_that.width,_that.height,_that.colorValue,_that.locked,_that.zIndex,_that.rotation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double x,  double y,  double width,  double height,  int colorValue,  bool locked,  int zIndex,  double rotation)?  $default,) {final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that.id,_that.x,_that.y,_that.width,_that.height,_that.colorValue,_that.locked,_that.zIndex,_that.rotation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Zone implements Zone {
  const _Zone({required this.id, required this.x, required this.y, required this.width, required this.height, required this.colorValue, this.locked = false, this.zIndex = 0, this.rotation = 0.0});
  factory _Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);

@override final  String id;
@override final  double x;
@override final  double y;
@override final  double width;
@override final  double height;
@override final  int colorValue;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  int zIndex;
@override@JsonKey() final  double rotation;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ZoneCopyWith<_Zone> get copyWith => __$ZoneCopyWithImpl<_Zone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ZoneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Zone&&(identical(other.id, id) || other.id == id)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex)&&(identical(other.rotation, rotation) || other.rotation == rotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,x,y,width,height,colorValue,locked,zIndex,rotation);

@override
String toString() {
  return 'Zone(id: $id, x: $x, y: $y, width: $width, height: $height, colorValue: $colorValue, locked: $locked, zIndex: $zIndex, rotation: $rotation)';
}


}

/// @nodoc
abstract mixin class _$ZoneCopyWith<$Res> implements $ZoneCopyWith<$Res> {
  factory _$ZoneCopyWith(_Zone value, $Res Function(_Zone) _then) = __$ZoneCopyWithImpl;
@override @useResult
$Res call({
 String id, double x, double y, double width, double height, int colorValue, bool locked, int zIndex, double rotation
});




}
/// @nodoc
class __$ZoneCopyWithImpl<$Res>
    implements _$ZoneCopyWith<$Res> {
  __$ZoneCopyWithImpl(this._self, this._then);

  final _Zone _self;
  final $Res Function(_Zone) _then;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? x = null,Object? y = null,Object? width = null,Object? height = null,Object? colorValue = null,Object? locked = null,Object? zIndex = null,Object? rotation = null,}) {
  return _then(_Zone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
