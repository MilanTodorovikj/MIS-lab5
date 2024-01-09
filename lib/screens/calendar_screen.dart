import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/Exam.dart';
import '../widgets/auth_gate.dart';
import '../widgets/new_exam.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CollectionReference _itemsCollection =
  FirebaseFirestore.instance.collection('exams');
  List<Exam> _exams = [];
  Map<DateTime, List<dynamic>> _events = {};
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await _itemsCollection.where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).get() as QuerySnapshot<Map<String, dynamic>>;

    _exams = querySnapshot.docs
        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
      return Exam.fromMap(doc.data()!);
    })
        .toList();

    print('Loaded exams: $_exams');
    _updateEvents(); // Call _updateEvents to update the _events map
  }

  void _updateEvents() {
    _events = {};
    for (Exam exam in _exams) {
      DateTime examDate =
      DateTime(exam.date.year, exam.date.month, exam.date.day, 0, 0, 0);
      if (_events.containsKey(examDate)) {
        _events[examDate]!.add(exam);
      } else {
        _events[examDate] = [exam];
      }
    }
    print('Updated events: $_events');
    setState(() {});
  }

  void _addExam() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewExam(
            addExam: _addNewExamToDatabase,
          ),
        );
      },
    );
  }

  void _addNewExamToDatabase(String subject, DateTime date, TimeOfDay time) async {
    String topic = 'exams'; // Use a meaningful topic name

    FirebaseMessaging.instance.subscribeToTopic(topic);

    try {
      var deviceState = await OneSignal.shared.getDeviceState();
      String? playerId = deviceState?.userId;



      if (playerId != null && playerId.isNotEmpty) {
        print("playerId:"+playerId);
        List<String> playerIds = [playerId];

        try {
          await OneSignal.shared.postNotification(OSCreateNotification(
            playerIds: playerIds,
            content: "You have a new exam: $subject",
            heading: "New Exam Added",
          ));
        } catch (e) {
          print("Error posting notification: $e");
        }
      } else {
        print("Player ID is null or empty.");
      }
    } catch (e) {
      // Handle errors
      print("Error getting device state: $e");
    }

    addExam(subject, date, time);
  }

  Future<void> addExam(String subject, DateTime date, TimeOfDay time) async {
    User? user = FirebaseAuth.instance.currentUser;
    DateTime newDate = DateTime(date.year, date.month, date.day, time.hour,
        time.minute, 0, 0, 0);
    if (user != null) {
      await FirebaseFirestore.instance.collection('exams').add({
        'subject': subject,
        'date': newDate,
        'userId': user.uid,
      });
      _loadExams();
    }
  }

  Future<void> _signOutAndNavigateToLogin(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthGate()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab4-201083"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          ElevatedButton(
            onPressed: () => _addExam(),
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.limeAccent),
            ),
            child: const Text(
              "Add exam",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => _signOutAndNavigateToLogin(context),
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.limeAccent),
            ),
            child: const Text(
              "Sign out",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2022),
            lastDay: DateTime(2025),
            startingDayOfWeek: StartingDayOfWeek.sunday,

            headerStyle: HeaderStyle(
              formatButtonTextStyle:
              TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            calendarStyle: CalendarStyle(
              weekendTextStyle: TextStyle().copyWith(color: Colors.red),
              outsideDaysVisible: false,
              markersMaxCount: 1,
              markersAlignment: Alignment.bottomCenter,
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue, // Color of the circle
                border: Border.all(
                  color: Colors.blue, // Border color for the circle
                  width: 2,
                ),
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue, // Color of the circle
                border: Border.all(
                  color: Colors.blue, // Border color for the circle
                  width: 2,
                ),
              ),
            ),
            onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
              // Handle day selection
              print('Selected date: $selectedDay');
              print('Focused date: $focusedDay');
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (DateTime focusedDay) {
              // Handle page change
              print('Page changed: $focusedDay');
              setState(() {
                _focusedDay = DateTime(focusedDay.year, focusedDay.month, 1);
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                DateTime eventDate =
                DateTime(date.year, date.month, date.day);
                if (_events.containsKey(eventDate) &&
                    _events[eventDate]!.isNotEmpty) {
                  return Positioned(
                    top: 2, // Adjust the top position
                    right: 2, // Adjust the right position
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 20.0,
                      height: 20.0,
                      child: Center(
                        child: Text(
                          _events[eventDate]!.length
                              .toString(), // Display the count of events in the marker
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                } else {
                  return SizedBox.shrink(); // Return an empty-sized widget if there are no events.
                }
              },

            ),
          ),
          SizedBox(height: 16), // Adjust the spacing as needed
          Expanded(
            child: _buildExamList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExamList() {
    // Filter exams for the focused month
    final currentMonthExams = _exams.where((exam) =>
    exam.date.month == _focusedDay.month &&
        exam.date.year == _focusedDay.year).toList();

    if (currentMonthExams.isEmpty) {
      return Center(
        child: Text("No exams for the current month."),
      );
    }

    return GridView.builder(
      itemCount: currentMonthExams.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentMonthExams[index].subject,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(currentMonthExams[index].date),
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  )
                ],
              )
            ],
          ),
        );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    );
  }
}