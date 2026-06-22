// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tactic_board_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TacticBoardTemplate {

 String get id; String get name; String? get description; DateTime get updatedAt; bool get isPreset; FormationType? get formation; PitchOrientation get orientation; PitchStyle get pitchStyle; List<Player> get players; List<Arrow> get arrows; List<Zone> get zones; List<HighlightCircle> get highlights; List<TextAnnotation> get textAnnotations;
/// Create a copy of TacticBoardTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TacticBoardTemplateCopyWith<TacticBoardTemplate> get copyWith => _$TacticBoardTemplateCopyWithImpl<TacticBoardTemplate>(this as TacticBoardTemplate, _$identity);

  /// Serializes this TacticBoardTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TacticBoardTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPreset, isPreset) || other.isPreset == isPreset)&&(identical(other.formation, formation) || other.formation == formation)&&(identical(other.orientation, orientation) || other.orientation == orientation)&&(identical(other.pitchStyle, pitchStyle) || other.pitchStyle == pitchStyle)&&const DeepCollectionEquality().equals(other.players, players)&&const DeepCollectionEquality().equals(other.arrows, arrows)&&const DeepCollectionEquality().equals(other.zones, zones)&&const DeepCollectionEquality().equals(other.highlights, highlights)&&const DeepCollectionEquality().equals(other.textAnnotations, textAnnotations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,updatedAt,isPreset,formation,orientation,pitchStyle,const DeepCollectionEquality().hash(players),const DeepCollectionEquality().hash(arrows),const DeepCollectionEquality().hash(zones),const DeepCollectionEquality().hash(highlights),const DeepCollectionEquality().hash(textAnnotations));

@override
String toString() {
  return 'TacticBoardTemplate(id: $id, name: $name, description: $description, updatedAt: $updatedAt, isPreset: $isPreset, formation: $formation, orientation: $orientation, pitchStyle: $pitchStyle, players: $players, arrows: $arrows, zones: $zones, highlights: $highlights, textAnnotations: $textAnnotations)';
}


}

/// @nodoc
abstract mixin class $TacticBoardTemplateCopyWith<$Res>  {
  factory $TacticBoardTemplateCopyWith(TacticBoardTemplate value, $Res Function(TacticBoardTemplate) _then) = _$TacticBoardTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, DateTime updatedAt, bool isPreset, FormationType? formation, PitchOrientation orientation, PitchStyle pitchStyle, List<Player> players, List<Arrow> arrows, List<Zone> zones, List<HighlightCircle> highlights, List<TextAnnotation> textAnnotations
});




}
/// @nodoc
class _$TacticBoardTemplateCopyWithImpl<$Res>
    implements $TacticBoardTemplateCopyWith<$Res> {
  _$TacticBoardTemplateCopyWithImpl(this._self, this._then);

  final TacticBoardTemplate _self;
  final $Res Function(TacticBoardTemplate) _then;

/// Create a copy of TacticBoardTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? updatedAt = null,Object? isPreset = null,Object? formation = freezed,Object? orientation = null,Object? pitchStyle = null,Object? players = null,Object? arrows = null,Object? zones = null,Object? highlights = null,Object? textAnnotations = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPreset: null == isPreset ? _self.isPreset : isPreset // ignore: cast_nullable_to_non_nullable
as bool,formation: freezed == formation ? _self.formation : formation // ignore: cast_nullable_to_non_nullable
as FormationType?,orientation: null == orientation ? _self.orientation : orientation // ignore: cast_nullable_to_non_nullable
as PitchOrientation,pitchStyle: null == pitchStyle ? _self.pitchStyle : pitchStyle // ignore: cast_nullable_to_non_nullable
as PitchStyle,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,arrows: null == arrows ? _self.arrows : arrows // ignore: cast_nullable_to_non_nullable
as List<Arrow>,zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as List<Zone>,highlights: null == highlights ? _self.highlights : highlights // ignore: cast_nullable_to_non_nullable
as List<HighlightCircle>,textAnnotations: null == textAnnotations ? _self.textAnnotations : textAnnotations // ignore: cast_nullable_to_non_nullable
as List<TextAnnotation>,
  ));
}

}


/// Adds pattern-matching-related methods to [TacticBoardTemplate].
extension TacticBoardTemplatePatterns on TacticBoardTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TacticBoardTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TacticBoardTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TacticBoardTemplate value)  $default,){
final _that = this;
switch (_that) {
case _TacticBoardTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TacticBoardTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _TacticBoardTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime updatedAt,  bool isPreset,  FormationType? formation,  PitchOrientation orientation,  PitchStyle pitchStyle,  List<Player> players,  List<Arrow> arrows,  List<Zone> zones,  List<HighlightCircle> highlights,  List<TextAnnotation> textAnnotations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TacticBoardTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.updatedAt,_that.isPreset,_that.formation,_that.orientation,_that.pitchStyle,_that.players,_that.arrows,_that.zones,_that.highlights,_that.textAnnotations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  DateTime updatedAt,  bool isPreset,  FormationType? formation,  PitchOrientation orientation,  PitchStyle pitchStyle,  List<Player> players,  List<Arrow> arrows,  List<Zone> zones,  List<HighlightCircle> highlights,  List<TextAnnotation> textAnnotations)  $default,) {final _that = this;
switch (_that) {
case _TacticBoardTemplate():
return $default(_that.id,_that.name,_that.description,_that.updatedAt,_that.isPreset,_that.formation,_that.orientation,_that.pitchStyle,_that.players,_that.arrows,_that.zones,_that.highlights,_that.textAnnotations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  DateTime updatedAt,  bool isPreset,  FormationType? formation,  PitchOrientation orientation,  PitchStyle pitchStyle,  List<Player> players,  List<Arrow> arrows,  List<Zone> zones,  List<HighlightCircle> highlights,  List<TextAnnotation> textAnnotations)?  $default,) {final _that = this;
switch (_that) {
case _TacticBoardTemplate() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.updatedAt,_that.isPreset,_that.formation,_that.orientation,_that.pitchStyle,_that.players,_that.arrows,_that.zones,_that.highlights,_that.textAnnotations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TacticBoardTemplate implements TacticBoardTemplate {
  const _TacticBoardTemplate({required this.id, required this.name, this.description, required this.updatedAt, this.isPreset = false, this.formation, this.orientation = PitchOrientation.vertical, this.pitchStyle = PitchStyle.striped, final  List<Player> players = const [], final  List<Arrow> arrows = const [], final  List<Zone> zones = const [], final  List<HighlightCircle> highlights = const [], final  List<TextAnnotation> textAnnotations = const []}): _players = players,_arrows = arrows,_zones = zones,_highlights = highlights,_textAnnotations = textAnnotations;
  factory _TacticBoardTemplate.fromJson(Map<String, dynamic> json) => _$TacticBoardTemplateFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  DateTime updatedAt;
@override@JsonKey() final  bool isPreset;
@override final  FormationType? formation;
@override@JsonKey() final  PitchOrientation orientation;
@override@JsonKey() final  PitchStyle pitchStyle;
 final  List<Player> _players;
@override@JsonKey() List<Player> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

 final  List<Arrow> _arrows;
@override@JsonKey() List<Arrow> get arrows {
  if (_arrows is EqualUnmodifiableListView) return _arrows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_arrows);
}

 final  List<Zone> _zones;
@override@JsonKey() List<Zone> get zones {
  if (_zones is EqualUnmodifiableListView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zones);
}

 final  List<HighlightCircle> _highlights;
@override@JsonKey() List<HighlightCircle> get highlights {
  if (_highlights is EqualUnmodifiableListView) return _highlights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_highlights);
}

 final  List<TextAnnotation> _textAnnotations;
@override@JsonKey() List<TextAnnotation> get textAnnotations {
  if (_textAnnotations is EqualUnmodifiableListView) return _textAnnotations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_textAnnotations);
}


/// Create a copy of TacticBoardTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TacticBoardTemplateCopyWith<_TacticBoardTemplate> get copyWith => __$TacticBoardTemplateCopyWithImpl<_TacticBoardTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TacticBoardTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TacticBoardTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isPreset, isPreset) || other.isPreset == isPreset)&&(identical(other.formation, formation) || other.formation == formation)&&(identical(other.orientation, orientation) || other.orientation == orientation)&&(identical(other.pitchStyle, pitchStyle) || other.pitchStyle == pitchStyle)&&const DeepCollectionEquality().equals(other._players, _players)&&const DeepCollectionEquality().equals(other._arrows, _arrows)&&const DeepCollectionEquality().equals(other._zones, _zones)&&const DeepCollectionEquality().equals(other._highlights, _highlights)&&const DeepCollectionEquality().equals(other._textAnnotations, _textAnnotations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,updatedAt,isPreset,formation,orientation,pitchStyle,const DeepCollectionEquality().hash(_players),const DeepCollectionEquality().hash(_arrows),const DeepCollectionEquality().hash(_zones),const DeepCollectionEquality().hash(_highlights),const DeepCollectionEquality().hash(_textAnnotations));

@override
String toString() {
  return 'TacticBoardTemplate(id: $id, name: $name, description: $description, updatedAt: $updatedAt, isPreset: $isPreset, formation: $formation, orientation: $orientation, pitchStyle: $pitchStyle, players: $players, arrows: $arrows, zones: $zones, highlights: $highlights, textAnnotations: $textAnnotations)';
}


}

/// @nodoc
abstract mixin class _$TacticBoardTemplateCopyWith<$Res> implements $TacticBoardTemplateCopyWith<$Res> {
  factory _$TacticBoardTemplateCopyWith(_TacticBoardTemplate value, $Res Function(_TacticBoardTemplate) _then) = __$TacticBoardTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, DateTime updatedAt, bool isPreset, FormationType? formation, PitchOrientation orientation, PitchStyle pitchStyle, List<Player> players, List<Arrow> arrows, List<Zone> zones, List<HighlightCircle> highlights, List<TextAnnotation> textAnnotations
});




}
/// @nodoc
class __$TacticBoardTemplateCopyWithImpl<$Res>
    implements _$TacticBoardTemplateCopyWith<$Res> {
  __$TacticBoardTemplateCopyWithImpl(this._self, this._then);

  final _TacticBoardTemplate _self;
  final $Res Function(_TacticBoardTemplate) _then;

/// Create a copy of TacticBoardTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? updatedAt = null,Object? isPreset = null,Object? formation = freezed,Object? orientation = null,Object? pitchStyle = null,Object? players = null,Object? arrows = null,Object? zones = null,Object? highlights = null,Object? textAnnotations = null,}) {
  return _then(_TacticBoardTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isPreset: null == isPreset ? _self.isPreset : isPreset // ignore: cast_nullable_to_non_nullable
as bool,formation: freezed == formation ? _self.formation : formation // ignore: cast_nullable_to_non_nullable
as FormationType?,orientation: null == orientation ? _self.orientation : orientation // ignore: cast_nullable_to_non_nullable
as PitchOrientation,pitchStyle: null == pitchStyle ? _self.pitchStyle : pitchStyle // ignore: cast_nullable_to_non_nullable
as PitchStyle,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,arrows: null == arrows ? _self._arrows : arrows // ignore: cast_nullable_to_non_nullable
as List<Arrow>,zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as List<Zone>,highlights: null == highlights ? _self._highlights : highlights // ignore: cast_nullable_to_non_nullable
as List<HighlightCircle>,textAnnotations: null == textAnnotations ? _self._textAnnotations : textAnnotations // ignore: cast_nullable_to_non_nullable
as List<TextAnnotation>,
  ));
}


}

// dart format on
