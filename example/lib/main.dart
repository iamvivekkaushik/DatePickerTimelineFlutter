import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Date Picker Timeline Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatePickerController _controller = DatePickerController();

  DateTime _selectedDayValue = DateTime.now();
  DateTime _selectedMonthValue = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  // function to get total days in a month
  int daysInMonth(DateTime date) {
    var firstDayThisMonth = firstDayOfMonth(date);
    var firstDayNextMonth = new DateTime(date.year, date.month + 1, 1);

    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  // function to get the first day of the month
  DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () {
            _controller.animateToSelection();
          },
        ),
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: Container(
          padding: EdgeInsets.all(20.0),
          color: Colors.blueGrey[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("You Selected Month:"),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              Text(_selectedMonthValue.toString()),
              Padding(
                padding: EdgeInsets.all(20),
              ),
              Text("You Selected Day:"),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              Text(_selectedDayValue.toString()),
              Padding(
                padding: EdgeInsets.all(20),
              ),
              Container(
                child: MonthPicker(
                  startDate: DateTime.now(),
                  height: 50,
                  initialSelectedDate: _selectedMonthValue,
                  selectionColor: Colors.black,
                  selectedTextColor: Colors.white,
                  onDateChange: (date) {
                    // New date selected
                    setState(() {
                      _selectedMonthValue = date;
                    });
                  },
                ),
              ),
              Container(
                child: DatePicker(
                  firstDayOfMonth(_selectedMonthValue),
                  width: 60,
                  height: 80,
                  controller: _controller,
                  initialSelectedDate: _selectedDayValue,
                  selectionColor: Colors.black,
                  selectedTextColor: Colors.white,
                  daysCount: daysInMonth(_selectedMonthValue),
                  inactiveDates: [
                    DateTime.now().add(Duration(days: 3)),
                    DateTime.now().add(Duration(days: 4)),
                    DateTime.now().add(Duration(days: 7))
                  ],
                  onDateChange: (date) {
                    // New date selected
                    setState(() {
                      _selectedDayValue = date;
                    });
                  },
                ),
              ),
              Container(
                child: YearPickerTimeline(
                  startDate: DateTime.now(),
                  height: 45,
                  initialSelectedDate: _selectedMonthValue,
                  selectionColor: Colors.black,
                  selectedTextColor: Colors.white,
                  onDateChange: (date) {
                    // New date selected
                    setState(() {
                      _selectedMonthValue = date;
                    });
                  },
                ),
              )
            ],
          ),
        ));
  }
}
