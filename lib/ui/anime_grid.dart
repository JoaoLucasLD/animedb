import 'dart:convert';
import 'package:favorite_button/favorite_button.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateAnimeGrid extends StatefulWidget {
  const CreateAnimeGrid({Key? key}) : super(key: key);

  @override
  State<CreateAnimeGrid> createState() => _CreateAnimeGridState();
}

class _CreateAnimeGridState extends State<CreateAnimeGrid> {
  int _page = 1;
  int _selectedIndex = 0;

  Future<Map> _getAnime() async {
    http.Response response;
    response = await http.get("https://api.jikan.moe/v4/top/anime?page=$_page");
    return json.decode(response.body);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

    List<Map<String, dynamic>> _selectedAnime = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('AnimeDB'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
                future: _getAnime(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 400,
                        height: 400,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Container();
                      } else {
                        return _createAnimeGrid(context, snapshot);
                      }
                  }
                }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outlined),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Colors.red,
        elevation: 4,
      ),
    );
  }

  int _getCount(List data) {
    return data.length + 1;
  }

  int _getCountFavorite(List data) {
    return data.length;
  }

  Widget _createAnimeGrid(BuildContext context, AsyncSnapshot snapshot) {

    if (_selectedIndex == 1) {
      print(_selectedAnime);
      return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 30.0,
            mainAxisExtent: 331.0,
          ),
          itemCount: _getCountFavorite(_selectedAnime),
          itemBuilder: (context, index) {
            return Wrap(
              children: [
                FadeInImage.memoryNetwork(
                  image: _selectedAnime[index]["images"]["jpg"]
                      ["large_image_url"],
                  height: 280.0,
                  // width: 300.0,
                  fit: BoxFit.fill,
                  placeholder: kTransparentImage,
                ),
                //  SizedBox(height: 10.0,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 3.0),
                  child: Text(
                      "${_selectedAnime[index]["rank"]} - ${_selectedAnime[index]["title"]}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          });
    } else {
      return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 30.0,
            mainAxisExtent: 331.0,
          ),
          itemCount: _getCount(snapshot.data["data"]),
          itemBuilder: (context, index) {
            if (index < snapshot.data["data"].length) {
              return Stack(
                children: [
                  Wrap(
                    children: [
                      FadeInImage.memoryNetwork(
                        //Testando com imagem de internet
                        image: snapshot.data["data"][index]["images"]["jpg"]
                            ["large_image_url"],
                        height: 280.0,
                        // width: 300.0,
                        fit: BoxFit.fill,
                        placeholder: kTransparentImage,
                      ),
                      //  SizedBox(height: 10.0,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 3.0),
                        child: Text(
                            "${snapshot.data["data"][index]["rank"]} - ${snapshot.data["data"][index]["title"]}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Positioned(
                      top: 12.5,
                      right: 12.5,
                      child: FavoriteButton(
                        isFavorite: false,
                        iconSize: 48.0,
                        valueChanged: (_) {
                          _selectedAnime.add(snapshot.data["data"][index]);
                          print(_selectedAnime);
                        },
                      ))
                ],
              );
            } else if (_page == 1 || index > snapshot.data["data"].length) {
              return GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_circle_right_sharp,
                        color: Colors.white, size: 70.0),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _page += 1;
                  });
                },
              );
            } else {
              return GestureDetector(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                          child: const Icon(Icons.arrow_circle_up_sharp,
                              color: Colors.white, size: 70.0),
                          onTap: () {
                            setState(() {
                              _page -= 1;
                            });
                          }),
                      SizedBox(height: 100.0),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0),
                        child: GestureDetector(
                            child: const Icon(Icons.arrow_circle_down_sharp,
                                color: Colors.white, size: 70.0),
                            onTap: () {
                              setState(() {
                                _page += 1;
                              });
                            }),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    _page += 1;
                  });
                },
              );
            }
          });
    }
  }
}
