import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewExam extends StatefulWidget {
  final Function addExam;

  const NewExam({super.key, required this.addExam});

  @override
  _NewExamState createState() => _NewExamState();
}

class _NewExamState extends State<NewExam> {
  final _subjectController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _submitData() {
    final enteredSubject = _subjectController.text;

    if (enteredSubject.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    widget.addExam(
        enteredSubject,
        _selectedDate,
        _selectedTime
    );

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _presentTimePicker() {
    showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 0, minute: 0))
        .then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTime = pickedTime;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Subject name'),
              controller: _subjectController,
              onSubmitted: (_) => _submitData(),
            ),
            Container(
              height: 70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No Date Chosen!'
                          : 'Default Date: ${DateFormat.yMd().format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor),
                    onPressed: _presentDatePicker,
                    child: const Text(
                      'Choose Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'No Time Chosen!'
                          : 'Default Time: ${_selectedTime.format(context)}',
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor),
                    onPressed: _presentTimePicker,
                    child: const Text(
                      'Choose Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.button?.color,
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                fixedSize: const Size.fromWidth(500)
              ),
              onPressed: _submitData,
              child: const Text('Add Exam Schedule', style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}