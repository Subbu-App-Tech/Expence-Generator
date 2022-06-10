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
  late ReportModel model;
  @override
  void didChangeDependencies() {
    model = Provider.of<ReportModel>(context);
    super.didChangeDependencies();
  }

  Future loadData() async {
    model.generateModel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: ProgressRing(),
              ),
            );
          }
          return Column(
            children: [
              const Text('Generator Configuration',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const Divider(),
              const DateRangeForm(),
              ExpensesTogenerate(model: model),
            ],
          );
        });
  }
}
