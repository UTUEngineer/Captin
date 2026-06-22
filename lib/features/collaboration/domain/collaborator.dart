import 'dart:ui';

import 'package:flutter/material.dart';

enum CollaboratorRole {
  host,
  editor,
  viewer,
}

class Collaborator {
  const Collaborator({
    required this.id,
    required this.name,
    required this.color,
    this.cursorPosition,
    this.role = CollaboratorRole.editor,
  });

  final String id;
  final String name;
  final Color color;
  final Offset? cursorPosition;
  final CollaboratorRole role;

  Collaborator copyWith({
    String? name,
    Color? color,
    Offset? cursorPosition,
    bool clearCursor = false,
    CollaboratorRole? role,
  }) {
    return Collaborator(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      cursorPosition: clearCursor ? null : (cursorPosition ?? this.cursorPosition),
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGB32(),
      'role': role.name,
      if (cursorPosition != null) ...{
        'cursorX': cursorPosition!.dx,
        'cursorY': cursorPosition!.dy,
      },
    };
  }

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    final cursorX = json['cursorX'];
    final cursorY = json['cursorY'];
    return Collaborator(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
      role: CollaboratorRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => CollaboratorRole.editor,
      ),
      cursorPosition: cursorX is num && cursorY is num
          ? Offset(cursorX.toDouble(), cursorY.toDouble())
          : null,
    );
  }
}

const collaboratorColorPalette = <Color>[
  Color(0xFF42A5F5),
  Color(0xFFFFEE58),
  Color(0xFFAB47BC),
  Color(0xFFFF7043),
  Color(0xFF26C6DA),
  Color(0xFFEC407A),
  Color(0xFF9CCC65),
  Color(0xFF7E57C2),
];

Color colorForCollaboratorId(String id) {
  final hash = id.codeUnits.fold<int>(0, (value, unit) => value + unit);
  return collaboratorColorPalette[hash % collaboratorColorPalette.length];
}
