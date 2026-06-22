// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analysis_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackPosition {

 double get x; double get y; double get timestampSeconds; int? get frame;
/// Create a copy of TrackPosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackPositionCopyWith<TrackPosition> get copyWith => _$TrackPositionCopyWithImpl<TrackPosition>(this as TrackPosition, _$identity);

  /// Serializes this TrackPosition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackPosition&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.timestampSeconds, timestampSeconds) || other.timestampSeconds == timestampSeconds)&&(identical(other.frame, frame) || other.frame == frame));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,timestampSeconds,frame);

@override
String toString() {
  return 'TrackPosition(x: $x, y: $y, timestampSeconds: $timestampSeconds, frame: $frame)';
}


}

/// @nodoc
abstract mixin class $TrackPositionCopyWith<$Res>  {
  factory $TrackPositionCopyWith(TrackPosition value, $Res Function(TrackPosition) _then) = _$TrackPositionCopyWithImpl;
@useResult
$Res call({
 double x, double y, double timestampSeconds, int? frame
});




}
/// @nodoc
class _$TrackPositionCopyWithImpl<$Res>
    implements $TrackPositionCopyWith<$Res> {
  _$TrackPositionCopyWithImpl(this._self, this._then);

  final TrackPosition _self;
  final $Res Function(TrackPosition) _then;

/// Create a copy of TrackPosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,Object? timestampSeconds = null,Object? frame = freezed,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,timestampSeconds: null == timestampSeconds ? _self.timestampSeconds : timestampSeconds // ignore: cast_nullable_to_non_nullable
as double,frame: freezed == frame ? _self.frame : frame // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackPosition].
extension TrackPositionPatterns on TrackPosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackPosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackPosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackPosition value)  $default,){
final _that = this;
switch (_that) {
case _TrackPosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackPosition value)?  $default,){
final _that = this;
switch (_that) {
case _TrackPosition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y,  double timestampSeconds,  int? frame)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackPosition() when $default != null:
return $default(_that.x,_that.y,_that.timestampSeconds,_that.frame);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y,  double timestampSeconds,  int? frame)  $default,) {final _that = this;
switch (_that) {
case _TrackPosition():
return $default(_that.x,_that.y,_that.timestampSeconds,_that.frame);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y,  double timestampSeconds,  int? frame)?  $default,) {final _that = this;
switch (_that) {
case _TrackPosition() when $default != null:
return $default(_that.x,_that.y,_that.timestampSeconds,_that.frame);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _TrackPosition implements TrackPosition {
  const _TrackPosition({required this.x, required this.y, required this.timestampSeconds, this.frame});
  factory _TrackPosition.fromJson(Map<String, dynamic> json) => _$TrackPositionFromJson(json);

@override final  double x;
@override final  double y;
@override final  double timestampSeconds;
@override final  int? frame;

/// Create a copy of TrackPosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackPositionCopyWith<_TrackPosition> get copyWith => __$TrackPositionCopyWithImpl<_TrackPosition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackPositionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackPosition&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.timestampSeconds, timestampSeconds) || other.timestampSeconds == timestampSeconds)&&(identical(other.frame, frame) || other.frame == frame));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,timestampSeconds,frame);

@override
String toString() {
  return 'TrackPosition(x: $x, y: $y, timestampSeconds: $timestampSeconds, frame: $frame)';
}


}

/// @nodoc
abstract mixin class _$TrackPositionCopyWith<$Res> implements $TrackPositionCopyWith<$Res> {
  factory _$TrackPositionCopyWith(_TrackPosition value, $Res Function(_TrackPosition) _then) = __$TrackPositionCopyWithImpl;
@override @useResult
$Res call({
 double x, double y, double timestampSeconds, int? frame
});




}
/// @nodoc
class __$TrackPositionCopyWithImpl<$Res>
    implements _$TrackPositionCopyWith<$Res> {
  __$TrackPositionCopyWithImpl(this._self, this._then);

  final _TrackPosition _self;
  final $Res Function(_TrackPosition) _then;

/// Create a copy of TrackPosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,Object? timestampSeconds = null,Object? frame = freezed,}) {
  return _then(_TrackPosition(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,timestampSeconds: null == timestampSeconds ? _self.timestampSeconds : timestampSeconds // ignore: cast_nullable_to_non_nullable
as double,frame: freezed == frame ? _self.frame : frame // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$VideoTrack {

 int get trackId; List<TrackPosition> get positions;
/// Create a copy of VideoTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoTrackCopyWith<VideoTrack> get copyWith => _$VideoTrackCopyWithImpl<VideoTrack>(this as VideoTrack, _$identity);

  /// Serializes this VideoTrack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoTrack&&(identical(other.trackId, trackId) || other.trackId == trackId)&&const DeepCollectionEquality().equals(other.positions, positions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,const DeepCollectionEquality().hash(positions));

@override
String toString() {
  return 'VideoTrack(trackId: $trackId, positions: $positions)';
}


}

/// @nodoc
abstract mixin class $VideoTrackCopyWith<$Res>  {
  factory $VideoTrackCopyWith(VideoTrack value, $Res Function(VideoTrack) _then) = _$VideoTrackCopyWithImpl;
@useResult
$Res call({
 int trackId, List<TrackPosition> positions
});




}
/// @nodoc
class _$VideoTrackCopyWithImpl<$Res>
    implements $VideoTrackCopyWith<$Res> {
  _$VideoTrackCopyWithImpl(this._self, this._then);

  final VideoTrack _self;
  final $Res Function(VideoTrack) _then;

/// Create a copy of VideoTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trackId = null,Object? positions = null,}) {
  return _then(_self.copyWith(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as int,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as List<TrackPosition>,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoTrack].
extension VideoTrackPatterns on VideoTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoTrack value)  $default,){
final _that = this;
switch (_that) {
case _VideoTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoTrack value)?  $default,){
final _that = this;
switch (_that) {
case _VideoTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int trackId,  List<TrackPosition> positions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoTrack() when $default != null:
return $default(_that.trackId,_that.positions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int trackId,  List<TrackPosition> positions)  $default,) {final _that = this;
switch (_that) {
case _VideoTrack():
return $default(_that.trackId,_that.positions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int trackId,  List<TrackPosition> positions)?  $default,) {final _that = this;
switch (_that) {
case _VideoTrack() when $default != null:
return $default(_that.trackId,_that.positions);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _VideoTrack implements VideoTrack {
  const _VideoTrack({required this.trackId, required final  List<TrackPosition> positions}): _positions = positions;
  factory _VideoTrack.fromJson(Map<String, dynamic> json) => _$VideoTrackFromJson(json);

@override final  int trackId;
 final  List<TrackPosition> _positions;
@override List<TrackPosition> get positions {
  if (_positions is EqualUnmodifiableListView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positions);
}


/// Create a copy of VideoTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoTrackCopyWith<_VideoTrack> get copyWith => __$VideoTrackCopyWithImpl<_VideoTrack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoTrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoTrack&&(identical(other.trackId, trackId) || other.trackId == trackId)&&const DeepCollectionEquality().equals(other._positions, _positions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,const DeepCollectionEquality().hash(_positions));

@override
String toString() {
  return 'VideoTrack(trackId: $trackId, positions: $positions)';
}


}

/// @nodoc
abstract mixin class _$VideoTrackCopyWith<$Res> implements $VideoTrackCopyWith<$Res> {
  factory _$VideoTrackCopyWith(_VideoTrack value, $Res Function(_VideoTrack) _then) = __$VideoTrackCopyWithImpl;
@override @useResult
$Res call({
 int trackId, List<TrackPosition> positions
});




}
/// @nodoc
class __$VideoTrackCopyWithImpl<$Res>
    implements _$VideoTrackCopyWith<$Res> {
  __$VideoTrackCopyWithImpl(this._self, this._then);

  final _VideoTrack _self;
  final $Res Function(_VideoTrack) _then;

/// Create a copy of VideoTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trackId = null,Object? positions = null,}) {
  return _then(_VideoTrack(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as int,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as List<TrackPosition>,
  ));
}


}


/// @nodoc
mixin _$PlayerAnalytics {

 int get trackId; double get distanceKm; int get sprintCount; double get maxSpeedKmh; List<List<double>> get heatmap;
/// Create a copy of PlayerAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerAnalyticsCopyWith<PlayerAnalytics> get copyWith => _$PlayerAnalyticsCopyWithImpl<PlayerAnalytics>(this as PlayerAnalytics, _$identity);

  /// Serializes this PlayerAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerAnalytics&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.sprintCount, sprintCount) || other.sprintCount == sprintCount)&&(identical(other.maxSpeedKmh, maxSpeedKmh) || other.maxSpeedKmh == maxSpeedKmh)&&const DeepCollectionEquality().equals(other.heatmap, heatmap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,distanceKm,sprintCount,maxSpeedKmh,const DeepCollectionEquality().hash(heatmap));

@override
String toString() {
  return 'PlayerAnalytics(trackId: $trackId, distanceKm: $distanceKm, sprintCount: $sprintCount, maxSpeedKmh: $maxSpeedKmh, heatmap: $heatmap)';
}


}

/// @nodoc
abstract mixin class $PlayerAnalyticsCopyWith<$Res>  {
  factory $PlayerAnalyticsCopyWith(PlayerAnalytics value, $Res Function(PlayerAnalytics) _then) = _$PlayerAnalyticsCopyWithImpl;
@useResult
$Res call({
 int trackId, double distanceKm, int sprintCount, double maxSpeedKmh, List<List<double>> heatmap
});




}
/// @nodoc
class _$PlayerAnalyticsCopyWithImpl<$Res>
    implements $PlayerAnalyticsCopyWith<$Res> {
  _$PlayerAnalyticsCopyWithImpl(this._self, this._then);

  final PlayerAnalytics _self;
  final $Res Function(PlayerAnalytics) _then;

/// Create a copy of PlayerAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trackId = null,Object? distanceKm = null,Object? sprintCount = null,Object? maxSpeedKmh = null,Object? heatmap = null,}) {
  return _then(_self.copyWith(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as int,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,sprintCount: null == sprintCount ? _self.sprintCount : sprintCount // ignore: cast_nullable_to_non_nullable
as int,maxSpeedKmh: null == maxSpeedKmh ? _self.maxSpeedKmh : maxSpeedKmh // ignore: cast_nullable_to_non_nullable
as double,heatmap: null == heatmap ? _self.heatmap : heatmap // ignore: cast_nullable_to_non_nullable
as List<List<double>>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerAnalytics].
extension PlayerAnalyticsPatterns on PlayerAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _PlayerAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int trackId,  double distanceKm,  int sprintCount,  double maxSpeedKmh,  List<List<double>> heatmap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerAnalytics() when $default != null:
return $default(_that.trackId,_that.distanceKm,_that.sprintCount,_that.maxSpeedKmh,_that.heatmap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int trackId,  double distanceKm,  int sprintCount,  double maxSpeedKmh,  List<List<double>> heatmap)  $default,) {final _that = this;
switch (_that) {
case _PlayerAnalytics():
return $default(_that.trackId,_that.distanceKm,_that.sprintCount,_that.maxSpeedKmh,_that.heatmap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int trackId,  double distanceKm,  int sprintCount,  double maxSpeedKmh,  List<List<double>> heatmap)?  $default,) {final _that = this;
switch (_that) {
case _PlayerAnalytics() when $default != null:
return $default(_that.trackId,_that.distanceKm,_that.sprintCount,_that.maxSpeedKmh,_that.heatmap);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _PlayerAnalytics implements PlayerAnalytics {
  const _PlayerAnalytics({required this.trackId, required this.distanceKm, required this.sprintCount, required this.maxSpeedKmh, required final  List<List<double>> heatmap}): _heatmap = heatmap;
  factory _PlayerAnalytics.fromJson(Map<String, dynamic> json) => _$PlayerAnalyticsFromJson(json);

@override final  int trackId;
@override final  double distanceKm;
@override final  int sprintCount;
@override final  double maxSpeedKmh;
 final  List<List<double>> _heatmap;
@override List<List<double>> get heatmap {
  if (_heatmap is EqualUnmodifiableListView) return _heatmap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_heatmap);
}


/// Create a copy of PlayerAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerAnalyticsCopyWith<_PlayerAnalytics> get copyWith => __$PlayerAnalyticsCopyWithImpl<_PlayerAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerAnalytics&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.sprintCount, sprintCount) || other.sprintCount == sprintCount)&&(identical(other.maxSpeedKmh, maxSpeedKmh) || other.maxSpeedKmh == maxSpeedKmh)&&const DeepCollectionEquality().equals(other._heatmap, _heatmap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,distanceKm,sprintCount,maxSpeedKmh,const DeepCollectionEquality().hash(_heatmap));

@override
String toString() {
  return 'PlayerAnalytics(trackId: $trackId, distanceKm: $distanceKm, sprintCount: $sprintCount, maxSpeedKmh: $maxSpeedKmh, heatmap: $heatmap)';
}


}

/// @nodoc
abstract mixin class _$PlayerAnalyticsCopyWith<$Res> implements $PlayerAnalyticsCopyWith<$Res> {
  factory _$PlayerAnalyticsCopyWith(_PlayerAnalytics value, $Res Function(_PlayerAnalytics) _then) = __$PlayerAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 int trackId, double distanceKm, int sprintCount, double maxSpeedKmh, List<List<double>> heatmap
});




}
/// @nodoc
class __$PlayerAnalyticsCopyWithImpl<$Res>
    implements _$PlayerAnalyticsCopyWith<$Res> {
  __$PlayerAnalyticsCopyWithImpl(this._self, this._then);

  final _PlayerAnalytics _self;
  final $Res Function(_PlayerAnalytics) _then;

/// Create a copy of PlayerAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trackId = null,Object? distanceKm = null,Object? sprintCount = null,Object? maxSpeedKmh = null,Object? heatmap = null,}) {
  return _then(_PlayerAnalytics(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as int,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,sprintCount: null == sprintCount ? _self.sprintCount : sprintCount // ignore: cast_nullable_to_non_nullable
as int,maxSpeedKmh: null == maxSpeedKmh ? _self.maxSpeedKmh : maxSpeedKmh // ignore: cast_nullable_to_non_nullable
as double,heatmap: null == heatmap ? _self._heatmap : heatmap // ignore: cast_nullable_to_non_nullable
as List<List<double>>,
  ));
}


}


/// @nodoc
mixin _$TeamPossessionZones {

 double get defensive; double get middle; double get attacking;
/// Create a copy of TeamPossessionZones
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamPossessionZonesCopyWith<TeamPossessionZones> get copyWith => _$TeamPossessionZonesCopyWithImpl<TeamPossessionZones>(this as TeamPossessionZones, _$identity);

  /// Serializes this TeamPossessionZones to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamPossessionZones&&(identical(other.defensive, defensive) || other.defensive == defensive)&&(identical(other.middle, middle) || other.middle == middle)&&(identical(other.attacking, attacking) || other.attacking == attacking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defensive,middle,attacking);

@override
String toString() {
  return 'TeamPossessionZones(defensive: $defensive, middle: $middle, attacking: $attacking)';
}


}

/// @nodoc
abstract mixin class $TeamPossessionZonesCopyWith<$Res>  {
  factory $TeamPossessionZonesCopyWith(TeamPossessionZones value, $Res Function(TeamPossessionZones) _then) = _$TeamPossessionZonesCopyWithImpl;
@useResult
$Res call({
 double defensive, double middle, double attacking
});




}
/// @nodoc
class _$TeamPossessionZonesCopyWithImpl<$Res>
    implements $TeamPossessionZonesCopyWith<$Res> {
  _$TeamPossessionZonesCopyWithImpl(this._self, this._then);

  final TeamPossessionZones _self;
  final $Res Function(TeamPossessionZones) _then;

/// Create a copy of TeamPossessionZones
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defensive = null,Object? middle = null,Object? attacking = null,}) {
  return _then(_self.copyWith(
defensive: null == defensive ? _self.defensive : defensive // ignore: cast_nullable_to_non_nullable
as double,middle: null == middle ? _self.middle : middle // ignore: cast_nullable_to_non_nullable
as double,attacking: null == attacking ? _self.attacking : attacking // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamPossessionZones].
extension TeamPossessionZonesPatterns on TeamPossessionZones {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamPossessionZones value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamPossessionZones() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamPossessionZones value)  $default,){
final _that = this;
switch (_that) {
case _TeamPossessionZones():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamPossessionZones value)?  $default,){
final _that = this;
switch (_that) {
case _TeamPossessionZones() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double defensive,  double middle,  double attacking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamPossessionZones() when $default != null:
return $default(_that.defensive,_that.middle,_that.attacking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double defensive,  double middle,  double attacking)  $default,) {final _that = this;
switch (_that) {
case _TeamPossessionZones():
return $default(_that.defensive,_that.middle,_that.attacking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double defensive,  double middle,  double attacking)?  $default,) {final _that = this;
switch (_that) {
case _TeamPossessionZones() when $default != null:
return $default(_that.defensive,_that.middle,_that.attacking);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamPossessionZones implements TeamPossessionZones {
  const _TeamPossessionZones({required this.defensive, required this.middle, required this.attacking});
  factory _TeamPossessionZones.fromJson(Map<String, dynamic> json) => _$TeamPossessionZonesFromJson(json);

@override final  double defensive;
@override final  double middle;
@override final  double attacking;

/// Create a copy of TeamPossessionZones
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamPossessionZonesCopyWith<_TeamPossessionZones> get copyWith => __$TeamPossessionZonesCopyWithImpl<_TeamPossessionZones>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamPossessionZonesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamPossessionZones&&(identical(other.defensive, defensive) || other.defensive == defensive)&&(identical(other.middle, middle) || other.middle == middle)&&(identical(other.attacking, attacking) || other.attacking == attacking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defensive,middle,attacking);

@override
String toString() {
  return 'TeamPossessionZones(defensive: $defensive, middle: $middle, attacking: $attacking)';
}


}

/// @nodoc
abstract mixin class _$TeamPossessionZonesCopyWith<$Res> implements $TeamPossessionZonesCopyWith<$Res> {
  factory _$TeamPossessionZonesCopyWith(_TeamPossessionZones value, $Res Function(_TeamPossessionZones) _then) = __$TeamPossessionZonesCopyWithImpl;
@override @useResult
$Res call({
 double defensive, double middle, double attacking
});




}
/// @nodoc
class __$TeamPossessionZonesCopyWithImpl<$Res>
    implements _$TeamPossessionZonesCopyWith<$Res> {
  __$TeamPossessionZonesCopyWithImpl(this._self, this._then);

  final _TeamPossessionZones _self;
  final $Res Function(_TeamPossessionZones) _then;

/// Create a copy of TeamPossessionZones
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defensive = null,Object? middle = null,Object? attacking = null,}) {
  return _then(_TeamPossessionZones(
defensive: null == defensive ? _self.defensive : defensive // ignore: cast_nullable_to_non_nullable
as double,middle: null == middle ? _self.middle : middle // ignore: cast_nullable_to_non_nullable
as double,attacking: null == attacking ? _self.attacking : attacking // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PossessionZones {

 TeamPossessionZones? get teamA; TeamPossessionZones? get teamB;
/// Create a copy of PossessionZones
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PossessionZonesCopyWith<PossessionZones> get copyWith => _$PossessionZonesCopyWithImpl<PossessionZones>(this as PossessionZones, _$identity);

  /// Serializes this PossessionZones to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PossessionZones&&(identical(other.teamA, teamA) || other.teamA == teamA)&&(identical(other.teamB, teamB) || other.teamB == teamB));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamA,teamB);

@override
String toString() {
  return 'PossessionZones(teamA: $teamA, teamB: $teamB)';
}


}

/// @nodoc
abstract mixin class $PossessionZonesCopyWith<$Res>  {
  factory $PossessionZonesCopyWith(PossessionZones value, $Res Function(PossessionZones) _then) = _$PossessionZonesCopyWithImpl;
@useResult
$Res call({
 TeamPossessionZones? teamA, TeamPossessionZones? teamB
});


$TeamPossessionZonesCopyWith<$Res>? get teamA;$TeamPossessionZonesCopyWith<$Res>? get teamB;

}
/// @nodoc
class _$PossessionZonesCopyWithImpl<$Res>
    implements $PossessionZonesCopyWith<$Res> {
  _$PossessionZonesCopyWithImpl(this._self, this._then);

  final PossessionZones _self;
  final $Res Function(PossessionZones) _then;

/// Create a copy of PossessionZones
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamA = freezed,Object? teamB = freezed,}) {
  return _then(_self.copyWith(
teamA: freezed == teamA ? _self.teamA : teamA // ignore: cast_nullable_to_non_nullable
as TeamPossessionZones?,teamB: freezed == teamB ? _self.teamB : teamB // ignore: cast_nullable_to_non_nullable
as TeamPossessionZones?,
  ));
}
/// Create a copy of PossessionZones
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamPossessionZonesCopyWith<$Res>? get teamA {
    if (_self.teamA == null) {
    return null;
  }

  return $TeamPossessionZonesCopyWith<$Res>(_self.teamA!, (value) {
    return _then(_self.copyWith(teamA: value));
  });
}/// Create a copy of PossessionZones
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamPossessionZonesCopyWith<$Res>? get teamB {
    if (_self.teamB == null) {
    return null;
  }

  return $TeamPossessionZonesCopyWith<$Res>(_self.teamB!, (value) {
    return _then(_self.copyWith(teamB: value));
  });
}
}


/// Adds pattern-matching-related methods to [PossessionZones].
extension PossessionZonesPatterns on PossessionZones {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PossessionZones value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PossessionZones() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PossessionZones value)  $default,){
final _that = this;
switch (_that) {
case _PossessionZones():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PossessionZones value)?  $default,){
final _that = this;
switch (_that) {
case _PossessionZones() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TeamPossessionZones? teamA,  TeamPossessionZones? teamB)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PossessionZones() when $default != null:
return $default(_that.teamA,_that.teamB);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TeamPossessionZones? teamA,  TeamPossessionZones? teamB)  $default,) {final _that = this;
switch (_that) {
case _PossessionZones():
return $default(_that.teamA,_that.teamB);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TeamPossessionZones? teamA,  TeamPossessionZones? teamB)?  $default,) {final _that = this;
switch (_that) {
case _PossessionZones() when $default != null:
return $default(_that.teamA,_that.teamB);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _PossessionZones implements PossessionZones {
  const _PossessionZones({this.teamA, this.teamB});
  factory _PossessionZones.fromJson(Map<String, dynamic> json) => _$PossessionZonesFromJson(json);

@override final  TeamPossessionZones? teamA;
@override final  TeamPossessionZones? teamB;

/// Create a copy of PossessionZones
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PossessionZonesCopyWith<_PossessionZones> get copyWith => __$PossessionZonesCopyWithImpl<_PossessionZones>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PossessionZonesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PossessionZones&&(identical(other.teamA, teamA) || other.teamA == teamA)&&(identical(other.teamB, teamB) || other.teamB == teamB));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamA,teamB);

@override
String toString() {
  return 'PossessionZones(teamA: $teamA, teamB: $teamB)';
}


}

/// @nodoc
abstract mixin class _$PossessionZonesCopyWith<$Res> implements $PossessionZonesCopyWith<$Res> {
  factory _$PossessionZonesCopyWith(_PossessionZones value, $Res Function(_PossessionZones) _then) = __$PossessionZonesCopyWithImpl;
@override @useResult
$Res call({
 TeamPossessionZones? teamA, TeamPossessionZones? teamB
});


@override $TeamPossessionZonesCopyWith<$Res>? get teamA;@override $TeamPossessionZonesCopyWith<$Res>? get teamB;

}
/// @nodoc
class __$PossessionZonesCopyWithImpl<$Res>
    implements _$PossessionZonesCopyWith<$Res> {
  __$PossessionZonesCopyWithImpl(this._self, this._then);

  final _PossessionZones _self;
  final $Res Function(_PossessionZones) _then;

/// Create a copy of PossessionZones
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamA = freezed,Object? teamB = freezed,}) {
  return _then(_PossessionZones(
teamA: freezed == teamA ? _self.teamA : teamA // ignore: cast_nullable_to_non_nullable
as TeamPossessionZones?,teamB: freezed == teamB ? _self.teamB : teamB // ignore: cast_nullable_to_non_nullable
as TeamPossessionZones?,
  ));
}

/// Create a copy of PossessionZones
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamPossessionZonesCopyWith<$Res>? get teamA {
    if (_self.teamA == null) {
    return null;
  }

  return $TeamPossessionZonesCopyWith<$Res>(_self.teamA!, (value) {
    return _then(_self.copyWith(teamA: value));
  });
}/// Create a copy of PossessionZones
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamPossessionZonesCopyWith<$Res>? get teamB {
    if (_self.teamB == null) {
    return null;
  }

  return $TeamPossessionZonesCopyWith<$Res>(_self.teamB!, (value) {
    return _then(_self.copyWith(teamB: value));
  });
}
}


/// @nodoc
mixin _$AnalysisResult {

 String get videoId; double get durationSeconds; List<VideoTrack> get tracks; List<PlayerAnalytics> get players; PossessionZones? get possessionZones;
/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisResultCopyWith<AnalysisResult> get copyWith => _$AnalysisResultCopyWithImpl<AnalysisResult>(this as AnalysisResult, _$identity);

  /// Serializes this AnalysisResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalysisResult&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other.tracks, tracks)&&const DeepCollectionEquality().equals(other.players, players)&&(identical(other.possessionZones, possessionZones) || other.possessionZones == possessionZones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,durationSeconds,const DeepCollectionEquality().hash(tracks),const DeepCollectionEquality().hash(players),possessionZones);

@override
String toString() {
  return 'AnalysisResult(videoId: $videoId, durationSeconds: $durationSeconds, tracks: $tracks, players: $players, possessionZones: $possessionZones)';
}


}

/// @nodoc
abstract mixin class $AnalysisResultCopyWith<$Res>  {
  factory $AnalysisResultCopyWith(AnalysisResult value, $Res Function(AnalysisResult) _then) = _$AnalysisResultCopyWithImpl;
@useResult
$Res call({
 String videoId, double durationSeconds, List<VideoTrack> tracks, List<PlayerAnalytics> players, PossessionZones? possessionZones
});


$PossessionZonesCopyWith<$Res>? get possessionZones;

}
/// @nodoc
class _$AnalysisResultCopyWithImpl<$Res>
    implements $AnalysisResultCopyWith<$Res> {
  _$AnalysisResultCopyWithImpl(this._self, this._then);

  final AnalysisResult _self;
  final $Res Function(AnalysisResult) _then;

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoId = null,Object? durationSeconds = null,Object? tracks = null,Object? players = null,Object? possessionZones = freezed,}) {
  return _then(_self.copyWith(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<VideoTrack>,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<PlayerAnalytics>,possessionZones: freezed == possessionZones ? _self.possessionZones : possessionZones // ignore: cast_nullable_to_non_nullable
as PossessionZones?,
  ));
}
/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PossessionZonesCopyWith<$Res>? get possessionZones {
    if (_self.possessionZones == null) {
    return null;
  }

  return $PossessionZonesCopyWith<$Res>(_self.possessionZones!, (value) {
    return _then(_self.copyWith(possessionZones: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalysisResult].
extension AnalysisResultPatterns on AnalysisResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalysisResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalysisResult value)  $default,){
final _that = this;
switch (_that) {
case _AnalysisResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalysisResult value)?  $default,){
final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String videoId,  double durationSeconds,  List<VideoTrack> tracks,  List<PlayerAnalytics> players,  PossessionZones? possessionZones)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that.videoId,_that.durationSeconds,_that.tracks,_that.players,_that.possessionZones);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String videoId,  double durationSeconds,  List<VideoTrack> tracks,  List<PlayerAnalytics> players,  PossessionZones? possessionZones)  $default,) {final _that = this;
switch (_that) {
case _AnalysisResult():
return $default(_that.videoId,_that.durationSeconds,_that.tracks,_that.players,_that.possessionZones);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String videoId,  double durationSeconds,  List<VideoTrack> tracks,  List<PlayerAnalytics> players,  PossessionZones? possessionZones)?  $default,) {final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that.videoId,_that.durationSeconds,_that.tracks,_that.players,_that.possessionZones);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _AnalysisResult implements AnalysisResult {
  const _AnalysisResult({required this.videoId, required this.durationSeconds, required final  List<VideoTrack> tracks, final  List<PlayerAnalytics> players = const [], this.possessionZones}): _tracks = tracks,_players = players;
  factory _AnalysisResult.fromJson(Map<String, dynamic> json) => _$AnalysisResultFromJson(json);

@override final  String videoId;
@override final  double durationSeconds;
 final  List<VideoTrack> _tracks;
@override List<VideoTrack> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

 final  List<PlayerAnalytics> _players;
@override@JsonKey() List<PlayerAnalytics> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

@override final  PossessionZones? possessionZones;

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisResultCopyWith<_AnalysisResult> get copyWith => __$AnalysisResultCopyWithImpl<_AnalysisResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalysisResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalysisResult&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&const DeepCollectionEquality().equals(other._players, _players)&&(identical(other.possessionZones, possessionZones) || other.possessionZones == possessionZones));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId,durationSeconds,const DeepCollectionEquality().hash(_tracks),const DeepCollectionEquality().hash(_players),possessionZones);

@override
String toString() {
  return 'AnalysisResult(videoId: $videoId, durationSeconds: $durationSeconds, tracks: $tracks, players: $players, possessionZones: $possessionZones)';
}


}

/// @nodoc
abstract mixin class _$AnalysisResultCopyWith<$Res> implements $AnalysisResultCopyWith<$Res> {
  factory _$AnalysisResultCopyWith(_AnalysisResult value, $Res Function(_AnalysisResult) _then) = __$AnalysisResultCopyWithImpl;
@override @useResult
$Res call({
 String videoId, double durationSeconds, List<VideoTrack> tracks, List<PlayerAnalytics> players, PossessionZones? possessionZones
});


@override $PossessionZonesCopyWith<$Res>? get possessionZones;

}
/// @nodoc
class __$AnalysisResultCopyWithImpl<$Res>
    implements _$AnalysisResultCopyWith<$Res> {
  __$AnalysisResultCopyWithImpl(this._self, this._then);

  final _AnalysisResult _self;
  final $Res Function(_AnalysisResult) _then;

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoId = null,Object? durationSeconds = null,Object? tracks = null,Object? players = null,Object? possessionZones = freezed,}) {
  return _then(_AnalysisResult(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as double,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<VideoTrack>,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<PlayerAnalytics>,possessionZones: freezed == possessionZones ? _self.possessionZones : possessionZones // ignore: cast_nullable_to_non_nullable
as PossessionZones?,
  ));
}

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PossessionZonesCopyWith<$Res>? get possessionZones {
    if (_self.possessionZones == null) {
    return null;
  }

  return $PossessionZonesCopyWith<$Res>(_self.possessionZones!, (value) {
    return _then(_self.copyWith(possessionZones: value));
  });
}
}

// dart format on
