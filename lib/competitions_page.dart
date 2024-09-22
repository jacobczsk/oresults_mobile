import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_bar.dart';
import 'oresults_api.dart';
import 'competition_page.dart';

class CompetitionsPage extends StatelessWidget {
  const CompetitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: OResultsAPI.getCompetitions(),
        builder: (BuildContext context,
            AsyncSnapshot<List<OResultsCompetition>> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: ORMBar(context),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final data = snapshot.data!;
          final DateFormat fmt = DateFormat("dd. MM. yyyy, HH:mm");

          return Scaffold(
              appBar: ORMBar(context),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int idx) {
                      final OResultsCompetition comp = data[idx];
                      return OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CompetitionPage(comp: comp)));
                          },
                          style: ButtonStyle(
                              side: WidgetStateProperty.all(BorderSide.none),
                              shape: WidgetStateProperty.all(
                                  const RoundedRectangleBorder()),
                              alignment: Alignment.topLeft,
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.all(8))),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fmt.format(comp.dateTime),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal)),
                                Text(comp.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Row(children: [
                                  SvgPicture.network(
                                      "https://oresults-flags.b-cdn.net/country-flag-icons/3x2/${comp.country}.svg",
                                      height: 12),
                                  const SizedBox(width: 5),
                                  Text(comp.place),
                                ]),
                                Text(comp.organizer,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal)),
                              ]));
                    }),
              ));
        });
  }
}
