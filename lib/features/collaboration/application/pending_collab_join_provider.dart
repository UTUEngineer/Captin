import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set when the app opens a `captain://collab/<code>` deep link.
final pendingCollabJoinCodeProvider = StateProvider<String?>((ref) => null);
