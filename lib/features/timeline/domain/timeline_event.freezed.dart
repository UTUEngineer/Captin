// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimelineEvent {

 String get id; int get minute; int get second;@TimelineEventTypeConverter() TimelineEventType get type; String get description; String? get linkedTacticalBoardId; String? get teamId; String? get playerName;
/// Create a copy of TimelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineEventCopyWith<TimelineEvent> get copyWith => _$TimelineEventCopyWithImpl<TimelineEvent>(this as TimelineEvent, _$identity);

  /// Serializes this TimelineEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.second, second) || other.second == second)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.linkedTacticalBoardId, linkedTacticalBoardId) || other.linkedTacticalBoardId == linkedTacticalBoardId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerName, playerName) || other.playerName == playerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,minute,second,type,description,linkedTacticalBoardId,teamId,playerName);

@override
String toString() {
  return 'TimelineEvent(id: $id, minute: $minute, second: $second, type: $type, description: $description, linkedTacticalBoardId: $linkedTacticalBoardId, teamId: $teamId, playerName: $playerName)';
}


}

/// @nodoc
abstract mixin class $TimelineEventCopyWith<$Res>  {
  factory $TimelineEventCopyWith(TimelineEvent value, $Res Function(TimelineEvent) _then) = _$TimelineEventCopyWithImpl;
@useResult
$Res call({
 String id, int minute, int second,@TimelineEventTypeConverter() TimelineEventType type, String description, String? linkedTacticalBoardId, String? teamId, String? playerName
});




}
/// @nodoc
class _$TimelineEventCopyWithImpl<$Res>
    implements $TimelineEventCopyWith<$Res> {
  _$TimelineEventCopyWithImpl(this._self, this._then);

  final TimelineEvent _self;
  final $Res Function(TimelineEvent) _then;

/// Create a copy of TimelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? minute = null,Object? second = null,Object? type = null,Object? description = null,Object? linkedTacticalBoardId = freezed,Object? teamId = freezed,Object? playerName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,second: null == second ? _self.second : second // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TimelineEventType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,linkedTacticalBoardId: freezed == linkedTacticalBoardId ? _self.linkedTacticalBoardId : linkedTacticalBoardId // ignore: cast_nullable_to_non_nullable
as String?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,playerName: freezed == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineEvent].
extension TimelineEventPatterns on TimelineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineEvent value)  $default,){
final _that = this;
switch (_that) {
case _TimelineEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineEvent value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int minute,  int second, @TimelineEventTypeConverter()  TimelineEventType type,  String description,  String? linkedTacticalBoardId,  String? teamId,  String? playerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineEvent() when $default != null:
return $default(_that.id,_that.minute,_that.second,_that.type,_that.description,_that.linkedTacticalBoardId,_that.teamId,_that.playerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int minute,  int second, @TimelineEventTypeConverter()  TimelineEventType type,  String description,  String? linkedTacticalBoardId,  String? teamId,  String? playerName)  $default,) {final _that = this;
switch (_that) {
case _TimelineEvent():
return $default(_that.id,_that.minute,_that.second,_that.type,_that.description,_that.linkedTacticalBoardId,_that.teamId,_that.playerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int minute,  int second, @TimelineEventTypeConverter()  TimelineEventType type,  String description,  String? linkedTacticalBoardId,  String? teamId,  String? playerName)?  $default,) {final _that = this;
switch (_that) {
case _TimelineEvent() when $default != null:
return $default(_that.id,_that.minute,_that.second,_that.type,_that.description,_that.linkedTacticalBoardId,_that.teamId,_that.playerName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineEvent implements TimelineEvent {
  const _TimelineEvent({required this.id, required this.minute, this.second = 0, @TimelineEventTypeConverter() required this.type, this.description = '', this.linkedTacticalBoardId, this.teamId, this.playerName});
  factory _TimelineEvent.fromJson(Map<String, dynamic> json) => _$TimelineEventFromJson(json);

@override final  String id;
@override final  int minute;
@override@JsonKey() final  int second;
@override@TimelineEventTypeConverter() final  TimelineEventType type;
@override@JsonKey() final  String description;
@override final  String? linkedTacticalBoardId;
@override final  String? teamId;
@override final  String? playerName;

/// Create a copy of TimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineEventCopyWith<_TimelineEvent> get copyWith => __$TimelineEventCopyWithImpl<_TimelineEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.second, second) || other.second == second)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.linkedTacticalBoardId, linkedTacticalBoardId) || other.linkedTacticalBoardId == linkedTacticalBoardId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerName, playerName) || other.playerName == playerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,minute,second,type,description,linkedTacticalBoardId,teamId,playerName);

@override
String toString() {
  return 'TimelineEvent(id: $id, minute: $minute, second: $second, type: $type, description: $description, linkedTacticalBoardId: $linkedTacticalBoardId, teamId: $teamId, playerName: $playerName)';
}


}

/// @nodoc
abstract mixin class _$TimelineEventCopyWith<$Res> implements $TimelineEventCopyWith<$Res> {
  factory _$TimelineEventCopyWith(_TimelineEvent value, $Res Function(_TimelineEvent) _then) = __$TimelineEventCopyWithImpl;
@override @useResult
$Res call({
 String id, int minute, int second,@TimelineEventTypeConverter() TimelineEventType type, String description, String? linkedTacticalBoardId, String? teamId, String? playerName
});




}
/// @nodoc
class __$TimelineEventCopyWithImpl<$Res>
    implements _$TimelineEventCopyWith<$Res> {
  __$TimelineEventCopyWithImpl(this._self, this._then);

  final _TimelineEvent _self;
  final $Res Function(_TimelineEvent) _then;

/// Create a copy of TimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? minute = null,Object? second = null,Object? type = null,Object? description = null,Object? linkedTacticalBoardId = freezed,Object? teamId = freezed,Object? playerName = freezed,}) {
  return _then(_TimelineEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,second: null == second ? _self.second : second // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TimelineEventType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,linkedTacticalBoardId: freezed == linkedTacticalBoardId ? _self.linkedTacticalBoardId : linkedTacticalBoardId // ignore: cast_nullable_to_non_nullable
as String?,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String?,playerName: freezed == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
