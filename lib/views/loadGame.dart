import 'dart:convert';

import 'package:akari/models/action.dart';
import 'package:flutter/material.dart';
import 'package:akari/utils/save.dart';
import 'package:akari/models/grid.dart';
import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';

class GamesListPage extends StatefulWidget {
  final SaveMode mode;

  GamesListPage({required this.mode});

  @override
  _GamesListPageState createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  late Future<List<Map<String, Object?>>> games;

  @override
  void initState() {
    super.initState();
    games = getAllGames(widget.mode);
  }

  void loadGame(Map<String, Object?> gameData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GridWidget(
        grid:Grid.loadGrid(
          creationTime: gameData['creation_time'] as int,
          time: gameData['time_spent'] as int,
          difficulty: gameData['difficulty'] as int,
          gridSize: gameData['size'] as int,
          startGrid: (jsonDecode(gameData['start_grid'] as String) as List)
        .map((item) => (item as List).map((i) => i as int).toList())
        .toList(),
          lights: (jsonDecode(gameData['lights'] as String) as List)
    .map((item) => Tuple2<int, int>((item as List)[0] as int, (item as List)[1] as int))
    .toList(),
          actions: (jsonDecode(gameData['actions'] as String) as List)
    .map((item) => GridAction.fromMap(item as Map<String, Object>)!)
    .toList(),
        
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parties en cours'),
      ),
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: games,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des parties'));
          }

          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune partie en cours'));
          }



return ListView.builder(
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
    Map<String, dynamic> gameData = snapshot.data![index];

    int creationTime = gameData['creation_time'] as int;
    String dateCreation = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(creationTime * 1000));
  
    int difficulty = gameData['difficulty'] as int;
    int size = gameData['size'] as int;
    int time = gameData['time_spent'] as int;

int hours = time ~/ 3600;
int minutes = (time % 3600) ~/ 60;
int seconds = time % 60;

String formattedTime = '$hours h $minutes min $seconds sec';

    return Card(
  elevation: 4,
  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: ListTile(
    title: Text(
      'Partie: $dateCreation',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Difficulté: $difficulty'),
          SizedBox(height: 5),
          Text('Taille: $size'),
          SizedBox(height: 5),
          Text('Temps passé: $formattedTime'),
        ],
      ),
    ),
    onTap: () {
      loadGame(gameData);
    },
  ),
);

  },
);




        },
      ),
    );
  }
}
