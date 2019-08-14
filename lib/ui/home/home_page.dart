import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gif_searcher/ui/gif/gif_page.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final String urlTrendGifs =
      'https://api.giphy.com/v1/gifs/trending?api_key=F8XJMOfFz6wl6tezeoQlWheYLY7i4LPG&limit=20&rating=G';
  String _searchWord;
  int _offsetSearch = 0;

  Future<Map> _getSearchGifs() async {
    http.Response response;

    if (_searchWord == null || _searchWord.isEmpty) {
      response = await http.get(urlTrendGifs);
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=F8XJMOfFz6wl6tezeoQlWheYLY7i4LPG&q=$_searchWord&limit=20&offset=$_offsetSearch&rating=G&lang=en');
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getSearchGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _searchWord = text;
                  _offsetSearch = 0;
                });
              },
              decoration: InputDecoration(
                  labelText: 'Pesquisar GIF',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getSearchGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Container();
                      } else {
                        return _createGifTable(context, snapshot);
                      }
                  }
                }),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_searchWord == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (_searchWord == null || index < snapshot.data['data'].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data['data'][index]['images']['fixed_height']['url'],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => GifPage(snapshot.data['data'][index])));
              },
              onLongPress: (){
                Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
              },
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0),
                    Text('Carregar mais...',
                        style: TextStyle(color: Colors.white, fontSize: 15.0))
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offsetSearch += 25;
                  });
                },
              ),
            );
          }
        });
  }
}
