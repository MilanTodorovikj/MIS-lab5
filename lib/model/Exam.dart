import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Exam {
  String subject;
  DateTime date;
  GeoPoint location;

  Exam({
    required this.subject,
    required this.date,
    required this.location,
  });

  // Add a named constructor for creating an Exam from a Map
  factory Exam.fromMap(Map<String, dynamic>? map) {
    if (map == null ||
        map['subject'] == null ||
        map['date'] == null ||
        map['location'] == null) {
      // Handle null values or missing keys, return a default Exam object or throw an error
      return Exam(
        subject: 'Default Subject',
        date: DateTime.now(),
        location: GeoPoint(0.0, 0.0),
      );
    }

    return Exam(
      subject: map['subject'] as String,
      date: (map['date'] as Timestamp).toDate(),
      location: map['location'] as GeoPoint,
    );
  }

  // Convert Exam object to a Map
  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'date': date,
      'location': location,
    };
  }
}