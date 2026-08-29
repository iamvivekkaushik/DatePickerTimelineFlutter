import 'package:date_picker_timeline/extra/dimen.dart';
import 'package:date_picker_timeline/selection.dart';
import 'package:flutter/widgets.dart';

/// Paints the range-selection band behind a date tile.
///
/// The tile's [child] (the pill `Container`) is inset by
/// [Dimen.tileMargin] on every side, but the tile itself owns the full
/// `itemExtent` box, so this band can paint across the gutter between
/// adjacent tiles: middles get a full-width band, endpoints get a
/// margin-wide connector strip on their gutter side so the band runs
/// flush into the endpoint pill. For [TileSelection.none] and
/// [TileSelection.selected] the [child] is returned untouched — no extra
/// render objects on the default path.
class RangeBand extends StatelessWidget {
  const RangeBand({
    super.key,
    required this.selection,
    required this.color,
    required this.child,
  });

  final TileSelection selection;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Widget band;
    switch (selection) {
      case TileSelection.rangeMiddle:
        band = ColoredBox(color: color);
        break;
      case TileSelection.rangeStart:
        // AlignmentDirectional resolves against the ambient Directionality,
        // so in RTL the connector flips to the correct gutter for free.
        band = Align(
          alignment: AlignmentDirectional.centerEnd,
          child: SizedBox(
            width: Dimen.tileMargin,
            height: double.infinity,
            child: ColoredBox(color: color),
          ),
        );
        break;
      case TileSelection.rangeEnd:
        band = Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: Dimen.tileMargin,
            height: double.infinity,
            child: ColoredBox(color: color),
          ),
        );
        break;
      case TileSelection.none:
      case TileSelection.selected:
        return child;
    }

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimen.tileMargin),
            child: band,
          ),
        ),
        child,
      ],
    );
  }
}
