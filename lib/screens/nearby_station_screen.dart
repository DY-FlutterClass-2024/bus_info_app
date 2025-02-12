import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'map_view_screen.dart'; // Add this line

class NearbyStationScreen extends StatefulWidget {
  const NearbyStationScreen({Key? key}) : super(key: key);

  @override
  NearbyStationScreenState createState() => NearbyStationScreenState();
}

class NearbyStationScreenState extends State<NearbyStationScreen> {
  late Future<List<dynamic>> futureStations = Future.value([]);
  DateTime? lastUpdated;
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<List<dynamic>> fetchStations(double x, double y) async {
    final response = await http.get(Uri.parse('http://api.szk.kr/businfo/station/search/coor?x=$x&y=$y'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      lastUpdated = DateTime.now();
      return data['response']['body']['result']['busStationAroundList'];
    } else {
      throw Exception('Failed to load stations');
    }
  }

  Future<void> _getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      futureStations = fetchStations(_locationData.longitude!, _locationData.latitude!);
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }
  
  Future<void> _refresh() async {
    await _getLocation();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<dynamic>>(
            future: futureStations,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return ListView(
                  children: [
                    SizedBox(height: 16),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('정보를 불러오는 중 오류가 발생했습니다.'),
                          Text('잠시 후 다시 시도해주세요.'),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return ListView(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          Text('현재 위치 주변에 정류소가 없습니다.')
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length + 1,
                  itemBuilder: (context, index) {
                    if (index == snapshot.data!.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            '${_locationData.latitude != null ? _locationData.latitude.toString() : 'N/A'}, ${_locationData.longitude != null ? _locationData.longitude.toString() : 'N/A'}\n'
                            '마지막 갱신 시간: ${lastUpdated != null ? lastUpdated!.toLocal().toString() : 'N/A'}\n',
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),
                      );
                    } else {
                      final station = snapshot.data![index];
                      return Card(
                        margin: EdgeInsets.only(top: 16, left: 12.0, right: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapViewScreen(stationId: station['stationId'].toString()),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: Icon(Icons.directions_bus, size: 40, color: Colors.white),
                            title: Text(
                              station['stationName'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('정류장번호: ${station['mobileNo']}\n거리: ${station['distance']}m'),
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}