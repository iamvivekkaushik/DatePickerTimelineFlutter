import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ShowcaseApp());

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Picker Timeline Designs',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF3F4F8),
      ),
      home: const ShowcasePage(),
    );
  }
}

class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Picker Timeline'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ClassicDemo(),
          SizedBox(height: 16),
          TimelineDemo(),
          SizedBox(height: 16),
          MidnightDemo(),
          SizedBox(height: 16),
          BookingDemo(),
          SizedBox(height: 16),
          SunsetDemo(),
          SizedBox(height: 16),
          CompactDemo(),
          SizedBox(height: 16),
          LocalizedDemo(),
          SizedBox(height: 16),
          ControllerDemo(),
          SizedBox(height: 16),
          MultiPickDemo(),
          SizedBox(height: 16),
          RangeDemo(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Shared card chrome for every design example.
class DesignCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? background;
  final Gradient? gradient;
  final Color textColor;

  const DesignCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.background,
    this.gradient,
    this.textColor = const Color(0xFF1C1B1F),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? (background ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.5,
                color: textColor.withValues(alpha: 0.65),
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Small pill showing the currently selected date of a demo.
class SelectedPill extends StatelessWidget {
  final DateTime? date;
  final String? label;
  final Color color;
  final Color textColor;

  const SelectedPill({
    super.key,
    this.date,
    this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final label = this.label ??
        (date == null
            ? 'Nothing selected yet'
            : 'Selected  ·  ${date!.toIso8601String().split('T').first}');
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// 1. The package defaults: black selection on a light card.
class ClassicDemo extends StatefulWidget {
  const ClassicDemo({super.key});

  @override
  State<ClassicDemo> createState() => _ClassicDemoState();
}

class _ClassicDemoState extends State<ClassicDemo> {
  DateTime? _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      title: 'Classic',
      subtitle: 'Default styling, out of the box',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            initialSelectedDate: DateTime.now(),
            selectionColor: Colors.black,
            selectedTextColor: Colors.white,
            daysCount: 90,
            onDateChange: (date) => setState(() => _selected = date),
          ),
          SelectedPill(
            date: _selected,
            color: Colors.black,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// Past and future: today opens centered, history scrolls off to the left.
class TimelineDemo extends StatefulWidget {
  const TimelineDemo({super.key});

  @override
  State<TimelineDemo> createState() => _TimelineDemoState();
}

class _TimelineDemoState extends State<TimelineDemo> {
  static const _blue = Color(0xFF0277BD);
  final DatePickerController _controller = DatePickerController();
  DateTime? _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      title: 'Past & future',
      subtitle: 'showPastDates: true — today opens centered',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            showPastDates: true,
            controller: _controller,
            initialSelectedDate: DateTime.now(),
            selectionColor: _blue,
            selectedTextColor: Colors.white,
            daysCount: 120,
            onDateChange: (date) => setState(() => _selected = date),
          ),
          const SizedBox(height: 12),
          _ChipButton(
            label: 'Center on selection',
            onTap: () =>
                _controller.animateToSelection(curve: Curves.easeOutCubic),
          ),
          SelectedPill(
            date: _selected,
            color: _blue.withValues(alpha: 0.12),
            textColor: _blue,
          ),
        ],
      ),
    );
  }
}

/// 2. Dark theme: violet selection on a midnight card.
class MidnightDemo extends StatefulWidget {
  const MidnightDemo({super.key});

  @override
  State<MidnightDemo> createState() => _MidnightDemoState();
}

class _MidnightDemoState extends State<MidnightDemo> {
  static const _violet = Color(0xFF7C4DFF);
  DateTime? _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    const monthDay = TextStyle(
      color: Colors.white54,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    const date = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    );
    return DesignCard(
      title: 'Midnight',
      subtitle: 'For dark UIs — violet accent',
      background: const Color(0xFF1B1830),
      textColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            initialSelectedDate: DateTime.now(),
            selectionColor: _violet,
            selectedTextColor: Colors.white,
            deactivatedColor: Colors.white24,
            monthTextStyle: monthDay,
            dayTextStyle: monthDay,
            dateTextStyle: date,
            daysCount: 90,
            onDateChange: (date) => setState(() => _selected = date),
          ),
          SelectedPill(
            date: _selected,
            color: _violet.withValues(alpha: 0.25),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

/// 3. Appointment booking: weekends are closed via [DatePicker.inactiveDates].
class BookingDemo extends StatefulWidget {
  const BookingDemo({super.key});

  @override
  State<BookingDemo> createState() => _BookingDemoState();
}

class _BookingDemoState extends State<BookingDemo> {
  static const _teal = Color(0xFF00A88E);
  static const _days = 60;
  DateTime? _selected;
  late final List<DateTime> _weekends;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _weekends = [
      for (var i = 0; i < _days; i++)
        if (DateUtils.addDaysToDate(today, i).weekday >= DateTime.saturday)
          DateUtils.addDaysToDate(today, i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      title: 'Booking',
      subtitle: 'Weekends closed — tap a weekday to book',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            selectionColor: _teal,
            selectedTextColor: Colors.white,
            deactivatedColor: Colors.black26,
            inactiveDates: _weekends,
            daysCount: _days,
            onDateChange: (date) => setState(() => _selected = date),
          ),
          SelectedPill(
            date: _selected,
            color: _teal.withValues(alpha: _selected == null ? 0.15 : 1),
            textColor: _selected == null ? _teal : Colors.white,
          ),
        ],
      ),
    );
  }
}

/// 4. Gradient hero card: white selection over a sunset gradient.
class SunsetDemo extends StatefulWidget {
  const SunsetDemo({super.key});

  @override
  State<SunsetDemo> createState() => _SunsetDemoState();
}

class _SunsetDemoState extends State<SunsetDemo> {
  DateTime? _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    const onGradient = TextStyle(
      color: Colors.white70,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
    const date = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );
    return DesignCard(
      title: 'Sunset',
      subtitle: 'Inverted: white selection on a gradient hero',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6D3F), Color(0xFFE9366F)],
      ),
      textColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            initialSelectedDate: DateTime.now(),
            selectionColor: Colors.white,
            selectedTextColor: const Color(0xFFE9366F),
            monthTextStyle: onGradient,
            dayTextStyle: onGradient,
            dateTextStyle: date,
            daysCount: 90,
            onDateChange: (date) => setState(() => _selected = date),
          ),
          SelectedPill(
            date: _selected,
            color: Colors.white,
            textColor: const Color(0xFFE9366F),
          ),
        ],
      ),
    );
  }
}

/// 5. Compact strip for tight layouts (app bars, bottom sheets).
class CompactDemo extends StatefulWidget {
  const CompactDemo({super.key});

  @override
  State<CompactDemo> createState() => _CompactDemoState();
}

class _CompactDemoState extends State<CompactDemo> {
  static const _indigo = Color(0xFF3D5AFE);
  DateTime? _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    const small = TextStyle(
      color: Colors.black54,
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );
    const date = TextStyle(
      color: Colors.black87,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );
    return DesignCard(
      title: 'Compact',
      subtitle: '44 × 64 tiles for dense layouts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            width: 44,
            height: 64,
            initialSelectedDate: DateTime.now(),
            selectionColor: _indigo,
            selectedTextColor: Colors.white,
            monthTextStyle: small,
            dayTextStyle: small,
            dateTextStyle: date,
            daysCount: 90,
            onDateChange: (date) => setState(() => _selected = date),
          ),
          SelectedPill(
            date: _selected,
            color: _indigo.withValues(alpha: 0.12),
            textColor: _indigo,
          ),
        ],
      ),
    );
  }
}

/// 6. Localized labels via [DatePicker.locale].
class LocalizedDemo extends StatefulWidget {
  const LocalizedDemo({super.key});

  @override
  State<LocalizedDemo> createState() => _LocalizedDemoState();
}

class _LocalizedDemoState extends State<LocalizedDemo> {
  static const _amber = Color(0xFFE8930C);
  DateTime? _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      title: 'Localized',
      subtitle: "locale: 'de_DE' — month and weekday names follow",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            locale: 'de_DE',
            initialSelectedDate: DateTime.now(),
            selectionColor: _amber,
            selectedTextColor: Colors.white,
            daysCount: 90,
            onDateChange: (date) => setState(() => _selected = date),
          ),
          SelectedPill(
            date: _selected,
            color: _amber.withValues(alpha: 0.15),
            textColor: _amber,
          ),
        ],
      ),
    );
  }
}

/// 7. Driving the picker programmatically with [DatePickerController].
class ControllerDemo extends StatefulWidget {
  const ControllerDemo({super.key});

  @override
  State<ControllerDemo> createState() => _ControllerDemoState();
}

class _ControllerDemoState extends State<ControllerDemo> {
  static const _green = Color(0xFF2E7D32);
  final DatePickerController _controller = DatePickerController();
  DateTime? _selected = DateTime.now();

  void _select(int daysFromToday) {
    _controller.setDateAndAnimate(
      DateUtils.addDaysToDate(DateTime.now(), daysFromToday),
      curve: Curves.easeOutCubic,
    );
    setState(
      () => _selected = DateUtils.addDaysToDate(DateTime.now(), daysFromToday),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      title: 'Controller',
      subtitle: 'setDateAndAnimate / animateToSelection from buttons',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            controller: _controller,
            initialSelectedDate: DateTime.now(),
            selectionColor: _green,
            selectedTextColor: Colors.white,
            daysCount: 90,
            onDateChange: (date) => setState(() => _selected = date),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _ChipButton(label: 'Today', onTap: () => _select(0)),
              _ChipButton(label: '+1 week', onTap: () => _select(7)),
              _ChipButton(label: '+1 month', onTap: () => _select(30)),
              _ChipButton(
                label: 'Back to selection',
                onTap: () => _controller.animateToSelection(
                  curve: Curves.easeOutCubic,
                ),
              ),
            ],
          ),
          SelectedPill(
            date: _selected,
            color: _green.withValues(alpha: 0.12),
            textColor: _green,
          ),
        ],
      ),
    );
  }
}

/// 9. Multiple selection: tap to add, tap again to remove.
class MultiPickDemo extends StatefulWidget {
  const MultiPickDemo({super.key});

  @override
  State<MultiPickDemo> createState() => _MultiPickDemoState();
}

class _MultiPickDemoState extends State<MultiPickDemo> {
  static const _pink = Color(0xFFD81B60);
  final DatePickerController _controller = DatePickerController();
  List<DateTime> _selected = [
    DateUtils.dateOnly(DateTime.now()),
    DateUtils.addDaysToDate(DateTime.now(), 2),
  ];

  String get _label {
    if (_selected.isEmpty) return 'No dates selected';
    if (_selected.length == 1) {
      return 'Selected  ·  ${_selected.single.toIso8601String().split('T').first}';
    }
    return '${_selected.length} days selected';
  }

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      title: 'Multi-pick',
      subtitle: 'selectionMode: multiple — tap again to remove',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            selectionMode: SelectionMode.multiple,
            selectedDates: _selected,
            controller: _controller,
            selectionColor: _pink,
            selectedTextColor: Colors.white,
            daysCount: 90,
            onSelectionChange: (dates) => setState(() => _selected = dates),
          ),
          const SizedBox(height: 12),
          _ChipButton(
            label: 'Clear',
            // Controller mutations are silent (they don't fire
            // onSelectionChange), so mirror the local state too.
            onTap: () {
              _controller.clearSelection();
              setState(() => _selected = []);
            },
          ),
          SelectedPill(
            label: _label,
            color: _pink.withValues(alpha: 0.12),
            textColor: _pink,
          ),
        ],
      ),
    );
  }
}

/// 10. Range selection: first tap picks the start, the second the end.
class RangeDemo extends StatefulWidget {
  const RangeDemo({super.key});

  @override
  State<RangeDemo> createState() => _RangeDemoState();
}

class _RangeDemoState extends State<RangeDemo> {
  static const _cyan = Color(0xFF00838F);
  final DatePickerController _controller = DatePickerController();
  List<DateTime> _range = [
    DateUtils.dateOnly(DateTime.now()),
    DateUtils.addDaysToDate(DateTime.now(), 4),
  ];

  String get _label {
    if (_range.isEmpty) return 'Tap a start date';
    final start = _range.first.toIso8601String().split('T').first;
    if (_range.length == 1) return 'Start · $start — now pick an end';
    final end = _range.last.toIso8601String().split('T').first;
    final days = _range.last.difference(_range.first).inDays + 1;
    return '$start  →  $end  ·  $days days';
  }

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      title: 'Range',
      subtitle: 'selectionMode: range — tap a start, then an end',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            selectionMode: SelectionMode.range,
            selectedDates: _range,
            controller: _controller,
            selectionColor: _cyan,
            selectedTextColor: Colors.white,
            rangeColor: _cyan.withValues(alpha: 0.15),
            daysCount: 90,
            onSelectionChange: (dates) => setState(() => _range = dates),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _ChipButton(
                label: 'Next 7 days',
                onTap: () {
                  final today = DateTime.now();
                  final end = DateUtils.addDaysToDate(today, 6);
                  _controller.selectRange(today, end);
                  setState(() => _range = [DateUtils.dateOnly(today), end]);
                },
              ),
              _ChipButton(
                label: 'Clear',
                onTap: () {
                  _controller.clearSelection();
                  setState(() => _range = []);
                },
              ),
            ],
          ),
          SelectedPill(
            label: _label,
            color: _cyan.withValues(alpha: 0.12),
            textColor: _cyan,
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ChipButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
