import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:expence_generator/apps/src/form/date_range.dart';
import 'package:expence_generator/apps/src/form/expence_to_gen.dart';
import 'package:expence_generator/apps/src/Data/provider.dart';

class DataHandleForm extends StatefulWidget {
  const DataHandleForm({Key? key}) : super(key: key);

  @override
  State<DataHandleForm> createState() => _DataHandleFormState();
}

class _DataHandleFormState extends State<DataHandleForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: const [
                Text('Generator Configuration',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Divider(),
                DateRangeForm(),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Select Days to avoid Expence to Generate',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                WeekDaysToSelect()
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        const SizedBox(height: 5),
        const ExpensesTogenerate(),
      ],
    );
  }
}

class WeekDaysToSelect extends StatefulWidget {
  const WeekDaysToSelect({Key? key}) : super(key: key);

  @override
  State<WeekDaysToSelect> createState() => _WeekDaysToSelectState();
}

class _WeekDaysToSelectState extends State<WeekDaysToSelect> {
  List<String> days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  List<String> weeksSelected = [];
  @override
  void didChangeDependencies() {
    weeksSelected = Provider.of<ReportModel>(context).daysToAvoid;
    super.didChangeDependencies();
  }

  void onTap(String day) {
    Provider.of<ReportModel>(context, listen: false).updateDayToAvoid(day);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 5,
        runSpacing: 5,
        children: days.map((e) {
          return Card(
            padding: EdgeInsets.zero,
            child: weeksSelected.contains(e)
                ? Chip.selected(text: Text(e), onPressed: () => onTap(e))
                : Chip(text: Text(e), onPressed: () => onTap(e)),
          );
        }).toList());
  }
}
