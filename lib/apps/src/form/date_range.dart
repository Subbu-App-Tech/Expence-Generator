import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:provider/provider.dart';
import 'package:expence_generator/apps/src/Data/provider.dart';

class DateRangeForm extends StatefulWidget {
  const DateRangeForm({Key? key}) : super(key: key);

  @override
  State<DateRangeForm> createState() => _DateRangeFormState();
}

class _DateRangeFormState extends State<DateRangeForm> {
  @override
  Widget build(BuildContext context) {
    DateTimeRange range = context.select((ReportModel e) => e.dateRange);
    return Container(
      padding: const EdgeInsets.all(5),
      color: m.Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: DatePicker(
              header: 'Date From',
              contentPadding: const EdgeInsets.all(5),
              selected: range.start,
              onChanged: (v) {
                if (v.isBefore(range.end)) {
                  range = DateTimeRange(start: v, end: range.end);
                  Provider.of<ReportModel>(context, listen: false)
                      .setUpdateDataRange(range);
                } else {
                  m.ScaffoldMessenger.of(context).showSnackBar(const m.SnackBar(
                      content: Text('Date must be before End Date')));
                }
              },
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: DatePicker(
              contentPadding: const EdgeInsets.all(5),
              header: 'Date To',
              selected: range.end,
              onChanged: (v) {
                if (v.isAfter(range.start)) {
                  range = DateTimeRange(start: range.start, end: v);
                  Provider.of<ReportModel>(context, listen: false)
                      .setUpdateDataRange(range);
                } else {
                  m.ScaffoldMessenger.of(context).showSnackBar(const m.SnackBar(
                      content: Text('Date must be After End Date')));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
