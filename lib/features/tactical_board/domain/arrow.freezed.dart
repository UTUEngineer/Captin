// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'arrow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Arrow {

 String get id; double get startX; double get startY; double get endX; double get endY; ArrowType get type; bool get curved; int? get colorValue; bool get locked; int get zIndex; double get rotation;
/// Create a copy of Arrow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArrowCopyWith<Arrow> get copyWith => _$ArrowCopyWithImpl<Arrow>(this as Arrow, _$identity);

  /// Serializes this Arrow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Arrow&&(identical(other.id, id) || other.id == id)&&(identical(other.startX, startX) || other.startX == startX)&&(identical(other.startY, startY) || other.startY == startY)&&(identical(other.endX, endX) || other.endX == endX)&&(identical(other.endY, endY) || other.endY == endY)&&(identical(other.type, type) || other.type == type)&&(identical(other.curved, curved) || other.curved == curved)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex)&&(identical(other.rotation, rotation) || other.rotation == rotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startX,startY,endX,endY,type,curved,colorValue,locked,zIndex,rotation);

@override
String toString() {
  return 'Arrow(id: $id, startX: $startX, startY: $startY, endX: $endX, endY: $endY, type: $type, curved: $curved, colorValue: $colorValue, locked: $locked, zIndex: $zIndex, rotation: $rotation)';
}


}

/// @nodoc
abstract mixin class $ArrowCopyWith<$Res>  {
  factory $ArrowCopyWith(Arrow value, $Res Function(Arrow) _then) = _$ArrowCopyWithImpl;
@useResult
$Res call({
 String id, double startX, double startY, double endX, double endY, ArrowType type, bool curved, int? colorValue, bool locked, int zIndex, double rotation
});




}
/// @nodoc
class _$ArrowCopyWithImpl<$Res>
    implements $ArrowCopyWith<$Res> {
  _$ArrowCopyWithImpl(this._self, this._then);

  final Arrow _self;
  final $Res Function(Arrow) _then;

/// Create a copy of Arrow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startX = null,Object? startY = null,Object? endX = null,Object? endY = null,Object? type = null,Object? curved = null,Object? colorValue = freezed,Object? locked = null,Object? zIndex = null,Object? rotation = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startX: null == startX ? _self.startX : startX // ignore: cast_nullable_to_non_nullable
as double,startY: null == startY ? _self.startY : startY // ignore: cast_nullable_to_non_nullable
as double,endX: null == endX ? _self.endX : endX // ignore: cast_nullable_to_non_nullable
as double,endY: null == endY ? _self.endY : endY // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ArrowType,curved: null == curved ? _self.curved : curved // ignore: cast_nullable_to_non_nullable
as bool,colorValue: freezed == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int?,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Arrow].
extension ArrowPatterns on Arrow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Arrow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Arrow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Arrow value)  $default,){
final _that = this;
switch (_that) {
case _Arrow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Arrow value)?  $default,){
final _that = this;
switch (_that) {
case _Arrow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double startX,  double startY,  double endX,  double endY,  ArrowType type,  bool curved,  int? colorValue,  bool locked,  int zIndex,  double rotation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Arrow() when $default != null:
return $default(_that.id,_that.startX,_that.startY,_that.endX,_that.endY,_that.type,_that.curved,_that.colorValue,_that.locked,_that.zIndex,_that.rotation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double startX,  double startY,  double endX,  double endY,  ArrowType type,  bool curved,  int? colorValue,  bool locked,  int zIndex,  double rotation)  $default,) {final _that = this;
switch (_that) {
case _Arrow():
return $default(_that.id,_that.startX,_that.startY,_that.endX,_that.endY,_that.type,_that.curved,_that.colorValue,_that.locked,_that.zIndex,_that.rotation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double startX,  double startY,  double endX,  double endY,  ArrowType type,  bool curved,  int? colorValue,  bool locked,  int zIndex,  double rotation)?  $default,) {final _that = this;
switch (_that) {
case _Arrow() when $default != null:
return $default(_that.id,_that.startX,_that.startY,_that.endX,_that.endY,_that.type,_that.curved,_that.colorValue,_that.locked,_that.zIndex,_that.rotation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Arrow implements Arrow {
  const _Arrow({required this.id, required this.startX, required this.startY, required this.endX, required this.endY, required this.type, this.curved = false, this.colorValue, this.locked = false, this.zIndex = 0, this.rotation = 0.0});
  factory _Arrow.fromJson(Map<String, dynamic> json) => _$ArrowFromJson(json);

@override final  String id;
@override final  double startX;
@override final  double startY;
@override final  double endX;
@override final  double endY;
@override final  ArrowType type;
@override@JsonKey() final  bool curved;
@override final  int? colorValue;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  int zIndex;
@override@JsonKey() final  double rotation;

/// Create a copy of Arrow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArrowCopyWith<_Arrow> get copyWith => __$ArrowCopyWithImpl<_Arrow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArrowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Arrow&&(identical(other.id, id) || other.id == id)&&(identical(other.startX, startX) || other.startX == startX)&&(identical(other.startY, startY) || other.startY == startY)&&(identical(other.endX, endX) || other.endX == endX)&&(identical(other.endY, endY) || other.endY == endY)&&(identical(other.type, type) || other.type == type)&&(identical(other.curved, curved) || other.curved == curved)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex)&&(identical(other.rotation, rotation) || other.rotation == rotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startX,startY,endX,endY,type,curved,colorValue,locked,zIndex,rotation);

@override
String toString() {
  return 'Arrow(id: $id, startX: $startX, startY: $startY, endX: $endX, endY: $endY, type: $type, curved: $curved, colorValue: $colorValue, locked: $locked, zIndex: $zIndex, rotation: $rotation)';
}


}

/// @nodoc
abstract mixin class _$ArrowCopyWith<$Res> implements $ArrowCopyWith<$Res> {
  factory _$ArrowCopyWith(_Arrow value, $Res Function(_Arrow) _then) = __$ArrowCopyWithImpl;
@override @useResult
$Res call({
 String id, double startX, double startY, double endX, double endY, ArrowType type, bool curved, int? colorValue, bool locked, int zIndex, double rotation
});




}
/// @nodoc
class __$ArrowCopyWithImpl<$Res>
    implements _$ArrowCopyWith<$Res> {
  __$ArrowCopyWithImpl(this._self, this._then);

  final _Arrow _self;
  final $Res Function(_Arrow) _then;

/// Create a copy of Arrow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startX = null,Object? startY = null,Object? endX = null,Object? endY = null,Object? type = null,Object? curved = null,Object? colorValue = freezed,Object? locked = null,Object? zIndex = null,Object? rotation = null,}) {
  return _then(_Arrow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startX: null == startX ? _self.startX : startX // ignore: cast_nullable_to_non_nullable
as double,startY: null == startY ? _self.startY : startY // ignore: cast_nullable_to_non_nullable
as double,endX: null == endX ? _self.endX : endX // ignore: cast_nullable_to_non_nullable
as double,endY: null == endY ? _self.endY : endY // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ArrowType,curved: null == curved ? _self.curved : curved // ignore: cast_nullable_to_non_nullable
as bool,colorValue: freezed == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int?,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
