import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;

class DetailType {
  String title;
  double value;
  int count;
  DetailType({
    required this.title,
    required this.value,
    required this.count,
  });

  TableRow get tableRow {
    return TableRow(children: [
      Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
      Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            value == -0.1 ? '' : value.toStringAsFixed(2),
            textAlign: TextAlign.right,
            maxLines: 1,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    value.isNegative ? m.Colors.red[800] : m.Colors.green[800]),
          )),
      Padding(
          padding: const EdgeInsets.all(5),
          child: Text('$count #',
              maxLines: 1,
              textAlign: TextAlign.right,
              style: const TextStyle())),
    ]);
  }
}
