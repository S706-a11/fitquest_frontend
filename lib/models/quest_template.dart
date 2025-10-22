import 'dart:convert';
import 'package:flutter/material.dart';

class QuestTemplate {
  final int id;
  final String title;
  final String description;
  final String category; // General, Strength, Cardio, Flexibility, etc.
  final String difficulty; // Beginner, Intermediate, Advanced, Expert, Master
  final int minLevel;
  final int maxLevel;
  final int xpReward;
  final int durationDays;
  final Map<String, dynamic>? targetMetrics;

  QuestTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.minLevel,
    required this.maxLevel,
    required this.xpReward,
    required this.durationDays,
    this.targetMetrics,
  });

  factory QuestTemplate.fromJson(Map<String, dynamic> json) {
    // Parse targetMetrics - it might be a JSON string or already a Map
    Map<String, dynamic>? parsedMetrics;
    if (json['targetMetrics'] != null) {
      if (json['targetMetrics'] is String) {
        // If it's a string, parse it as JSON
        try {
          parsedMetrics = jsonDecode(json['targetMetrics']) as Map<String, dynamic>;
        } catch (e) {
          print('Error parsing targetMetrics: $e');
          parsedMetrics = null;
        }
      } else if (json['targetMetrics'] is Map) {
        // If it's already a Map, use it directly
        parsedMetrics = json['targetMetrics'] as Map<String, dynamic>;
      }
    }

    return QuestTemplate(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      minLevel: json['minLevel'] as int? ?? 1,
      maxLevel: json['maxLevel'] as int? ?? 100,
      xpReward: json['xpReward'] as int? ?? 0,
      durationDays: json['durationDays'] as int? ?? 7,
      targetMetrics: parsedMetrics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'minLevel': minLevel,
      'maxLevel': maxLevel,
      'xpReward': xpReward,
      'durationDays': durationDays,
      'targetMetrics': targetMetrics,
    };
  }

  // Helper to get difficulty color
  Color getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50); // Green
      case 'intermediate':
        return const Color(0xFF2196F3); // Blue
      case 'advanced':
        return const Color(0xFFFF9800); // Orange
      case 'expert':
        return const Color(0xFFE91E63); // Pink
      case 'master':
        return const Color(0xFF9C27B0); // Purple
      default:
        return const Color(0xFF757575); // Grey
    }
  }
}
