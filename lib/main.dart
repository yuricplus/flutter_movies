import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:math' as math;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Movie {
  final Map date;
  final int page;
  final List results;

  const Movie({ required this.date,
    required this.results,
    required this.page,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      date: json['date'],
      page: json['page'],
      results: json['results']
    );
  }
}

Future<Movie> getMovies() async {
  var params = { 'api_key': '10ac6b308154d8d3da2368d25caa4778', 'language': 'pt-BR', 'page': '2' };
  var url = Uri.http('api.themoviedb.org', '/3/movie/upcoming', params);

  var response = await http.get(url);
  if(response.statusCode == 200) {
    var jsonResponse =
    convert.jsonDecode(response.body) as Map<String, dynamic>;

    return Movie(date: jsonResponse['dates'], results: jsonResponse['results'], page: jsonResponse['page']);
  }
  return throw Exception('Failed to get information Movies');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const Color white = Color(0xFFFFFFFF);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Colors.red,
          splashColor: Colors.red
      ),
      home: const MyHomePage(title: 'Movie In Threat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Movie>? _movie;

  @override
  void initState() {
    super.initState();
    _movie = getMovies();
  }

  void _incrementCounter() {
    setState(() {

    });
  }

  Widget getTextWidgets(List<String> strings)
  {
    return Row(children: strings.map((item) => Text(item)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        foregroundColor: Colors.black87,
        shadowColor: null,
        elevation: 0,
        backgroundColor: Colors.white,
        excludeHeaderSemantics: false,
      ),
      body: Center(
        child: FutureBuilder<Movie>(
          future: _movie,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {
              if(snapshot.hasData) {
                var baseUrl = 'https://image.tmdb.org/t/p/original';
                return ListView(
                  padding: const EdgeInsets.all(8),
                    children: snapshot.data!.results.map((item) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.7)
                      ),
                        padding: const EdgeInsets.all(10.0),
                        margin: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Image.network(
                                    baseUrl + item['poster_path'],
                                    width: 105,
                                    height: 100,
                                    errorBuilder: (context, exception, stackTrack) => Icon(Icons.error)
                                )
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                    child: Text(
                                      item['title'],
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white),
                                    )
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                      'Movie',
                                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white),
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                    ),
                    ).toList()
                );
              } else if (snapshot.hasError) {
                return Text('error ${snapshot.error}');
              }
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
