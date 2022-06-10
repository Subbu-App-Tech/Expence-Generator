import 'package:bot_toast/bot_toast.dart';
import 'package:expence_generator/apps/src/constant.dart';
import 'package:expence_generator/apps/src/widget/generated_table.dart';
import 'package:fluent_ui/fluent_ui.dart' as f;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expence_generator/apps/src/form/data_handle_form.dart';
import 'package:expence_generator/apps/src/form/total_to_gen.dart';
import 'package:expence_generator/apps/src/Data/models.dart';
import 'package:expence_generator/apps/src/Data/provider.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = ReportModel();
    return FutureBuilder(
        future: model.loadData(),
        builder: (context, snapshot) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => model),
            ],
            child: MaterialApp(
              builder: BotToastInit(),
              navigatorObservers: [BotToastNavigatorObserver()],
              title: 'Expence Generator',
              home: f.FluentApp(
                  home: snapshot.connectionState != ConnectionState.done
                      ? const f.ScaffoldPage(
                          content: f.Center(child: f.ProgressRing()))
                      : const HomePg()),
            ),
          );
        });
  }
}

class HomePg extends StatelessWidget {
  const HomePg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expence Generator')),
      body: ListView(shrinkWrap: true, children: [
        const SizedBox(height: 10),
        const MiniReportForImport(),
        const DataHandleForm(),
        TotalToGenerate(key: totalBoxKey),
        Center(
            child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GeneratedReportFromInput()),
                  );
                },
                style: ElevatedButton.styleFrom(primary: Colors.green[800]),
                child: const Text('Generate Data'))),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class MiniReportForImport extends StatelessWidget {
  const MiniReportForImport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Model> datas = context.select((ReportModel e) => e.datas);
    return f.Padding(
      padding: const EdgeInsets.all(8.0),
      child: datas.isEmpty
          ? f.Column(
              children: [
                f.Center(
                  child: f.Row(
                    mainAxisAlignment: f.MainAxisAlignment.center,
                    children: [
                      Container(
                          color: Colors.red[50],
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          child: const Text(importFormat)),
                    ],
                  ),
                ),
                f.Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: ElevatedButton(
                          onPressed: () async {
                            await Provider.of<ReportModel>(context,
                                    listen: false)
                                .getFile();
                          },
                          child: const Text('Upload CSV Document'))),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Data Summary',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Summary From imported Data',
                    textAlign: TextAlign.center),
                f.Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Table(
                    children: datas.allDetail.map((e) => e.tableRow).toList(),
                    border: TableBorder.all(),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                  ),
                ),
              ],
            ),
    );
  }
}
