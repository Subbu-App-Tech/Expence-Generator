import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:provider/provider.dart';
import 'package:expence_generator/apps/src/Data/models.dart';
import 'package:expence_generator/apps/src/Data/provider.dart';

class ExpensesTogenerate extends StatefulWidget {
  const ExpensesTogenerate({Key? key}) : super(key: key);

  @override
  State<ExpensesTogenerate> createState() => _ExpensesTogenerateState();
}

class _ExpensesTogenerateState extends State<ExpensesTogenerate> {
  List<ExpenceInputModel> models = [];
  @override
  Widget build(BuildContext context) {
    models = Provider.of<ReportModel>(context).model;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Expences To Generate',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              m.ElevatedButton.icon(
                  onPressed: () {
                    Provider.of<ReportModel>(context, listen: false)
                        .addEmptyModel();
                    setState(() {});
                    totalBoxKey.currentState?.setState(() {});
                  },
                  icon: const Icon(FluentIcons.add),
                  label: const Text('Add Expence')),
            ],
          ),
          ListView.separated(
            separatorBuilder: (_, __) => const Divider(),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: models.length,
            itemBuilder: (context, int i) {
              return ExpenceModelForm(
                model: models[i],
                idx: i + 1,
                onDelete: () {
                  Provider.of<ReportModel>(context, listen: false)
                      .removeModel(models[i].uqIdx, true);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ExpenceModelForm extends StatefulWidget {
  final ExpenceInputModel model;
  final int idx;
  final Function() onDelete;
  const ExpenceModelForm(
      {Key? key,
      required this.model,
      required this.idx,
      required this.onDelete})
      : super(key: key);

  @override
  State<ExpenceModelForm> createState() => _ExpenceModelFormState();
}

class _ExpenceModelFormState extends State<ExpenceModelForm> {
  List<String> uqTypes = [];
  final TextStyle _prefixStyle = const TextStyle(fontWeight: FontWeight.bold);
  @override
  void didChangeDependencies() {
    uqTypes = Provider.of<ReportModel>(context).uqDataTypes;
    super.didChangeDependencies();
  }

  Widget get nametextBox => TextBox(
        prefix: Text(' Expence Name: ', style: _prefixStyle),
        onChanged: (v) => widget.model.details = v,
        controller: TextEditingController(text: widget.model.details),
        onSubmitted: (v) => updateTotal(),
      );
  Widget get typeCombox {
    if (!uqTypes.contains(widget.model.type) &&
        widget.model.type != fixedAmount) {
      uqTypes.add(widget.model.type);
    }
    return Combobox<String>(
      placeholder: const Text('Amount Type'),
      items: [fixedAmount, ...uqTypes]
          .map((e) => ComboboxItem(
              value: e,
              child: Text(e == fixedAmount ? fixedAmount : 'Percent of $e',
                  maxLines: 1)))
          .toList(),
      isExpanded: true,
      value: widget.model.type,
      onChanged: (String? c) {
        if (c != null) {
          setState(() {
            widget.model.type = c;
            if (widget.model.type != fixedAmount) {
              if (widget.model.value >= 100) {
                widget.model.value = 1;
              }
            }
          });
        }
      },
    );
  }

  Widget get valueBox => TextBox(
        prefix:
            Text(widget.model.type == fixedAmount ? ' Amt: ' : ' Percent: '),
        textAlign: TextAlign.right,
        suffix: Text(widget.model.type == fixedAmount ? '₹' : '%',
            style: _prefixStyle),
        onChanged: (v) =>
            widget.model.value = double.tryParse(v) ?? widget.model.value,
        onSubmitted: (v) {
          _cont4.text = widget.model.value.toStringAsFixed(2);
          updateTotal();
        },
        controller: _cont4,
      );

  Widget get intervalCombox => Tooltip(
        message: 'Expence Period',
        child: Combobox<DayInterval>(
          placeholder: const Text('Period Interval'),
          items: DayInterval.values
              .map((e) =>
                  ComboboxItem(value: e, child: Text(e.name, maxLines: 1)))
              .toList(),
          isExpanded: true,
          value: widget.model.interval,
          onChanged: (DayInterval? c) {
            if (c != null) {
              setState(() {
                widget.model.interval = c;
                widget.model.intervalGap = 1;
              });
            }
          },
        ),
      );
  Widget get timeMultipleCombox => Tooltip(
        message: 'Value will be this times\n'
            'Eg. if 10\'s, Then value will be 10,20,110...',
        child: Combobox<int>(
          placeholder: const Text('Amount Times'),
          items: [1, 10, 100, 1000]
              .map((e) => ComboboxItem(
                  value: e, child: Text('$e\'s Times', maxLines: 1)))
              .toList(),
          isExpanded: true,
          value: widget.model.multipleTimes,
          onChanged: (int? c) {
            if (c != null) {
              setState(() {
                widget.model.multipleTimes = c;
              });
            }
          },
        ),
      );

  Widget get intervalBox => TextBox(
      suffix: Text(' Times a ', style: _prefixStyle),
      textAlign: TextAlign.right,
      onChanged: (v) => widget.model.intervalGap =
          double.tryParse(v) ?? widget.model.intervalGap,
      controller: _contintGap,
      onSubmitted: (_) => updateTotal());
  Widget get intervalVaryBox => Tooltip(
        message: 'Day Interval is allowed to vary with given range',
        child: TextBox(
          prefix: const Text(' Day Vary Rg: '),
          textAlign: TextAlign.right,
          onChanged: (v) => widget.model.intervalRange =
              int.tryParse(v) ?? widget.model.intervalRange,
          controller: _contintRg,
          onSubmitted: (_) => updateTotal(),
        ),
      );
  Widget get valueVaryBox => Tooltip(
        message: 'Expence Value is allowed to vary with given range',
        child: TextBox(
          prefix: const Text(' Expence Vary Rg: '),
          textAlign: TextAlign.right,
          onChanged: (v) => widget.model.varyRange =
              double.tryParse(v) ?? widget.model.varyRange,
          controller: _contvaryRange,
          onSubmitted: (_) => updateTotal(),
        ),
      );

  void updateTotal() {
    _key.currentState?.setState(() {});
    ReportModel.updateModel(widget.model);
    totalBoxKey.currentState?.setState(() {});
  }

  final GlobalKey _key = GlobalKey();

  final TextEditingController _cont4 = TextEditingController();
  final TextEditingController _contintGap = TextEditingController();
  final TextEditingController _contintRg = TextEditingController();
  final TextEditingController _contvaryRange = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ReportModel.updateModel(widget.model);
    _cont4.text = widget.model.value.toStringAsFixed(2);
    _contintGap.text = widget.model.intervalGap.toStringAsFixed(2);
    _contintRg.text = widget.model.intervalRange.toStringAsFixed(0);
    _contvaryRange.text = widget.model.varyRange.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(border: Border.all()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: nametextBox,
                ),
                IconButton(
                    icon: Icon(FluentIcons.delete, color: Colors.red.dark),
                    onPressed: widget.onDelete)
              ],
            ),
            Row(
              children: [
                Expanded(flex: 3, child: typeCombox),
                const SizedBox(width: 5),
                Expanded(flex: 2, child: valueBox),
              ],
            ),
            Row(
              children: [
                Expanded(flex: 2, child: intervalBox),
                const SizedBox(width: 5),
                Expanded(flex: 2, child: intervalCombox),
                const SizedBox(width: 5),
                Expanded(flex: 1, child: timeMultipleCombox),
              ],
            ),
            Row(
              children: [
                Expanded(flex: 5, child: valueVaryBox),
                const SizedBox(width: 5),
                Expanded(flex: 4, child: intervalVaryBox),
              ],
            ),
            ExpenceModelSummary(key: _key, model: widget.model)
          ],
        ),
      ),
    );
  }
}

class ExpenceModelSummary extends StatefulWidget {
  final ExpenceInputModel model;
  const ExpenceModelSummary({Key? key, required this.model}) : super(key: key);

  @override
  State<ExpenceModelSummary> createState() => _ExpenceModelSummaryState();
}

class _ExpenceModelSummaryState extends State<ExpenceModelSummary> {
  @override
  Widget build(BuildContext context) {
    TextStyle _symbStyle = const TextStyle(fontWeight: FontWeight.bold);
    final totals =
        Provider.of<ReportModel>(context).getExpenceTotal(widget.model);
    return Container(
      color: m.Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(totals.amount.toStringAsFixed(2) + ' ₹ '),
            Text('x', style: _symbStyle),
            Text(totals.times.toString() + ' # '),
            Text(' = ', style: _symbStyle),
            Text(totals.total.toStringAsFixed(2) + ' ₹ ', style: _symbStyle),
            Text('[ ± ${totals.varyRg.ceil()}]'),
          ],
        ),
      ),
    );
  }
}
