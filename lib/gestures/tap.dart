/// Signature for a function that detects when a tap has occurred.
///
/// Used by [DatePicker] for tap detection.
typedef DateSelectionCallback = void Function(DateTime selectedDate);

/// Signature for a function that is called when the selected date changes.
///
/// Used by [DatePicker] for change notification.
typedef DateChangeListener = DateSelectionCallback;
