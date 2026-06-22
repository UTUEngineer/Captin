// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drill_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DrillTemplate {

 String get id; String get name; String get description; List<TrainingProp> get props; List<DrillPath> get paths; int get recommendedPlayers;
/// Create a copy of DrillTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrillTemplateCopyWith<DrillTemplate> get copyWith => _$DrillTemplateCopyWithImpl<DrillTemplate>(this as DrillTemplate, _$identity);

  /// Serializes this DrillTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DrillTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.props, props)&&const DeepCollectionEquality().equals(other.paths, paths)&&(identical(other.recommendedPlayers, recommendedPlayers) || other.recommendedPlayers == recommendedPlayers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(props),const DeepCollectionEquality().hash(paths),recommendedPlayers);

@override
String toString() {
  return 'DrillTemplate(id: $id, name: $name, description: $description, props: $props, paths: $paths, recommendedPlayers: $recommendedPlayers)';
}


}

/// @nodoc
abstract mixin class $DrillTemplateCopyWith<$Res>  {
  factory $DrillTemplateCopyWith(DrillTemplate value, $Res Function(DrillTemplate) _then) = _$DrillTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, List<TrainingProp> props, List<DrillPath> paths, int recommendedPlayers
});




}
/// @nodoc
class _$DrillTemplateCopyWithImpl<$Res>
    implements $DrillTemplateCopyWith<$Res> {
  _$DrillTemplateCopyWithImpl(this._self, this._then);

  final DrillTemplate _self;
  final $Res Function(DrillTemplate) _then;

/// Create a copy of DrillTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? props = null,Object? paths = null,Object? recommendedPlayers = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,props: null == props ? _self.props : props // ignore: cast_nullable_to_non_nullable
as List<TrainingProp>,paths: null == paths ? _self.paths : paths // ignore: cast_nullable_to_non_nullable
as List<DrillPath>,recommendedPlayers: null == recommendedPlayers ? _self.recommendedPlayers : recommendedPlayers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DrillTemplate].
extension DrillTemplatePatterns on DrillTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DrillTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DrillTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DrillTemplate value)  $default,){
final _that = this;
switch (_that) {
case _DrillTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DrillTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _DrillTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  List<TrainingProp> props,  List<DrillPath> paths,  int recommendedPlayers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DrillTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.props,_that.paths,_that.recommendedPlayers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  List<TrainingProp> props,  List<DrillPath> paths,  int recommendedPlayers)  $default,) {final _that = this;
switch (_that) {
case _DrillTemplate():
return $default(_that.id,_that.name,_that.description,_that.props,_that.paths,_that.recommendedPlayers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  List<TrainingProp> props,  List<DrillPath> paths,  int recommendedPlayers)?  $default,) {final _that = this;
switch (_that) {
case _DrillTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.props,_that.paths,_that.recommendedPlayers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DrillTemplate implements DrillTemplate {
  const _DrillTemplate({required this.id, required this.name, required this.description, final  List<TrainingProp> props = const [], final  List<DrillPath> paths = const [], this.recommendedPlayers = 8}): _props = props,_paths = paths;
  factory _DrillTemplate.fromJson(Map<String, dynamic> json) => _$DrillTemplateFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
 final  List<TrainingProp> _props;
@override@JsonKey() List<TrainingProp> get props {
  if (_props is EqualUnmodifiableListView) return _props;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_props);
}

 final  List<DrillPath> _paths;
@override@JsonKey() List<DrillPath> get paths {
  if (_paths is EqualUnmodifiableListView) return _paths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paths);
}

@override@JsonKey() final  int recommendedPlayers;

/// Create a copy of DrillTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DrillTemplateCopyWith<_DrillTemplate> get copyWith => __$DrillTemplateCopyWithImpl<_DrillTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DrillTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DrillTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._props, _props)&&const DeepCollectionEquality().equals(other._paths, _paths)&&(identical(other.recommendedPlayers, recommendedPlayers) || other.recommendedPlayers == recommendedPlayers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_props),const DeepCollectionEquality().hash(_paths),recommendedPlayers);

@override
String toString() {
  return 'DrillTemplate(id: $id, name: $name, description: $description, props: $props, paths: $paths, recommendedPlayers: $recommendedPlayers)';
}


}

/// @nodoc
abstract mixin class _$DrillTemplateCopyWith<$Res> implements $DrillTemplateCopyWith<$Res> {
  factory _$DrillTemplateCopyWith(_DrillTemplate value, $Res Function(_DrillTemplate) _then) = __$DrillTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, List<TrainingProp> props, List<DrillPath> paths, int recommendedPlayers
});




}
/// @nodoc
class __$DrillTemplateCopyWithImpl<$Res>
    implements _$DrillTemplateCopyWith<$Res> {
  __$DrillTemplateCopyWithImpl(this._self, this._then);

  final _DrillTemplate _self;
  final $Res Function(_DrillTemplate) _then;

/// Create a copy of DrillTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? props = null,Object? paths = null,Object? recommendedPlayers = null,}) {
  return _then(_DrillTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,props: null == props ? _self._props : props // ignore: cast_nullable_to_non_nullable
as List<TrainingProp>,paths: null == paths ? _self._paths : paths // ignore: cast_nullable_to_non_nullable
as List<DrillPath>,recommendedPlayers: null == recommendedPlayers ? _self.recommendedPlayers : recommendedPlayers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
