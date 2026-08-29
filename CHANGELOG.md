## [1.4.1] - 29/08/2026

* Added `showScrollbar` (#86): renders an always-visible horizontal scrollbar
  attached to the timeline's own scroll position, in its own gutter below the
  tiles (the picker's total height becomes `height + 12`). Style it with an
  ancestor `ScrollbarTheme`

## [1.4.0] - 29/08/2026

* Added `granularity` (#43): `DateGranularity.week` renders one tile per week
  ("AUG / 22–28 / 2026") and `DateGranularity.month` one per month
  ("2026 / SEP"). Tapping a tile selects and emits the first day of its unit,
  and every selection mode, `inactiveDates`/`activeDates` (one entry
  deactivates its whole unit) and all `DatePickerController` methods compose
  with it — dates passed anywhere snap to their containing unit
* Added `firstDayOfWeek` (`DateTime.monday`..`DateTime.sunday`) to override
  the week start, which otherwise comes from the ambient
  `MaterialLocalizations` (Sunday for `en_US`)
* `daysCount` now counts tiles in every granularity (days by default, the
  historical meaning)
* `GregorianDateWidget` gained optional `topLabel`/`middleLabel`/`bottomLabel`
  overrides; existing call sites render identically
* The Persian calendar supports day granularity only (asserted)
* New exported name: `DateGranularity`
* Example app: new "Weeks & months" showcase card with a granularity switch
* Added multi-date and range selection (#57): `selectionMode: SelectionMode.multiple`
  selects any number of days (tapping a selected day removes it) and
  `SelectionMode.range` selects a start and an end date (a second tap on an
  earlier day swaps the endpoints)
* Added `selectedDates`, which seeds the selection and adopts any later change
  to the list, and `onSelectionChange`, which reports the whole selection after
  every tap. In `range` mode the list holds `[start, end]` — the endpoints,
  never the expanded span
* Days between the range endpoints are painted with a new `rangeColor` band
  that runs continuously across the gaps between tiles; `rangeTextColor`
  styles their labels. The endpoints keep the existing `selectionColor` pill
* `DatePickerController` gained `selectedDates`, `select`, `deselect`,
  `clearSelection` and `selectRange`. `jumpToSelection`/`animateToSelection`
  target the most recently selected date. Controller methods fire no
  callbacks, matching `setDateAndAnimate`, which now sets the selection to
  exactly `[date]` in every mode
* `onDateChange` fires in `single` mode only — the default, so existing code
  is unaffected
* `GregorianDateWidget` and `PersianDateWidget` gained optional `selection`
  and `rangeColor` parameters; existing call sites render identically
* New public names exported from the package: `SelectionMode`,
  `TileSelection`, `SelectionChangeListener`, `DateChangeListener`,
  `DateSelectionCallback`
* Example app: two new showcase cards, Multi-pick and Range

## [1.3.0] - 22/08/2026

* Updated dependencies for the latest Flutter: `intl` widened to `>=0.19.0 <0.21.0`, Dart SDK floor raised to 3.5.0 (Flutter 3.24)
* Fixed date tiles overflowing when the given `height` is too small for the text
  styles, e.g. on devices with a taller system font or a large text-scale
  setting. Labels now scale down instead of overflowing
* Modernised the example app's Android build (AGP 8.11.1, Gradle 8.14, Kotlin
  2.2.20, compileSdk 36) and raised its iOS deployment target to 13.0
* Adopted `flutter_lints` and cleaned up all analyzer warnings
* Fixed `DatePickerController` crashes: `jumpToSelection`/`animateToSelection`
  no longer throw when nothing is selected, methods no-op instead of crashing
  when the picker is unmounted or not yet laid out, and out-of-range dates are
  ignored as documented. Added `isAttached`
* `setDateAndAnimate` now repaints the selection highlight
* The picker now reacts to widget updates (changed text styles, colors,
  locale, or a new controller instance) and disposes its scroll controller
* Performance: fixed `itemExtent` on the list, cached `DateFormat` instances,
  and O(1) active/inactive date lookup
* Date tiles are DST-safe (calendar-day arithmetic instead of 24-hour jumps)
* Added `showPastDates`: renders past dates left of `startDate` (half of
  `daysCount`), opens with the selection centered, and makes all
  `DatePickerController` methods center the target date in the viewport
* Example app rebuilt as a design showcase: Classic, Midnight (dark), Booking
  (weekends disabled), Sunset (gradient), Compact, Localized (`de_DE`), and a
  `DatePickerController` playground

## [1.2.7] - 27/05/2025

* Update intl version

## [1.2.6] - 2/04/2024

* Added Support for Gregorian Calendar

## [1.2.5] - 17/06/2023

* Updated Intl

## [1.2.4] - 17/06/2023

* Updated Intl

## [1.2.3] - 06/03/2021

* Migrated to Null Safety

## [1.2.1] - 15/08/2020

* Added option to activate/deactivate certain dates
* Fixed bug where slider was going past the selected date

## [1.2.0] - 31/03/2020

* This version is breaking backward compatibility
* Added option to show past dates
* Added option to change the selected date text color separately
* Added a controller to the control the DatePicker widget
* Added option to change the width of the Date Widget Item

## [1.1.3] - 30/09/2019

* Fixed issue with Locale not being initialized

## [1.1.0] - 27/09/2019

* Added Locale option to show date in different language
* Added option to limit the number of date shown in the list
* Added option to manage width and height of the timeline

## [1.0.0] - 19/09/2019

* Added ability to manage text style for month, date and day text.
* Made changes to DatePickerTimeline constructor
* First Major release

## [0.0.3] - 13/09/2019

* Fixed bug where passing date to constructor was not working

## [0.0.2] - 05/09/2019

* Updated Readme 
* Added Selected Time Display to the Demo App
* Removed time from the selected date


## [0.0.1] - 24/08/2019

* Initial release.
