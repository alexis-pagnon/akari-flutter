import 'package:flutter/material.dart';
import 'package:akari/utils/save.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  final SaveMode mode;

  const History({super.key, required this.mode});

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<History> {
  late Future<List<Map<String, Object?>>> games;

  @override
  void initState() {
    super.initState();
    games = getAllGames(widget.mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parties Terminées'),
      ),
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: games,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Erreur de chargement des parties'));
          }

          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune partie terminée'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> gameData = snapshot.data![index];

              int creationTime = gameData['creation_time'] as int;
              String dateCreation = DateFormat('dd-MM-yyyy HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(creationTime * 1000));

              int difficulty = gameData['difficulty'] as int;
              int size = gameData['size'] as int;
              int time = gameData['time_spent'] as int;

              int hours = time ~/ 3600;
              int minutes = (time % 3600) ~/ 60;
              int seconds = time % 60;

              String formattedTime = '$hours h $minutes min $seconds sec';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    'Partie: $dateCreation',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Difficulté: $difficulty'),
                        const SizedBox(height: 5),
                        Text('Taille: $size'),
                        const SizedBox(height: 5),
                        Text('Temps passé: $formattedTime'),
                      ],
                    ),
                  ),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
