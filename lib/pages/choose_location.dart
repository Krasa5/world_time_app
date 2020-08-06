import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:world_time_app/services/world_time.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../services/world_time.dart';

class ChooseLocation extends StatefulWidget {
  @override
  _ChooseLocationState createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  List data = List(); // store the json response here
  List<WorldTime> locations =
      List(); // loop the data in json response into this variable
  List filteredLocations = List();

  Future<void> getLocs() async {
    Response response = await get('http://worldtimeapi.org/api/timezone');
    List data = jsonDecode(response.body);
    final List data2 = data;
    if (filteredLocations.isEmpty) {
      setState(() {
        locations = [for (String url in data) WorldTime(url: url)];
        filteredLocations = data;
      });
    } else {
      setState(() {
        locations = [for (String url in filteredLocations) WorldTime(url: url)];
      });
      filteredLocations = data2;
    }
  }

  void updateTime(index) async {
    WorldTime instance = locations[index];
    await instance.getTime();
    // goes back to home
    Navigator.pop(context, {
      'url': instance.url,
      'time': instance.time,
      'isDaytime': instance.isDaytime,
    });
  }

  @override
  void initState() {
    super.initState();
    getLocs();
  }

  void _filterCountries(value) {
    //remove all elements in list which contains "Africa"
    filteredLocations
        .removeWhere((element) => !element.toLowerCase().contains(value));
    print(filteredLocations);
    if (filteredLocations.isEmpty) {
      Fluttertoast.showToast(
          msg: "Not found.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      getLocs();
    }
  }

  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: !isSearching
            ? Text('Choose a city')
            : TextField(
                onSubmitted: (value) {
                  _filterCountries(value);
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search for countries',
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          isSearching
              ? IconButton(
                  // if isSearching is True show Icon to Cancel
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                      filteredLocations = [];
                      getLocs();
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
                ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
                child: Card(
                  child: ListTile(
                    onTap: () {
                      updateTime(index);
                    },
                    title: Text(locations[index].url),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
