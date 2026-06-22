// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'formation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Formation {

 FormationType get type; List<Player> get players;
/// Create a copy of Formation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FormationCopyWith<Formation> get copyWith => _$FormationCopyWithImpl<Formation>(this as Formation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Formation&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.players, players));
}


@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(players));

@override
String toString() {
  return 'Formation(type: $type, players: $players)';
}


}

/// @nodoc
abstract mixin class $FormationCopyWith<$Res>  {
  factory $FormationCopyWith(Formation value, $Res Function(Formation) _then) = _$FormationCopyWithImpl;
@useResult
$Res call({
 FormationType type, List<Player> players
});




}
/// @nodoc
class _$FormationCopyWithImpl<$Res>
    implements $FormationCopyWith<$Res> {
  _$FormationCopyWithImpl(this._self, this._then);

  final Formation _self;
  final $Res Function(Formation) _then;

/// Create a copy of Formation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? players = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FormationType,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,
  ));
}

}


/// Adds pattern-matching-related methods to [Formation].
extension FormationPatterns on Formation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Formation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Formation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Formation value)  $default,){
final _that = this;
switch (_that) {
case _Formation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Formation value)?  $default,){
final _that = this;
switch (_that) {
case _Formation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FormationType type,  List<Player> players)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Formation() when $default != null:
return $default(_that.type,_that.players);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FormationType type,  List<Player> players)  $default,) {final _that = this;
switch (_that) {
case _Formation():
return $default(_that.type,_that.players);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FormationType type,  List<Player> players)?  $default,) {final _that = this;
switch (_that) {
case _Formation() when $default != null:
return $default(_that.type,_that.players);case _:
  return null;

}
}

}

/// @nodoc


class _Formation implements Formation {
  const _Formation({required this.type, required final  List<Player> players}): _players = players;
  

@override final  FormationType type;
 final  List<Player> _players;
@override List<Player> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}


/// Create a copy of Formation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FormationCopyWith<_Formation> get copyWith => __$FormationCopyWithImpl<_Formation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Formation&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._players, _players));
}


@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_players));

@override
String toString() {
  return 'Formation(type: $type, players: $players)';
}


}

/// @nodoc
abstract mixin class _$FormationCopyWith<$Res> implements $FormationCopyWith<$Res> {
  factory _$FormationCopyWith(_Formation value, $Res Function(_Formation) _then) = __$FormationCopyWithImpl;
@override @useResult
$Res call({
 FormationType type, List<Player> players
});




}
/// @nodoc
class __$FormationCopyWithImpl<$Res>
    implements _$FormationCopyWith<$Res> {
  __$FormationCopyWithImpl(this._self, this._then);

  final _Formation _self;
  final $Res Function(_Formation) _then;

/// Create a copy of Formation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? players = null,}) {
  return _then(_Formation(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FormationType,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,
  ));
}


}

// dart format on
