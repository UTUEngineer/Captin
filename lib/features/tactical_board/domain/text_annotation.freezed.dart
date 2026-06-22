// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_annotation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TextAnnotation {

 String get id; double get x; double get y; String get text; bool get locked; int get zIndex;
/// Create a copy of TextAnnotation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextAnnotationCopyWith<TextAnnotation> get copyWith => _$TextAnnotationCopyWithImpl<TextAnnotation>(this as TextAnnotation, _$identity);

  /// Serializes this TextAnnotation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextAnnotation&&(identical(other.id, id) || other.id == id)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.text, text) || other.text == text)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,x,y,text,locked,zIndex);

@override
String toString() {
  return 'TextAnnotation(id: $id, x: $x, y: $y, text: $text, locked: $locked, zIndex: $zIndex)';
}


}

/// @nodoc
abstract mixin class $TextAnnotationCopyWith<$Res>  {
  factory $TextAnnotationCopyWith(TextAnnotation value, $Res Function(TextAnnotation) _then) = _$TextAnnotationCopyWithImpl;
@useResult
$Res call({
 String id, double x, double y, String text, bool locked, int zIndex
});




}
/// @nodoc
class _$TextAnnotationCopyWithImpl<$Res>
    implements $TextAnnotationCopyWith<$Res> {
  _$TextAnnotationCopyWithImpl(this._self, this._then);

  final TextAnnotation _self;
  final $Res Function(TextAnnotation) _then;

/// Create a copy of TextAnnotation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? x = null,Object? y = null,Object? text = null,Object? locked = null,Object? zIndex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TextAnnotation].
extension TextAnnotationPatterns on TextAnnotation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextAnnotation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextAnnotation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextAnnotation value)  $default,){
final _that = this;
switch (_that) {
case _TextAnnotation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextAnnotation value)?  $default,){
final _that = this;
switch (_that) {
case _TextAnnotation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double x,  double y,  String text,  bool locked,  int zIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextAnnotation() when $default != null:
return $default(_that.id,_that.x,_that.y,_that.text,_that.locked,_that.zIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double x,  double y,  String text,  bool locked,  int zIndex)  $default,) {final _that = this;
switch (_that) {
case _TextAnnotation():
return $default(_that.id,_that.x,_that.y,_that.text,_that.locked,_that.zIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double x,  double y,  String text,  bool locked,  int zIndex)?  $default,) {final _that = this;
switch (_that) {
case _TextAnnotation() when $default != null:
return $default(_that.id,_that.x,_that.y,_that.text,_that.locked,_that.zIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextAnnotation implements TextAnnotation {
  const _TextAnnotation({required this.id, required this.x, required this.y, required this.text, this.locked = false, this.zIndex = 0});
  factory _TextAnnotation.fromJson(Map<String, dynamic> json) => _$TextAnnotationFromJson(json);

@override final  String id;
@override final  double x;
@override final  double y;
@override final  String text;
@override@JsonKey() final  bool locked;
@override@JsonKey() final  int zIndex;

/// Create a copy of TextAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextAnnotationCopyWith<_TextAnnotation> get copyWith => __$TextAnnotationCopyWithImpl<_TextAnnotation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextAnnotationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextAnnotation&&(identical(other.id, id) || other.id == id)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.text, text) || other.text == text)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,x,y,text,locked,zIndex);

@override
String toString() {
  return 'TextAnnotation(id: $id, x: $x, y: $y, text: $text, locked: $locked, zIndex: $zIndex)';
}


}

/// @nodoc
abstract mixin class _$TextAnnotationCopyWith<$Res> implements $TextAnnotationCopyWith<$Res> {
  factory _$TextAnnotationCopyWith(_TextAnnotation value, $Res Function(_TextAnnotation) _then) = __$TextAnnotationCopyWithImpl;
@override @useResult
$Res call({
 String id, double x, double y, String text, bool locked, int zIndex
});




}
/// @nodoc
class __$TextAnnotationCopyWithImpl<$Res>
    implements _$TextAnnotationCopyWith<$Res> {
  __$TextAnnotationCopyWithImpl(this._self, this._then);

  final _TextAnnotation _self;
  final $Res Function(_TextAnnotation) _then;

/// Create a copy of TextAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? x = null,Object? y = null,Object? text = null,Object? locked = null,Object? zIndex = null,}) {
  return _then(_TextAnnotation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
