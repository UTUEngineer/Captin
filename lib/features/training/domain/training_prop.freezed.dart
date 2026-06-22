// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_prop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainingProp {

 String get id;@TrainingPropTypeConverter() TrainingPropType get type; double get x; double get y; double get rotation; int? get colorValue; String? get label;
/// Create a copy of TrainingProp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingPropCopyWith<TrainingProp> get copyWith => _$TrainingPropCopyWithImpl<TrainingProp>(this as TrainingProp, _$identity);

  /// Serializes this TrainingProp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingProp&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,x,y,rotation,colorValue,label);

@override
String toString() {
  return 'TrainingProp(id: $id, type: $type, x: $x, y: $y, rotation: $rotation, colorValue: $colorValue, label: $label)';
}


}

/// @nodoc
abstract mixin class $TrainingPropCopyWith<$Res>  {
  factory $TrainingPropCopyWith(TrainingProp value, $Res Function(TrainingProp) _then) = _$TrainingPropCopyWithImpl;
@useResult
$Res call({
 String id,@TrainingPropTypeConverter() TrainingPropType type, double x, double y, double rotation, int? colorValue, String? label
});




}
/// @nodoc
class _$TrainingPropCopyWithImpl<$Res>
    implements $TrainingPropCopyWith<$Res> {
  _$TrainingPropCopyWithImpl(this._self, this._then);

  final TrainingProp _self;
  final $Res Function(TrainingProp) _then;

/// Create a copy of TrainingProp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? x = null,Object? y = null,Object? rotation = null,Object? colorValue = freezed,Object? label = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TrainingPropType,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,colorValue: freezed == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainingProp].
extension TrainingPropPatterns on TrainingProp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingProp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingProp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingProp value)  $default,){
final _that = this;
switch (_that) {
case _TrainingProp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingProp value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingProp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @TrainingPropTypeConverter()  TrainingPropType type,  double x,  double y,  double rotation,  int? colorValue,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingProp() when $default != null:
return $default(_that.id,_that.type,_that.x,_that.y,_that.rotation,_that.colorValue,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @TrainingPropTypeConverter()  TrainingPropType type,  double x,  double y,  double rotation,  int? colorValue,  String? label)  $default,) {final _that = this;
switch (_that) {
case _TrainingProp():
return $default(_that.id,_that.type,_that.x,_that.y,_that.rotation,_that.colorValue,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @TrainingPropTypeConverter()  TrainingPropType type,  double x,  double y,  double rotation,  int? colorValue,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _TrainingProp() when $default != null:
return $default(_that.id,_that.type,_that.x,_that.y,_that.rotation,_that.colorValue,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingProp implements TrainingProp {
  const _TrainingProp({required this.id, @TrainingPropTypeConverter() required this.type, required this.x, required this.y, this.rotation = 0.0, this.colorValue, this.label});
  factory _TrainingProp.fromJson(Map<String, dynamic> json) => _$TrainingPropFromJson(json);

@override final  String id;
@override@TrainingPropTypeConverter() final  TrainingPropType type;
@override final  double x;
@override final  double y;
@override@JsonKey() final  double rotation;
@override final  int? colorValue;
@override final  String? label;

/// Create a copy of TrainingProp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingPropCopyWith<_TrainingProp> get copyWith => __$TrainingPropCopyWithImpl<_TrainingProp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingPropToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingProp&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,x,y,rotation,colorValue,label);

@override
String toString() {
  return 'TrainingProp(id: $id, type: $type, x: $x, y: $y, rotation: $rotation, colorValue: $colorValue, label: $label)';
}


}

/// @nodoc
abstract mixin class _$TrainingPropCopyWith<$Res> implements $TrainingPropCopyWith<$Res> {
  factory _$TrainingPropCopyWith(_TrainingProp value, $Res Function(_TrainingProp) _then) = __$TrainingPropCopyWithImpl;
@override @useResult
$Res call({
 String id,@TrainingPropTypeConverter() TrainingPropType type, double x, double y, double rotation, int? colorValue, String? label
});




}
/// @nodoc
class __$TrainingPropCopyWithImpl<$Res>
    implements _$TrainingPropCopyWith<$Res> {
  __$TrainingPropCopyWithImpl(this._self, this._then);

  final _TrainingProp _self;
  final $Res Function(_TrainingProp) _then;

/// Create a copy of TrainingProp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? x = null,Object? y = null,Object? rotation = null,Object? colorValue = freezed,Object? label = freezed,}) {
  return _then(_TrainingProp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TrainingPropType,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,colorValue: freezed == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
