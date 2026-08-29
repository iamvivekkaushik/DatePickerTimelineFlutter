/// ***
/// This class consists of the DateWidget that is used in the ListView.builder
///
/// Author: Vivek Kaushik `<me@vivekkasuhik.com>`
/// github: https://github.com/iamvivekkaushik/
/// ***
library;

import 'package:date_picker_timeline/extra/dimen.dart';
import 'package:date_picker_timeline/extra/range_band.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:date_picker_timeline/selection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GregorianDateWidget extends StatelessWidget {
  /// Width of the tile's pill; the tile itself adds [Dimen.tileMargin]
  /// on every side.
  final double? width;

  /// The date this tile represents (a unit start date in week/month
  /// granularity).
  final DateTime date;

  /// Styles for the month, weekday and day-number labels.
  final TextStyle? monthTextStyle, dayTextStyle, dateTextStyle;

  /// Background color of the pill ([Colors.transparent] when unselected).
  final Color selectionColor;

  /// Called with [date] when the tile is tapped.
  final DateSelectionCallback? onDateSelected;

  /// Locale used to format the labels.
  final String? locale;

  /// Formatters for the month/weekday labels. When null, they are built
  /// from [locale] on each build (kept for backwards compatibility);
  /// [DatePicker] passes cached instances instead.
  final DateFormat? monthFormat;
  final DateFormat? dayFormat;

  /// What this tile paints for the current selection. [selectionColor]
  /// keeps its existing meaning (the pill fill); this only adds the
  /// range band behind the tile.
  final TileSelection selection;

  /// Color of the band painted behind days inside a selected range.
  final Color rangeColor;

  /// Verbatim overrides for the three label rows, used by [DatePicker] for
  /// week/month granularity tiles. When null the labels are formatted from
  /// [date] exactly as before. Slot-to-style mapping: [topLabel] renders
  /// with `monthTextStyle`, [middleLabel] with `dateTextStyle`, and
  /// [bottomLabel] with `dayTextStyle`.
  final String? topLabel;
  final String? middleLabel;
  final String? bottomLabel;

  const GregorianDateWidget({
    super.key,
    required this.date,
    required this.monthTextStyle,
    required this.dayTextStyle,
    required this.dateTextStyle,
    required this.selectionColor,
    this.width,
    this.onDateSelected,
    this.locale,
    this.monthFormat,
    this.dayFormat,
    this.selection = TileSelection.none,
    this.rangeColor = Colors.transparent,
    this.topLabel,
    this.middleLabel,
    this.bottomLabel,
  });

  @override
  Widget build(BuildContext context) {
    final month = monthFormat ?? DateFormat("MMM", locale);
    final day = dayFormat ?? DateFormat("E", locale);
    return InkWell(
      customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: RangeBand(
        selection: selection,
        color: rangeColor,
        child: Container(
          width: width,
          margin: const EdgeInsets.all(Dimen.tileMargin),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            color: selectionColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            // spaceBetween keeps the labels spread across the tile height as
            // before; each label sits in a Flexible + FittedBox so it scales
            // down instead of overflowing when the given `height` is too small
            // for the text styles (e.g. on devices with a taller system font or
            // a large text-scale setting). Flex factors mirror the default
            // font-size ratio (11/24/11) so the date only shrinks after the
            // smaller labels would.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                        topLabel ?? month.format(date).toUpperCase(), // Month
                        style: monthTextStyle),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(middleLabel ?? date.day.toString(), // Date
                        style: dateTextStyle),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                        bottomLabel ??
                            day.format(date).toUpperCase(), // WeekDay
                        style: dayTextStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        onDateSelected?.call(date);
      },
    );
  }
}
