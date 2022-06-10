import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:provider/provider.dart';
import 'package:expence_generator/apps/src/Data/provider.dart';

class TotalToGenerate extends StatefulWidget {
  const TotalToGenerate({Key? key}) : super(key: key);

  @override
  State<TotalToGenerate> createState() => _TotalToGenerateState();
}

class _TotalToGenerateState extends State<TotalToGenerate> {
  @override
  Widget build(BuildContext context) {
    final genModels = Provider.of<ReportModel>(context).getGenModelForAllModel;
    double total = 0;
    double varyRg = 0;
    for (var e in genModels) {
      total += e.total;
      varyRg += e.varyRg;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        padding: const EdgeInsets.all(8),
        backgroundColor: m.Colors.red[800],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Total Expence will Generate',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)),
            const SizedBox(height: 6),
            Text(
              '₹ ${total.toStringAsFixed(2)} [ ± ${varyRg.ceil()}]',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
