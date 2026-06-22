// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'path_control_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PathControlPoint {

 double get x; double get y;
/// Create a copy of PathControlPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PathControlPointCopyWith<PathControlPoint> get copyWith => _$PathControlPointCopyWithImpl<PathControlPoint>(this as PathControlPoint, _$identity);

  /// Serializes this PathControlPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathControlPoint&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'PathControlPoint(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $PathControlPointCopyWith<$Res>  {
  factory $PathControlPointCopyWith(PathControlPoint value, $Res Function(PathControlPoint) _then) = _$PathControlPointCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$PathControlPointCopyWithImpl<$Res>
    implements $PathControlPointCopyWith<$Res> {
  _$PathControlPointCopyWithImpl(this._self, this._then);

  final PathControlPoint _self;
  final $Res Function(PathControlPoint) _then;

/// Create a copy of PathControlPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PathControlPoint].
extension PathControlPointPatterns on PathControlPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PathControlPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PathControlPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PathControlPoint value)  $default,){
final _that = this;
switch (_that) {
case _PathControlPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PathControlPoint value)?  $default,){
final _that = this;
switch (_that) {
case _PathControlPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PathControlPoint() when $default != null:
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y)  $default,) {final _that = this;
switch (_that) {
case _PathControlPoint():
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y)?  $default,) {final _that = this;
switch (_that) {
case _PathControlPoint() when $default != null:
return $default(_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PathControlPoint implements PathControlPoint {
  const _PathControlPoint({required this.x, required this.y});
  factory _PathControlPoint.fromJson(Map<String, dynamic> json) => _$PathControlPointFromJson(json);

@override final  double x;
@override final  double y;

/// Create a copy of PathControlPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PathControlPointCopyWith<_PathControlPoint> get copyWith => __$PathControlPointCopyWithImpl<_PathControlPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PathControlPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PathControlPoint&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'PathControlPoint(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$PathControlPointCopyWith<$Res> implements $PathControlPointCopyWith<$Res> {
  factory _$PathControlPointCopyWith(_PathControlPoint value, $Res Function(_PathControlPoint) _then) = __$PathControlPointCopyWithImpl;
@override @useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class __$PathControlPointCopyWithImpl<$Res>
    implements _$PathControlPointCopyWith<$Res> {
  __$PathControlPointCopyWithImpl(this._self, this._then);

  final _PathControlPoint _self;
  final $Res Function(_PathControlPoint) _then;

/// Create a copy of PathControlPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(_PathControlPoint(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
