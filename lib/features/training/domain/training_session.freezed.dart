// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainingSession {

 String get id; String get name; String get notes; List<TrainingProp> get props; List<DrillPath> get paths; TacticBoardTemplate? get boardTemplate; DateTime get updatedAt;
/// Create a copy of TrainingSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingSessionCopyWith<TrainingSession> get copyWith => _$TrainingSessionCopyWithImpl<TrainingSession>(this as TrainingSession, _$identity);

  /// Serializes this TrainingSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.props, props)&&const DeepCollectionEquality().equals(other.paths, paths)&&(identical(other.boardTemplate, boardTemplate) || other.boardTemplate == boardTemplate)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,notes,const DeepCollectionEquality().hash(props),const DeepCollectionEquality().hash(paths),boardTemplate,updatedAt);

@override
String toString() {
  return 'TrainingSession(id: $id, name: $name, notes: $notes, props: $props, paths: $paths, boardTemplate: $boardTemplate, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TrainingSessionCopyWith<$Res>  {
  factory $TrainingSessionCopyWith(TrainingSession value, $Res Function(TrainingSession) _then) = _$TrainingSessionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String notes, List<TrainingProp> props, List<DrillPath> paths, TacticBoardTemplate? boardTemplate, DateTime updatedAt
});


$TacticBoardTemplateCopyWith<$Res>? get boardTemplate;

}
/// @nodoc
class _$TrainingSessionCopyWithImpl<$Res>
    implements $TrainingSessionCopyWith<$Res> {
  _$TrainingSessionCopyWithImpl(this._self, this._then);

  final TrainingSession _self;
  final $Res Function(TrainingSession) _then;

/// Create a copy of TrainingSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? notes = null,Object? props = null,Object? paths = null,Object? boardTemplate = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,props: null == props ? _self.props : props // ignore: cast_nullable_to_non_nullable
as List<TrainingProp>,paths: null == paths ? _self.paths : paths // ignore: cast_nullable_to_non_nullable
as List<DrillPath>,boardTemplate: freezed == boardTemplate ? _self.boardTemplate : boardTemplate // ignore: cast_nullable_to_non_nullable
as TacticBoardTemplate?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of TrainingSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticBoardTemplateCopyWith<$Res>? get boardTemplate {
    if (_self.boardTemplate == null) {
    return null;
  }

  return $TacticBoardTemplateCopyWith<$Res>(_self.boardTemplate!, (value) {
    return _then(_self.copyWith(boardTemplate: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrainingSession].
extension TrainingSessionPatterns on TrainingSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingSession value)  $default,){
final _that = this;
switch (_that) {
case _TrainingSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingSession value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String notes,  List<TrainingProp> props,  List<DrillPath> paths,  TacticBoardTemplate? boardTemplate,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingSession() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.props,_that.paths,_that.boardTemplate,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String notes,  List<TrainingProp> props,  List<DrillPath> paths,  TacticBoardTemplate? boardTemplate,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TrainingSession():
return $default(_that.id,_that.name,_that.notes,_that.props,_that.paths,_that.boardTemplate,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String notes,  List<TrainingProp> props,  List<DrillPath> paths,  TacticBoardTemplate? boardTemplate,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainingSession() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.props,_that.paths,_that.boardTemplate,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingSession implements TrainingSession {
  const _TrainingSession({required this.id, required this.name, this.notes = '', final  List<TrainingProp> props = const [], final  List<DrillPath> paths = const [], this.boardTemplate, required this.updatedAt}): _props = props,_paths = paths;
  factory _TrainingSession.fromJson(Map<String, dynamic> json) => _$TrainingSessionFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String notes;
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

@override final  TacticBoardTemplate? boardTemplate;
@override final  DateTime updatedAt;

/// Create a copy of TrainingSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingSessionCopyWith<_TrainingSession> get copyWith => __$TrainingSessionCopyWithImpl<_TrainingSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingSession&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._props, _props)&&const DeepCollectionEquality().equals(other._paths, _paths)&&(identical(other.boardTemplate, boardTemplate) || other.boardTemplate == boardTemplate)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,notes,const DeepCollectionEquality().hash(_props),const DeepCollectionEquality().hash(_paths),boardTemplate,updatedAt);

@override
String toString() {
  return 'TrainingSession(id: $id, name: $name, notes: $notes, props: $props, paths: $paths, boardTemplate: $boardTemplate, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TrainingSessionCopyWith<$Res> implements $TrainingSessionCopyWith<$Res> {
  factory _$TrainingSessionCopyWith(_TrainingSession value, $Res Function(_TrainingSession) _then) = __$TrainingSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String notes, List<TrainingProp> props, List<DrillPath> paths, TacticBoardTemplate? boardTemplate, DateTime updatedAt
});


@override $TacticBoardTemplateCopyWith<$Res>? get boardTemplate;

}
/// @nodoc
class __$TrainingSessionCopyWithImpl<$Res>
    implements _$TrainingSessionCopyWith<$Res> {
  __$TrainingSessionCopyWithImpl(this._self, this._then);

  final _TrainingSession _self;
  final $Res Function(_TrainingSession) _then;

/// Create a copy of TrainingSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? notes = null,Object? props = null,Object? paths = null,Object? boardTemplate = freezed,Object? updatedAt = null,}) {
  return _then(_TrainingSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,props: null == props ? _self._props : props // ignore: cast_nullable_to_non_nullable
as List<TrainingProp>,paths: null == paths ? _self._paths : paths // ignore: cast_nullable_to_non_nullable
as List<DrillPath>,boardTemplate: freezed == boardTemplate ? _self.boardTemplate : boardTemplate // ignore: cast_nullable_to_non_nullable
as TacticBoardTemplate?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of TrainingSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticBoardTemplateCopyWith<$Res>? get boardTemplate {
    if (_self.boardTemplate == null) {
    return null;
  }

  return $TacticBoardTemplateCopyWith<$Res>(_self.boardTemplate!, (value) {
    return _then(_self.copyWith(boardTemplate: value));
  });
}
}

// dart format on
