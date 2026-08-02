import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RandomTask extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isDone;
  final bool isLocked; // 🔒 هل تم اختيار الحالة وأُقفلت نهائياً؟

  const RandomTask({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.isDone,
    this.isLocked = false,
  });

  RandomTask copyWith({
    String? title,
    String? description,
    DateTime? date,
    bool? isDone,
    bool? isLocked,
  }) {
    return RandomTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Color get color {
    const palette = [
      Color(0xFF6B4EE6), Color(0xFF0F9D55), Color(0xFF2E7D9A),
      Color(0xFFE05C5C), Color(0xFF7B4EA6), Color(0xFF0F6E56),
      Color(0xFFEF9F27), Color(0xFF185FA5), Color(0xFF993C1D),
    ];
    final hash = title.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return palette[hash % palette.length];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'is_done': isDone,
    'is_locked': isLocked,
  };

  factory RandomTask.fromJson(Map<String, dynamic> json) => RandomTask(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description']?.toString() ?? '',
    date: DateTime.parse(json['date'] as String),
    isDone: json['is_done'] as bool? ?? false,
    isLocked: json['is_locked'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [id, title, description, date, isDone, isLocked];
}