import 'package:http/http.dart' as http;
import 'dart:convert';

class OResultsAPI {
  static Future<List<OResultsCompetition>> getCompetitions() async {
    final response =
        await http.get(Uri.parse("https://cdn.oresults.eu/events"));
    if (response.statusCode ~/ 100 != 2) {
      throw Exception("Status code != 2xx");
    }

    final dynamic rjson = jsonDecode(utf8.decode(response.bodyBytes));
    List<OResultsCompetition> result = [];

    for (var comp in rjson) {
      result.add(OResultsCompetition.fromJson(comp));
    }

    return result;
  }
}

class OResultsCompetition {
  final int id;
  final String name, organizer, place, country;
  final DateTime dateTime;

  int lastChange = 0;
  List<OResultsClass> classes = [];
  List<OResultsRunner> runners = [];

  OResultsCompetition(this.id, this.name, this.organizer, this.place,
      this.country, this.dateTime);

  static OResultsCompetition fromJson(Map<String, dynamic> json) {
    if (json["place"] == null) {
      json["place"] = "";
    }
    if (json["countryCode"] == null) {
      json["countryCode"] = "CZ";
    }
    return OResultsCompetition(
      json["id"],
      json["name"],
      json["organizer"],
      json["place"],
      json["countryCode"],
      DateTime.parse(json["date"]).toLocal(),
    );
  }

  Future<bool> fetchChanges() async {
    final response = await http.get(Uri.parse(
        "https://cdn.oresults.eu/events/$id/changes?since=$lastChange"));
    if (response.statusCode ~/ 100 != 2) {
      throw Exception("Status code != 2xx");
    }

    final Map<String, dynamic> json =
        jsonDecode(utf8.decode(response.bodyBytes));

    for (var cls in json["classes"]) {
      classes.add(OResultsClass.fromJson(cls));
    }
    for (var runner in json["runners"]) {
      runners.add(OResultsRunner.fromJson(runner));
    }
    lastChange = json["lastChangeId"];

    return true;
  }
}

class OResultsClass {
  final int id, leg, legCount;
  final String name, displayName;
  final List<OResultsControl> controls;

  OResultsClass(this.id, this.leg, this.legCount, this.name, this.controls,
      this.displayName);

  static OResultsClass fromJson(Map<String, dynamic> json) {
    List<OResultsControl> rcontrols = [];
    for (var control in json["controls"]) {
      rcontrols.add(OResultsControl.fromJson(control));
    }

    String displayName = json["name"];
    if (json["leg"] != 0) {
      displayName += "-${json["leg"]}";
    }

    return OResultsClass(json["id"], json["leg"], json["legCount"],
        json["name"], rcontrols, displayName);
  }
}

class OResultsControl {
  final int code, changeId;
  final double? distance;
  final String? name;

  OResultsControl(this.code, this.changeId, this.distance, this.name);

  static OResultsControl fromJson(Map<String, dynamic> json) {
    return OResultsControl(
        json["code"], json["changeId"], json["distance"], json["name"]);
  }
}

class OResultsRunner {
  final String importId, name, club, className;
  final String? resultStatus;
  final int? leg, cardNum, startTime, finishTime;
  int? runTime;

  OResultsRunner(
      this.importId,
      this.name,
      this.club,
      this.className,
      this.resultStatus,
      this.leg,
      this.cardNum,
      this.startTime,
      this.finishTime,
      this.runTime);

  static fromJson(Map<String, dynamic> json) {
    int? runTime;

    if (json["finishTime"] != null && json["startTime"] != null) {
      runTime = json["finishTime"] - json["startTime"];
    } else {
      runTime = null;
    }

    return OResultsRunner(
        json["importId"],
        json["name"],
        json["club"],
        json["className"],
        json["resultStatus"],
        json["leg"],
        json["cardNum"],
        json["startTime"],
        json["finishTime"],
        runTime);
  }
}
