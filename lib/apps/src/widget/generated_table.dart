import 'package:bot_toast/bot_toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:provider/provider.dart';
import 'package:expence_generator/apps/src/Data/models.dart';
import 'package:expence_generator/apps/src/Data/provider.dart';

class GeneratedReportFromInput extends StatelessWidget {
  const GeneratedReportFromInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future getData() async {
      Provider.of<ReportModel>(context, listen: false).generateModel();
    }

    return FutureBuilder(
      future: getData(),
      builder: (c, s) {
        return m.Scaffold(
          appBar: m.AppBar(
            title: const Text('Data Summary'),
            actions: [
              Center(
                  child: m.IconButton(
                      onPressed: () async {
                        BotToast.showLoading();
                        await Provider.of<ReportModel>(context, listen: false)
                            .generateCSV();
                        BotToast.closeAllLoading();
                      },
                      icon: const Icon(FluentIcons.excel_document))),
            ],
          ),
          body: s.connectionState == ConnectionState.done
              ? const GeneratedReportForImport()
              : const Center(child: ProgressRing()),
        );
      },
    );
  }
}

class GeneratedReportForImport extends StatelessWidget {
  const GeneratedReportForImport({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Model> datas =
        Provider.of<ReportModel>(context, listen: false).datasGenerated;
    datas.sortList();
    double total =
        datas.isEmpty ? 0 : datas.map((e) => e.debit).reduce((a, b) => a + b);
    TableRow tableRow(Model e) {
      return TableRow(children: [
        Padding(
            padding: const EdgeInsets.all(5), child: Text(e.date.toDMYString)),
        Padding(
            padding: const EdgeInsets.all(5),
            child: Text(e.details,
                style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              e.debit == -0.1 ? '' : e.debit.toStringAsFixed(2),
              textAlign: TextAlign.right,
              maxLines: 1,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: m.Colors.red[800]),
            )),
      ]);
    }

    TableRow totalTableRow() {
      return TableRow(children: [
        const Padding(padding: EdgeInsets.all(5), child: Text('Total')),
        Padding(
            padding: const EdgeInsets.all(5),
            child: Text('# ${datas.length}',
                style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              total.toStringAsFixed(2),
              textAlign: TextAlign.right,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: m.Colors.red[800]),
            )),
      ]);
    }

    return datas.isEmpty
        ? const Text('')
        : ListView(
            children: [
              const Text('Generated Data From Your Input',
                  textAlign: TextAlign.center),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Table(
                  children: [
                    ...datas.map((e) => tableRow(e)).toList(),
                    totalTableRow()
                  ],
                  border: TableBorder.all(),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                ),
              ),
              const SizedBox(height: 20)
            ],
          );
  }
}
