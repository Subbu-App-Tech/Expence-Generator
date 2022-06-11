import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:expence_generator/apps/src/Data/models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

class DataHandling {
  Future<List<Model>> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        dialogTitle: 'Pick CSV',
        type: FileType.custom,
        allowedExtensions: ['csv']);
    if (result?.files.single.path == null) {
      return [];
    } else {
      File file = File(result!.files.single.path!);
      String csv = await file.readAsString();
      final data = const CsvToListConverter().convert(csv);
      int dateIdx = data.first
          .indexWhere((e) => e.toString().trim().toLowerCase() == 'date');
      int detailIdx = data.first
          .indexWhere((e) => e.toString().trim().toLowerCase() == 'details');
      int typeIdx = data.first
          .indexWhere((e) => e.toString().trim().toLowerCase() == 'type');
      int creditIdx = data.first
          .indexWhere((e) => e.toString().trim().toLowerCase() == 'credit');
      int debitIdx = data.first
          .indexWhere((e) => e.toString().trim().toLowerCase() == 'debit');
      List<Model> model = [];
      data.sublist(1).forEach((d) {
        DateTime date;
        try {
          date = DateFormat("dd/MM/yyyy").parse(d[dateIdx]);
        } catch (e) {
          date = DateTime.tryParse(d[dateIdx].toString()) ?? DateTime.now();
        }
        final mod = Model(
            date: date,
            credit: double.tryParse(d[creditIdx].toString()) ?? 0,
            debit: double.tryParse(d[debitIdx].toString()) ?? 0,
            details: d[detailIdx].toString(),
            type: d[typeIdx].toString());
        model.add(mod);
      });
      return model;
    }
  }
}
