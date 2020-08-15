# DatePickerTimeline

[![Pub](https://img.shields.io/pub/v/date_picker_timeline?color=%232bb6f6)](https://pub.dev/packages/date_picker_timeline)

Flutter Date Picker Library that provides a calendar as a horizontal timeline.

<p>
 <img src="https://raw.githubusercontent.com/iamvivekkaushik/DatePickerTimelineFlutter/master/screenshots/demo.gif?raw=true"/>
</p>

## How To Use

Import the following package in your dart file

```dart
import 'package:date_picker_timeline/date_picker_timeline.dart';
```

## Usage

This version is breaking backwards compatibility

Use the `DatePicker` Widget

```dart
Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      DatePicker(
        DateTime.now(),
        initialSelectedDate: DateTime.now(),
        selectionColor: Colors.black,
        selectedTextColor: Colors.white,
        onDateChange: (date) {
          // New date selected
          setState(() {
            _selectedValue = date;
          });
        },
      ),
    ],
)
```

##### Constructor:

```dart
DatePicker(
    this.startDate, {
    Key key,
    this.width,
    this.height,
    this.controller,
    this.monthTextStyle,
    this.dayTextStyle,
    this.dateTextStyle,
    this.selectedTextColor,
    this.selectionColor,
    this.deactivatedColor,
    this.initialSelectedDate,
    this.activeDates,
    this.inactiveDates,
    this.daysCount,
    this.onDateChange,
    this.locale = "en_US",
}) : super(key: key);
```

Author
------

* [Vivek Kaushik](https://github.com/iamvivekkaushik/)


Contributors
------------
* [BradInTheUSA](https://github.com/bradintheusa)
* [Roger](https://github.com/rogermedeirosdasilva)
