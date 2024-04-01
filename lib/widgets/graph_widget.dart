import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';

class GraphWidget extends StatefulWidget {
  const GraphWidget({Key? key}) : super(key: key);

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[100],
        constraints: const BoxConstraints(
          maxHeight: 230.0,
          maxWidth: 300.0,
        ),
        padding: const EdgeInsets.all(24.0),
        child: Chart(
          layers: layers(),
          padding: const EdgeInsets.symmetric(horizontal: 30.0).copyWith(
            bottom: 12.0,
          ),
        ),
      ),
    );
  }

  List<ChartLayer> layers() {
    final from = DateTime(2021, 4);
    final to = DateTime(2021, 8);
    final frequency =
        (to.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / 3.0;
    return [
      ChartGridLayer(
        settings: ChartGridSettings(
          x: ChartGridSettingsAxis(
            color: Colors.grey.shade300,
            frequency: frequency,
            max: DateTime(2017, 11).millisecondsSinceEpoch.toDouble(),
            min: DateTime(2017, 4).millisecondsSinceEpoch.toDouble(),
          ),
          y: ChartGridSettingsAxis(
            color: Colors.grey.shade300,
            frequency: 3.0,
            max: 66.0,
            min: 48.0,
          ),
        ),
      ),
      ChartHighlightLayer(
        shape: () => ChartHighlightLineShape<ChartLineDataItem>(
          backgroundColor: Colors.grey.withOpacity(0.5),
          currentPos: (item) => item.currentValuePos,
          radius: const BorderRadius.all(Radius.circular(8.0)),
          width: 20.0,
        ),
      ),
      ChartAxisLayer(
        settings: ChartAxisSettings(
          x: ChartAxisSettingsAxis(
            frequency: frequency,
            max: to.millisecondsSinceEpoch.toDouble(),
            min: from.millisecondsSinceEpoch.toDouble(),
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 10.0,
            ),
          ),
          y: const ChartAxisSettingsAxis(
            frequency: 100.0,
            max: 400.0,
            min: 0.0,
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 10.0,
            ),
          ),
        ),
        labelX: (value) => DateFormat('HH:SS')
            .format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
        labelY: (value) => value.toInt().toString(),
      ),
      ChartLineLayer(
        items: List.generate(
          4,
              (index) => ChartLineDataItem(
            x: (index * frequency) + from.millisecondsSinceEpoch,
            value: Random().nextInt(380) + 20,
          ),
        ),
        settings: const ChartLineSettings(
          color: Color(0xFF8043F9),
          thickness: 4.0,
        ),
      ),
      ChartTooltipLayer(
        shape: () => ChartTooltipLineShape<ChartLineDataItem>(
          backgroundColor: Colors.grey,
          circleBackgroundColor: Colors.black,
          circleBorderColor: const Color(0xFF331B6D),
          circleSize: 4.0,
          circleBorderThickness: 2.0,
          currentPos: (item) => item.currentValuePos,
          onTextValue: (item) => item.value.toString(),
          marginBottom: 6.0,
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 3.0,
          ),
          radius: 6.0,
          textStyle: const TextStyle(
            color: Colors.black,
            letterSpacing: 0.2,
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];
  }
}