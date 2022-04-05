import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'Album.dart';

void main() => runApp(const ListApp());

class ListApp extends StatelessWidget {
  const ListApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ListAppHome(),
    );
  }
}

class ListAppHome extends StatefulWidget {
  const ListAppHome({Key? key}) : super(key: key);

  @override
  _ListAppHome createState() => _ListAppHome();
}

class _ListAppHome extends State<ListAppHome> {
  late Future<List<Album>> _albuns;

  @override
  void initState() {
    super.initState();

    _albuns = fetchAlbum();
    _albuns.then(
      (value) => print(value[0].userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: FutureBuilder<List<Album>>(
        future: _albuns,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => TextButton(
                onPressed: () {
                  SnackBar snackBar = SnackBar(
                    content: Text(
                      'Cê pressionou o album ${snapshot.data![index].id}',
                      textAlign: TextAlign.center,
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      snapshot.data![index].title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    ));
  }
}

Future<List<Album>> fetchAlbum() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> listAlbuns = jsonDecode(response.body);
    return List.generate(100, (index) => Album.fromJson(listAlbuns[index]));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
