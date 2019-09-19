# DatePickerTimeline

[![Pub](https://img.shields.io/pub/v/date_picker_timeline?color=%232bb6f6)](https://pub.dev/packages/date_picker_timeline)

Flutter Date Picker Library that provides a calendar as a horizontal timeline.

<p>
 <img src="https://raw.githubusercontent.com/iamvivekkaushik/DatePickerTimelineFlutter/master/screenshots/demo.gif?raw=true"/>
</p>

## How To Use

Import the following package in your dart file

```
import 'package:date_picker_timeline/date_picker_timeline.dart';
```

## Usage

Use the `DatePickerTimeline` Widget

```
    Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DatePickerTimeline(
            DateTime.now(),
            onDateChange: (date) {
              // New date selected
              print(date.day.toString());
            },
          ),
        ],
    ),
```

##### Constructor:

```
    DatePickerTimeline(
        this.currentDate, {
        Key key,
        this.width,
        this.height = 80,
        this.monthTextStyle = defaultMonthTextStyle,
        this.dayTextStyle = defaultDayTextStyle,
        this.dateTextStyle = defaultDateTextStyle,
        this.selectionColor = AppColors.defaultSelectionColor,
        this.daysCount = 50000,
        this.onDateChange,
      }) : super(key: key);
```

Author
------

* [Vivek Kaushik](http://github.com/iamvivekkaushik/)


Contributors
------------
* [BradInTheUSA](https://github.com/bradintheusa)
