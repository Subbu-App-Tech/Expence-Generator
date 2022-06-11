// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:expence_generator/apps/src/Data/shared_prefs.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:expence_generator/apps/src/import_data.dart';
import 'package:expence_generator/apps/src/Data/models.dart';
import 'package:win32/win32.dart' as win;
import 'package:path_provider_windows/path_provider_windows.dart' as path;
import 'package:path_provider/path_provider.dart' as pth;
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

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

  Future loadData() async => model = await db.getDatas();

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
    double interv = model.interv(dateRange);
    double gap = model.intervalGap;
    int times = (interv * gap).floor();
    double value = model.type == fixedAmount
        ? model.value
        : (datas.where((e) => e.type == model.type).toList().diff *
            model.value /
            (interv * 100));
    return GeneratedDataModel(
        amount: value,
        multipletimes: model.multipleTimes,
        name: model.details,
        interval: model.interval,
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
        int daytoEdit = c.interval.dayEql + varDayRg;
        DateTime date = i == 0 ? lastDt : lastDt.add(Duration(days: daytoEdit));
        if (date.isBefore(dateRange.start) || date.isAfter(dateRange.end)) {
          print('${c.name} => $expence | $date');
          continue;
        }
        if (j >= gapCount) {
          j = 0;
          lastDt = date;
        }
        j += 1;
        double vvl = (expence / c.multipletimes).floor().toDouble().abs() *
            c.multipletimes;
        datasGen.add(Model(
            date: date,
            details: c.name,
            type: 'Expence',
            credit: 0,
            debit: vvl));
      }
    }
    datasGen.removeWhere((e) => e.debit == 0);
    datasGenerated = datasGen;
  }

  final _random = Random();
  int _next(int min, int max) => min + _random.nextInt(max - min);

  Future generateCSV() async {
    List<Model> datass = [...datas, ...datasGenerated];
    datass.sortList();
    final dir = await fileStorageDir;
    final file =
        await File('${dir.path}/Data_Generated.csv').create(recursive: true);
    String toWrite = Model.header.join(',');
    toWrite += '\n';
    List<String> temp = [];
    for (var e in datass) {
      if (!temp.contains(e.date.toDMYString)) {
        toWrite += '\n';
        temp.add(e.date.toDMYString);
      }
      toWrite += e.toList.join(',');
      toWrite += '\n';
    }
    await file.writeAsString(toWrite);
    if (Platform.isWindows) {
      openFilePath(file.path);
    } else {
      OpenFile.open(file.path);
    }
  }
}

class GeneratedDataModel {
  String name;
  double amount;
  int times;
  int varyRg;
  int varyDayRg;
  DayInterval interval;
  int multipletimes;
  GeneratedDataModel({
    required this.amount,
    required this.times,
    required this.varyRg,
    required this.varyDayRg,
    required this.name,
    required this.interval,
    required this.multipletimes,
  });
  double get total => times * amount;
}

// Future generateData(List<Model> modelsExist,List<> ) async {

// }

Future<Directory> get fileStorageDir async {
  if (Platform.isWindows) {
    String doc = win.FOLDERID_Downloads;
    String? library = (await path.PathProviderWindows().getPath(doc));
    // ignore: unnecessary_string_interpolations
    Directory dir = await Directory('$library').create(recursive: true);
    return dir;
  } else {
    Directory dir = (await pth.getExternalStorageDirectories(
                type: pth.StorageDirectory.downloads))
            ?.first ??
        await pth.getDownloadsDirectory() ??
        await pth.getApplicationSupportDirectory();
    return dir;
  }
}

Future openFilePath(String path) async {
  final url = Uri.parse('file:$path');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}
