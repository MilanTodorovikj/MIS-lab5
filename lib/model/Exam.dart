import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Exam {
  String subject;
  DateTime date;

  Exam({
    required this.subject,
    required this.date,
  });

  // Add a named constructor for creating an Exam from a Map
  factory Exam.fromMap(Map<String, dynamic>? map) {
    if (map == null || map['subject'] == null || map['date'] == null) {
      // Handle null values or missing keys, return a default Exam object or throw an error
      return Exam(subject: 'Default Subject', date: DateTime.now());
    }

    return Exam(
      subject: map['subject'] as String,
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}