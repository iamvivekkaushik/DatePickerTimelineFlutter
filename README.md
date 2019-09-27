# MSDatePickerTimeline

[![Pub](https://img.shields.io/pub/v/ms_date_picker_timeline?color=%232bb6f6)](https://pub.dev/packages/ms_date_picker_timeline)

Flutter Date Picker Library that provides a calendar as a horizontal timeline.

<p>
 <img src="https://raw.githubusercontent.com/iamvivekkaushik/DatePickerTimelineFlutter/master/screenshots/demo.gif?raw=true"/>
</p>

## How To Use

Import the following package in your dart file

```
import 'package:ms_date_picker_timeline/ms_date_picker_timeline.dart';
```

## Usage

Use the `MSDatePickerTimeline` Widget

```
    Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MSDatePickerTimeline(
            DateTime.now(),
            locale: 'pt_BR',
            startDate: DateTime.now(),
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
    MSDatePickerTimeline(
      this.currentDate, {
      Key key,
      this.monthTextStyle = defaultMonthTextStyle,
      this.dayTextStyle = defaultDayTextStyle,
      this.dateTextStyle = defaultDateTextStyle,
      this.selectionColor = AppColors.defaultSelectionColor,
      this.startDate,
      this.onDateChange,
      this.locale,
    }) : super(key: key);
```

Author
* [Roger Medeiros](https://github.com/rogermedeirosdasilva/DatePickerTimelineFlutter/)


Based in DatePickerTimelineFlutter
------

* [Vivek Kaushik](http://github.com/iamvivekkaushik/)
