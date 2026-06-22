// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_timeline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchTimeline {

 String get id; String get matchId; int get duration; List<TimelineEvent> get events;
/// Create a copy of MatchTimeline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchTimelineCopyWith<MatchTimeline> get copyWith => _$MatchTimelineCopyWithImpl<MatchTimeline>(this as MatchTimeline, _$identity);

  /// Serializes this MatchTimeline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchTimeline&&(identical(other.id, id) || other.id == id)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.duration, duration) || other.duration == duration)&&const DeepCollectionEquality().equals(other.events, events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,matchId,duration,const DeepCollectionEquality().hash(events));

@override
String toString() {
  return 'MatchTimeline(id: $id, matchId: $matchId, duration: $duration, events: $events)';
}


}

/// @nodoc
abstract mixin class $MatchTimelineCopyWith<$Res>  {
  factory $MatchTimelineCopyWith(MatchTimeline value, $Res Function(MatchTimeline) _then) = _$MatchTimelineCopyWithImpl;
@useResult
$Res call({
 String id, String matchId, int duration, List<TimelineEvent> events
});




}
/// @nodoc
class _$MatchTimelineCopyWithImpl<$Res>
    implements $MatchTimelineCopyWith<$Res> {
  _$MatchTimelineCopyWithImpl(this._self, this._then);

  final MatchTimeline _self;
  final $Res Function(MatchTimeline) _then;

/// Create a copy of MatchTimeline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? matchId = null,Object? duration = null,Object? events = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<TimelineEvent>,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchTimeline].
extension MatchTimelinePatterns on MatchTimeline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchTimeline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchTimeline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchTimeline value)  $default,){
final _that = this;
switch (_that) {
case _MatchTimeline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchTimeline value)?  $default,){
final _that = this;
switch (_that) {
case _MatchTimeline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String matchId,  int duration,  List<TimelineEvent> events)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchTimeline() when $default != null:
return $default(_that.id,_that.matchId,_that.duration,_that.events);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String matchId,  int duration,  List<TimelineEvent> events)  $default,) {final _that = this;
switch (_that) {
case _MatchTimeline():
return $default(_that.id,_that.matchId,_that.duration,_that.events);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String matchId,  int duration,  List<TimelineEvent> events)?  $default,) {final _that = this;
switch (_that) {
case _MatchTimeline() when $default != null:
return $default(_that.id,_that.matchId,_that.duration,_that.events);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchTimeline implements MatchTimeline {
  const _MatchTimeline({required this.id, required this.matchId, this.duration = 90, final  List<TimelineEvent> events = const []}): _events = events;
  factory _MatchTimeline.fromJson(Map<String, dynamic> json) => _$MatchTimelineFromJson(json);

@override final  String id;
@override final  String matchId;
@override@JsonKey() final  int duration;
 final  List<TimelineEvent> _events;
@override@JsonKey() List<TimelineEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}


/// Create a copy of MatchTimeline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchTimelineCopyWith<_MatchTimeline> get copyWith => __$MatchTimelineCopyWithImpl<_MatchTimeline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchTimelineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchTimeline&&(identical(other.id, id) || other.id == id)&&(identical(other.matchId, matchId) || other.matchId == matchId)&&(identical(other.duration, duration) || other.duration == duration)&&const DeepCollectionEquality().equals(other._events, _events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,matchId,duration,const DeepCollectionEquality().hash(_events));

@override
String toString() {
  return 'MatchTimeline(id: $id, matchId: $matchId, duration: $duration, events: $events)';
}


}

/// @nodoc
abstract mixin class _$MatchTimelineCopyWith<$Res> implements $MatchTimelineCopyWith<$Res> {
  factory _$MatchTimelineCopyWith(_MatchTimeline value, $Res Function(_MatchTimeline) _then) = __$MatchTimelineCopyWithImpl;
@override @useResult
$Res call({
 String id, String matchId, int duration, List<TimelineEvent> events
});




}
/// @nodoc
class __$MatchTimelineCopyWithImpl<$Res>
    implements _$MatchTimelineCopyWith<$Res> {
  __$MatchTimelineCopyWithImpl(this._self, this._then);

  final _MatchTimeline _self;
  final $Res Function(_MatchTimeline) _then;

/// Create a copy of MatchTimeline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? matchId = null,Object? duration = null,Object? events = null,}) {
  return _then(_MatchTimeline(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,matchId: null == matchId ? _self.matchId : matchId // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<TimelineEvent>,
  ));
}


}

// dart format on
