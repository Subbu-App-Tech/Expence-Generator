import 'package:expence_generator/apps/src/Data/helper_model.dart';
import 'package:expence_generator/apps/src/Data/models.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

extension DateExt on DateTime {
  DateTime get toStartOfDay => DateTime(year, month, day);
  String get toDMYString => DateFormat('dd/MM/yyyy').format(this);
}

extension ModelListExt on List<Model> {
  double get credit =>
      length == 0 ? 0 : map((e) => e.credit).reduce((a, b) => a + b);
  double get debit =>
      length == 0 ? 0 : map((e) => e.debit).reduce((a, b) => a + b);
  double get diff => credit - debit;
  List<String> get uqTypes => map((e) => e.type).toSet().toList();
  List<DetailType> get typeDetail => uqTypes.map((e) {
        List<Model> mod = where((w) => w.type == e).toList();
        return DetailType(
          title: e,
          count: mod.length,
          value: mod.diff,
        );
      }).toList();
  List<DetailType> get allDetail => [
        DetailType(title: 'Total Difference', value: diff, count: length),
        DetailType(title: '[ Debit ] Money In ', value: credit, count: length),
        DetailType(title: '[Credit] Money Out', value: debit, count: length),
        DetailType(title: 'Types Found', value: -0.1, count: uqTypes.length),
        ...typeDetail
      ];
  void sortList() {
    sort((a, b) => a.date.compareTo(b.date));
  }
}
