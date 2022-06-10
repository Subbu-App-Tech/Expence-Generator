// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:expence_generator/apps/src/Data/shared_prefs.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:expence_generator/apps/src/import_data.dart';
import 'package:expence_generator/apps/src/Data/models.dart';
import 'package:open_document/open_document.dart';

final GlobalKey totalBoxKey = GlobalKey();

class ReportModel with ChangeNotifier {
  List<ExpenceInputModel> model = [];
  List<Model> datas = [];
  List<Model> datasGenerated = [];
  DateTimeRange dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now());
  List<String> get uqDataTypes => datas.uqTypes;
  double get differ => getDataCredit - getDataDebit;
  void setUpdateDataRange(DateTimeRange range) {
    dateRange = range;
    notifyListeners();
  }

  Future loadData() async {
    model = await db.getDatas();
  }

  double get getDataCredit =>
      datas.isEmpty ? 0 : datas.map((e) => e.credit).reduce((a, b) => a + b);
  double get getDataDebit =>
      datas.isEmpty ? 0 : datas.map((e) => e.debit).reduce((a, b) => a + b);

  Future getFile() async {
    datas = await DataHandling().getFile();
    if (datas.isEmpty) {
      BotToast.showText(text: 'Please Select CSV File to Import Data');
      return;
    }
    datas.sort(((a, b) => a.date.compareTo(b.date)));
    DateTime firstDay =
        datas.first.date.toDMYString == datas.last.date.toDMYString
            ? datas.first.date.subtract(const Duration(days: 7))
            : datas.first.date;
    dateRange = DateTimeRange(start: firstDay, end: datas.last.date);
    notifyListeners();
  }

  Future addEmptyModel() async {
    final exe = ExpenceInputModel(
        uqIdx: UniqueKey().toString(),
        details: '',
        value: 1,
        type: fixedAmount);
    model.add(exe);
    await db.putUpdateData(exe);
  }

  Future removeModel(String uqIdx, [bool listen = false]) async {
    model.removeWhere((e) => e.uqIdx == uqIdx);
    if (listen) notifyListeners();
    await db.deleteData(uqIdx);
  }

  static Future updateModel(ExpenceInputModel model) async {
    await db.putUpdateData(model);
  }

  List<GeneratedDataModel> get getGenModelForAllModel =>
      model.map((e) => getExpenceTotal(e)).toList();

  GeneratedDataModel getExpenceTotal(ExpenceInputModel model) {
    double interv = dateRange.duration.inDays / (model.interval.dayEql);
    double gap = model.intervalGap;
    int times = (interv * gap).floor();
    double value = model.type == fixedAmount
        ? model.value
        : (datas.where((e) => e.type == model.type).toList().diff *
            model.value /
            (interv * 100));
    return GeneratedDataModel(
        amount: value,
        name: model.details,
        times: times,
        varyRg: model.varyRange.floor(),
        varyDayRg: model.intervalRange);
  }

  void notify() => notifyListeners();

  Future generateModel() async {
    List<Model> datasGen = [];
    for (var c in getGenModelForAllModel) {
      int gapCount = (c.times / dateRange.duration.inDays).floor();
      DateTime lastDt = dateRange.start;
      int j = 0;
      for (var i = 0; i < c.times; i++) {
        int varAmtRg = c.varyRg == 0 ? 0 : _next(-(c.varyRg + 1), c.varyRg + 1);
        int varDayRg =
            c.varyDayRg == 0 ? 0 : _next(-(c.varyDayRg + 1), c.varyDayRg + 1);
        double expence = c.amount + varAmtRg;
        DateTime date = lastDt.add(Duration(days: 1 + varDayRg));
        if (j >= gapCount) {
          j = 0;
          lastDt = date;
        }
        j += 1;
        datasGen.add(Model(
            date: date,
            details: c.name,
            type: 'Expence',
            credit: 0,
            debit: expence));
      }
    }
    datasGen.removeWhere((e) => e.credit == 0);
    datasGenerated = datasGen;
  }

  final _random = Random();
  int _next(int min, int max) => min + _random.nextInt(max - min);

  Future generateCSV() async {
    List<Model> datass = [...datas, ...datasGenerated];
    datass.sortList();
    final file = await File('Data_Generated.csv').create(recursive: true);
    String toWrite = Model.header.join(',');
    toWrite += '\n';
    for (var e in datass) {
      toWrite += e.toList.join(',');
      toWrite += '\n';
    }
    await file.writeAsString(toWrite);
    OpenDocument.openDocument(filePath: file.path);
  }
}

class GeneratedDataModel {
  String name;
  double amount;
  int times;
  int varyRg;
  int varyDayRg;
  GeneratedDataModel({
    required this.amount,
    required this.times,
    required this.varyRg,
    required this.varyDayRg,
    required this.name,
  });
  double get total => times * amount;
}

// Future generateData(List<Model> modelsExist,List<> ) async {

// }
