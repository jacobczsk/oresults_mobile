import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'oresults_api.dart';
import 'app_bar.dart';
import 'class_page.dart';

class CompetitionPage extends StatefulWidget {
  const CompetitionPage({super.key, required this.comp});

  final OResultsCompetition comp;

  @override
  State<CompetitionPage> createState() => _CompetitionPageState();
}

class _CompetitionPageState extends State<CompetitionPage> {
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    updateTimer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => setState(() {}));
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

          final DateFormat fmt = DateFormat("dd. MM. yyyy, HH:mm");
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
                                  Text(fmt.format(widget.comp.dateTime),
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
                        Expanded(
                            child: ListView.separated(
                                itemCount: widget.comp.classes.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(height: 0),
                                itemBuilder: (BuildContext context, int idx) {
                                  final OResultsClass cls =
                                      widget.comp.classes[idx];
                                  return OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ClassPage(
                                                    comp: widget.comp,
                                                    cls: cls)));
                                      },
                                      style: ButtonStyle(
                                          side: WidgetStateProperty.all(
                                              BorderSide.none),
                                          shape: WidgetStateProperty.all(
                                              const RoundedRectangleBorder()),
                                          alignment: Alignment.centerLeft,
                                          minimumSize: WidgetStateProperty.all(
                                              Size.zero),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: WidgetStateProperty.all(
                                              const EdgeInsets.all(4))),
                                      child: Text(cls.displayName,
                                          style:
                                              const TextStyle(fontSize: 15)));
                                }))
                      ])));
        });
  }

  @override
  void dispose() {
    super.dispose();
    updateTimer?.cancel();
  }
}
