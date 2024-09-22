import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'oresults_api.dart';
import 'dart:async';
import 'app_bar.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key, required this.comp, required this.cls});

  final OResultsCompetition comp;
  final OResultsClass cls;

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  Timer? updateTimer;
  bool radioControls = false;

  static String formatStatus(String status) {
    return status.split("").where((a) => a == a.toUpperCase()).toList().join();
  }

  @override
  void initState() {
    super.initState();
    updateTimer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.comp.fetchChanges(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: ORMBar(context),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final DateFormat globalTimeFmt = DateFormat("dd. MM. yyyy, HH:mm");
          final DateFormat runTimeFmt = DateFormat("HH:mm:ss");

          List<OResultsRunner> okRunners = [];
          List<OResultsRunner> inForestRunners = [];
          List<OResultsRunner> notOkRunners = [];

          final int now = DateTime.now().toUtc().millisecondsSinceEpoch;

          for (var runner in widget.comp.runners) {
            if (runner.className == widget.cls.name) {
              if (runner.finishTime == null) {
                runner.runTime = now - runner.startTime!;
              }

              switch (runner.resultStatus) {
                case "OK":
                  okRunners.add(runner);
                  break;
                case null:
                  inForestRunners.add(runner);
                  break;
                default:
                  notOkRunners.add(runner);
              }
            }
          }

          okRunners.sort((a, b) => a.runTime!.compareTo(b.runTime!));
          inForestRunners.sort((a, b) {
            int cmp = a.runTime!.compareTo(b.runTime!);
            if (cmp != 0) {
              return cmp;
            }
            return a.name.compareTo(b.name);
          });
          notOkRunners.sort((a, b) => a.name.compareTo(b.name));

          final List<OResultsRunner> classRunners =
              okRunners + inForestRunners + notOkRunners;
          int winTime = okRunners[0].runTime!;

          List<TableRow> table = [];
          int counter = 1;
          int lastTime = 0;
          int lastPlace = 0;

          for (var runner in classRunners) {
            String place = "";
            if (runner.runTime != lastTime) {
              lastPlace = counter;
            }

            if (runner.resultStatus != null) {
              place = "${(lastPlace).toString()}.";
            }
            String runTime = runTimeFmt.format(
                DateTime.fromMillisecondsSinceEpoch(runner.runTime!).toUtc());
            String loss =
                "+${runTimeFmt.format(DateTime.fromMillisecondsSinceEpoch(runner.runTime! - winTime).toUtc())}";

            if (!["OK", null].contains(runner.resultStatus)) {
              runTime = "";
              loss = "";
              place = formatStatus(runner.resultStatus!);
            }

            lastTime = runner.runTime!;
            counter++;

            table.add(TableRow(children: [
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(place)),
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(runner.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(runner.club,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary))
                      ])),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(runTime),
                Text(loss,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary))
              ])
            ]));
          }

          return Scaffold(
              appBar: ORMBar(context),
              body: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                                side: WidgetStateProperty.all(BorderSide.none),
                                shape: WidgetStateProperty.all(
                                    const RoundedRectangleBorder()),
                                alignment: Alignment.centerLeft,
                                minimumSize: WidgetStateProperty.all(Size.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(4))),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                      globalTimeFmt
                                          .format(widget.comp.dateTime),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.left),
                                  Text(widget.comp.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Row(children: [
                                    SvgPicture.network(
                                        "https://oresults-flags.b-cdn.net/country-flag-icons/3x2/${widget.comp.country}.svg",
                                        height: 12),
                                    const SizedBox(width: 5),
                                    Text(widget.comp.place),
                                  ]),
                                  Text(widget.comp.organizer,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal)),
                                ])),
                        const Divider(),
                        Row(children: [
                          Expanded(
                              child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ButtonStyle(
                                      side: WidgetStateProperty.all(
                                          BorderSide.none),
                                      shape: WidgetStateProperty.all(
                                          const RoundedRectangleBorder()),
                                      alignment: Alignment.centerLeft,
                                      minimumSize:
                                          WidgetStateProperty.all(Size.zero),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: WidgetStateProperty.all(
                                          const EdgeInsets.all(4))),
                                  child: Text(widget.cls.displayName,
                                      style: const TextStyle(fontSize: 15)))),
                          const Text("Radiokontroly"),
                          Checkbox(
                              value: radioControls,
                              onChanged: (bool? val) {
                                setState(() {
                                  radioControls = val!;
                                });
                              })
                        ]),
                        const Divider(),
                        Expanded(
                            child: SingleChildScrollView(
                                child: Table(columnWidths: const {
                          0: MinColumnWidth(
                              IntrinsicColumnWidth(), FractionColumnWidth(.15)),
                          1: MinColumnWidth(
                              IntrinsicColumnWidth(), FractionColumnWidth(.7)),
                          2: MinColumnWidth(
                              IntrinsicColumnWidth(), FractionColumnWidth(.25))
                        }, children: table)))
                      ])));
        });
  }

  @override
  void dispose() {
    super.dispose();
    updateTimer?.cancel();
  }
}
