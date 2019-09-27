library date_picker_timeline;

import 'package:ms_date_picker_timeline/date_widget.dart';
import 'package:ms_date_picker_timeline/extra/color.dart';
import 'package:ms_date_picker_timeline/extra/style.dart';
import 'package:ms_date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';

class MSDatePickerTimeline extends StatefulWidget {
  final TextStyle monthTextStyle, dayTextStyle, dateTextStyle;
  final Color selectionColor;
  final DateTime currentDate;
  final DateChangeListener onDateChange;
  final String locale;
  final DateTime startDate;
  final ScrollController _scrollController = new ScrollController();

  // Creates the DatePickerTimeline Widget
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

  @override
  State<StatefulWidget> createState() => new _MSDatePickerState();
}

class _MSDatePickerState extends State<MSDatePickerTimeline> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        itemCount: 365,
        controller: widget._scrollController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          // Return the Date Widget
          DateTime _date = (widget.startDate ?? DateTime.now()).add(Duration(days: index));
          DateTime date = new DateTime(_date.year, _date.month, _date.day);
          bool isSelected = compareDate(date, widget.currentDate);

          return DateWidget(
            date: date,
            monthTextStyle: widget.monthTextStyle,
            dateTextStyle: widget.dateTextStyle,
            dayTextStyle: widget.dayTextStyle,
            locale: widget.locale,
            selectionColor:
                isSelected ? widget.selectionColor : Colors.transparent,
            onDateSelected: (selectedDate) {
              // A date is selected
              if (widget.onDateChange != null) {
                widget.onDateChange(selectedDate);
                final difference = selectedDate.difference((widget.startDate ?? DateTime.now())).inDays;
                scrollToPosition(difference);
              }
              /*
              setState(() {
                widget.currentDate = selectedDate;
              });
              */
            },
          );
        },
      ),
    );
  }

  bool compareDate(DateTime date1, DateTime date2) {
    bool isEquals = (date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year);
    if (isEquals) {
      final difference = date1.difference((widget.startDate ?? DateTime.now())).inDays;
      scrollToPosition(difference);
    }

    return isEquals;
  }

  void scrollToPosition(int position) {
    widget._scrollController.animateTo(position * 62.0, duration: new Duration(seconds: 1), curve: Curves.ease);
  }
}