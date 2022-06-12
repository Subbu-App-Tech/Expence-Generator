import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';

import 'extensions.dart';
export 'extensions.dart';

const String fixedAmount = 'Fixed Amount';

enum DayInterval {
  day('Day', 1),
  week('Week', 7),
  month('Month', 30),
  year('Year', 365);

  final String name;
  final int dayEql;
  const DayInterval(this.name, this.dayEql);
}

class Model {
  DateTime date;
  String details;
  String type;
  double credit;
  double debit;
  Model(
      {required this.date,
      required this.details,
      required this.type,
      required this.credit,
      required this.debit});

  @override
  String toString() {
    return '${date.toDMYString}, $type, $details,'
        ' ${credit.toStringAsFixed(2)}, ${debit.toStringAsFixed(2)} ';
  }

  List<String> get toList => [
        date.toDMYString,
        type,
        details,
        credit.toStringAsFixed(2),
        debit.toStringAsFixed(2)
      ];
  static List<String> header = ['Date', 'Type', 'Details', 'Credit', 'Debit'];
}

class ExpenceInputModel {
  String uqIdx;
  String details;
  String type;
  double value;
  DayInterval interval;
  double intervalGap;
  int intervalRange;
  double varyRange;
  int multipleTimes;
  bool isAvailableOnlyInDay;

  ExpenceInputModel({
    required this.uqIdx,
    required this.details,
    this.type = fixedAmount,
    this.value = 0,
    this.varyRange = 0,
    this.interval = DayInterval.day,
    this.intervalGap = 0,
    this.intervalRange = 0,
    this.multipleTimes = 1,
    this.isAvailableOnlyInDay = false,
  });
  bool get isFixedAmt => type == fixedAmount;
  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'uqIdx': uqIdx});
    result.addAll({'details': details});
    result.addAll({'type': type});
    result.addAll({'value': value});
    result.addAll({'interval': interval.name});
    result.addAll({'intervalGap': intervalGap});
    result.addAll({'intervalRange': intervalRange});
    result.addAll({'varyRange': varyRange});
    result.addAll({'isAvailableOnlyInDay': isAvailableOnlyInDay});
    result.addAll({'multipleTimes': multipleTimes});
    //

    return result;
  }

  factory ExpenceInputModel.fromMap(Map<String, dynamic> map) {
    return ExpenceInputModel(
        uqIdx: map['uqIdx'],
        details: map['details'] ?? '',
        type: map['type'] ?? '',
        value: map['value']?.toDouble() ?? 0.0,
        interval: DayInterval.values.firstWhere(
            (e) => e.name == map['interval'],
            orElse: () => DayInterval.day),
        intervalGap: map['intervalGap']?.toDouble() ?? 0.0,
        intervalRange: map['intervalRange']?.toInt() ?? 0,
        varyRange: map['varyRange']?.toDouble() ?? 0.0,
        multipleTimes: map['multipleTimes'] ?? 1,
        isAvailableOnlyInDay: map['isAvailableOnlyInDay'] ?? false);
  }

  String toJson() => json.encode(toMap());

  double interv(dateRange) => dateRange.duration.inDays / (interval.dayEql);

  factory ExpenceInputModel.fromJson(String source) =>
      ExpenceInputModel.fromMap(json.decode(source));
}
