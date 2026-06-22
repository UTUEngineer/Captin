// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drill_path.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DrillPath {

 String get id; double get startX; double get startY; double get endX; double get endY; List<PathControlPoint> get controlPoints;@DrillPathStyleConverter() DrillPathStyle get style; int get colorValue;
/// Create a copy of DrillPath
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrillPathCopyWith<DrillPath> get copyWith => _$DrillPathCopyWithImpl<DrillPath>(this as DrillPath, _$identity);

  /// Serializes this DrillPath to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DrillPath&&(identical(other.id, id) || other.id == id)&&(identical(other.startX, startX) || other.startX == startX)&&(identical(other.startY, startY) || other.startY == startY)&&(identical(other.endX, endX) || other.endX == endX)&&(identical(other.endY, endY) || other.endY == endY)&&const DeepCollectionEquality().equals(other.controlPoints, controlPoints)&&(identical(other.style, style) || other.style == style)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startX,startY,endX,endY,const DeepCollectionEquality().hash(controlPoints),style,colorValue);

@override
String toString() {
  return 'DrillPath(id: $id, startX: $startX, startY: $startY, endX: $endX, endY: $endY, controlPoints: $controlPoints, style: $style, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class $DrillPathCopyWith<$Res>  {
  factory $DrillPathCopyWith(DrillPath value, $Res Function(DrillPath) _then) = _$DrillPathCopyWithImpl;
@useResult
$Res call({
 String id, double startX, double startY, double endX, double endY, List<PathControlPoint> controlPoints,@DrillPathStyleConverter() DrillPathStyle style, int colorValue
});




}
/// @nodoc
class _$DrillPathCopyWithImpl<$Res>
    implements $DrillPathCopyWith<$Res> {
  _$DrillPathCopyWithImpl(this._self, this._then);

  final DrillPath _self;
  final $Res Function(DrillPath) _then;

/// Create a copy of DrillPath
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startX = null,Object? startY = null,Object? endX = null,Object? endY = null,Object? controlPoints = null,Object? style = null,Object? colorValue = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startX: null == startX ? _self.startX : startX // ignore: cast_nullable_to_non_nullable
as double,startY: null == startY ? _self.startY : startY // ignore: cast_nullable_to_non_nullable
as double,endX: null == endX ? _self.endX : endX // ignore: cast_nullable_to_non_nullable
as double,endY: null == endY ? _self.endY : endY // ignore: cast_nullable_to_non_nullable
as double,controlPoints: null == controlPoints ? _self.controlPoints : controlPoints // ignore: cast_nullable_to_non_nullable
as List<PathControlPoint>,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as DrillPathStyle,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DrillPath].
extension DrillPathPatterns on DrillPath {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DrillPath value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DrillPath() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DrillPath value)  $default,){
final _that = this;
switch (_that) {
case _DrillPath():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DrillPath value)?  $default,){
final _that = this;
switch (_that) {
case _DrillPath() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double startX,  double startY,  double endX,  double endY,  List<PathControlPoint> controlPoints, @DrillPathStyleConverter()  DrillPathStyle style,  int colorValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DrillPath() when $default != null:
return $default(_that.id,_that.startX,_that.startY,_that.endX,_that.endY,_that.controlPoints,_that.style,_that.colorValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double startX,  double startY,  double endX,  double endY,  List<PathControlPoint> controlPoints, @DrillPathStyleConverter()  DrillPathStyle style,  int colorValue)  $default,) {final _that = this;
switch (_that) {
case _DrillPath():
return $default(_that.id,_that.startX,_that.startY,_that.endX,_that.endY,_that.controlPoints,_that.style,_that.colorValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double startX,  double startY,  double endX,  double endY,  List<PathControlPoint> controlPoints, @DrillPathStyleConverter()  DrillPathStyle style,  int colorValue)?  $default,) {final _that = this;
switch (_that) {
case _DrillPath() when $default != null:
return $default(_that.id,_that.startX,_that.startY,_that.endX,_that.endY,_that.controlPoints,_that.style,_that.colorValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DrillPath implements DrillPath {
  const _DrillPath({required this.id, required this.startX, required this.startY, required this.endX, required this.endY, final  List<PathControlPoint> controlPoints = const [], @DrillPathStyleConverter() this.style = DrillPathStyle.run, this.colorValue = 0xFF2E7D32}): _controlPoints = controlPoints;
  factory _DrillPath.fromJson(Map<String, dynamic> json) => _$DrillPathFromJson(json);

@override final  String id;
@override final  double startX;
@override final  double startY;
@override final  double endX;
@override final  double endY;
 final  List<PathControlPoint> _controlPoints;
@override@JsonKey() List<PathControlPoint> get controlPoints {
  if (_controlPoints is EqualUnmodifiableListView) return _controlPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_controlPoints);
}

@override@JsonKey()@DrillPathStyleConverter() final  DrillPathStyle style;
@override@JsonKey() final  int colorValue;

/// Create a copy of DrillPath
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DrillPathCopyWith<_DrillPath> get copyWith => __$DrillPathCopyWithImpl<_DrillPath>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DrillPathToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DrillPath&&(identical(other.id, id) || other.id == id)&&(identical(other.startX, startX) || other.startX == startX)&&(identical(other.startY, startY) || other.startY == startY)&&(identical(other.endX, endX) || other.endX == endX)&&(identical(other.endY, endY) || other.endY == endY)&&const DeepCollectionEquality().equals(other._controlPoints, _controlPoints)&&(identical(other.style, style) || other.style == style)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startX,startY,endX,endY,const DeepCollectionEquality().hash(_controlPoints),style,colorValue);

@override
String toString() {
  return 'DrillPath(id: $id, startX: $startX, startY: $startY, endX: $endX, endY: $endY, controlPoints: $controlPoints, style: $style, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class _$DrillPathCopyWith<$Res> implements $DrillPathCopyWith<$Res> {
  factory _$DrillPathCopyWith(_DrillPath value, $Res Function(_DrillPath) _then) = __$DrillPathCopyWithImpl;
@override @useResult
$Res call({
 String id, double startX, double startY, double endX, double endY, List<PathControlPoint> controlPoints,@DrillPathStyleConverter() DrillPathStyle style, int colorValue
});




}
/// @nodoc
class __$DrillPathCopyWithImpl<$Res>
    implements _$DrillPathCopyWith<$Res> {
  __$DrillPathCopyWithImpl(this._self, this._then);

  final _DrillPath _self;
  final $Res Function(_DrillPath) _then;

/// Create a copy of DrillPath
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startX = null,Object? startY = null,Object? endX = null,Object? endY = null,Object? controlPoints = null,Object? style = null,Object? colorValue = null,}) {
  return _then(_DrillPath(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startX: null == startX ? _self.startX : startX // ignore: cast_nullable_to_non_nullable
as double,startY: null == startY ? _self.startY : startY // ignore: cast_nullable_to_non_nullable
as double,endX: null == endX ? _self.endX : endX // ignore: cast_nullable_to_non_nullable
as double,endY: null == endY ? _self.endY : endY // ignore: cast_nullable_to_non_nullable
as double,controlPoints: null == controlPoints ? _self._controlPoints : controlPoints // ignore: cast_nullable_to_non_nullable
as List<PathControlPoint>,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as DrillPathStyle,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
