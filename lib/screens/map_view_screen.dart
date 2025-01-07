import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../styles/_dark_map_style.dart';

class MapViewScreen extends StatefulWidget {
  final String? stationId;

  const MapViewScreen({super.key, this.stationId});

  @override
  MapViewScreenState createState() => MapViewScreenState();
}

class MapViewScreenState extends State<MapViewScreen> {
  late GoogleMapController mapController;
  LocationData? currentLocation;
  final Location location = Location();
  final LatLng _defaultLocation = const LatLng(37.241369, 127.215994);
  Set<Marker> _markers = {};
  LatLng? _currentMapPosition;
  BitmapDescriptor? busIcon;
  bool isBottomSheetVisible = false;
  Map<String, dynamic>? selectedStation;
  List<dynamic> busArrivalList = [];
  bool isLoading = false;
  bool hasError = false;
  String? _selectedMarkerId;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _loadBusIcon();
  }

  void _loadBusIcon() async {
    busIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/bus_icon.png',
    );
  }

  void _getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentLocation = await location.getLocation();
    setState(() {
      _currentMapPosition = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    });
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    if (_currentMapPosition == null) return;

    final response = await http.get(Uri.parse(
        'http://api.szk.kr/businfo/station/search/coor?x=${_currentMapPosition!.longitude}&y=${_currentMapPosition!.latitude}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final stations = data['response']['body']['result']['busStationAroundList'];
      _addMarkers(stations);
      if (widget.stationId != null) {
        _showSelectedStation(widget.stationId!);
      }
    } else {
      _showFetchError();
      throw Exception('Failed to load stations');
    }
  }

  void _addMarkers(List<dynamic> stations) {
    Set<Marker> markers = {};
    for (var station in stations) {
      final marker = Marker(
        markerId: MarkerId(station['stationId'].toString()),
        position: LatLng(double.parse(station['y']), double.parse(station['x'])),
        icon: _selectedMarkerId == station['stationId'].toString()
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : busIcon ?? BitmapDescriptor.defaultMarker,
        onTap: () {
          setState(() {
            _selectedMarkerId = station['stationId'].toString();
            selectedStation = station;
            isBottomSheetVisible = true;
            isLoading = true;
            hasError = false;
            busArrivalList = [];
          });
          _fetchBusArrival(station['stationId']);
        },
      );
      markers.add(marker);
    }
    setState(() {
      _markers = markers;
    });
  }

  void _showSelectedStation(String stationId) {
    final selectedMarker = _markers.firstWhere((marker) => marker.markerId.value == stationId);
    mapController.animateCamera(CameraUpdate.newLatLng(selectedMarker.position));
    selectedMarker.onTap!();
  }

  Future<void> _fetchBusArrival(String stationId) async {
    try {
      final response = await http.get(Uri.parse(
          'http://api.szk.kr/businfo/station/search/arvlbus?stationId=$stationId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          busArrivalList = data['response']['body']['result']['busArrivalList'] ?? [];
          if (busArrivalList is Map) {
            busArrivalList = [busArrivalList];
          }

          busArrivalList.sort((a, b) {
            final timeA = int.tryParse(a['predictTime1'] ?? '0') ?? 0;
            final timeB = int.tryParse(b['predictTime1'] ?? '0') ?? 0;
            return timeA.compareTo(timeB);
          });

          isLoading = false;
        });

        for (var bus in busArrivalList) {
          final routeId = bus['routeId'];
          _fetchBusRouteInfo(routeId, bus);
        }
      } else {
        throw Exception('Failed to load bus arrivals');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _fetchBusRouteInfo(String routeId, Map<String, dynamic> bus) async {
    try {
      final response = await http
          .get(Uri.parse('http://api.szk.kr/businfo/bus/search/info?routeId=$routeId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final busRouteInfo = data['response']['body']['result']['busRouteInfoItem'];
        setState(() {
          bus['routeName'] = busRouteInfo['routeName'];
          bus['routeTypeCd'] = busRouteInfo['routeTypeCd'];
        });
      } else {
        // Skip this bus instead of flagging the entire screen as error
        setState(() {
          busArrivalList.remove(bus);
        });
      }
    } catch (e) {
      // If something goes wrong, just remove this bus
      setState(() {
        busArrivalList.remove(bus);
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(darkMapStyle);
    if (currentLocation != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          17.0,
        ),
      );
    } else {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          _defaultLocation,
          17.0,
        ),
      );
    }
  }

  Color getRouteColor(dynamic routeTypeCd) {
    switch (routeTypeCd) {
      case '11':
        return Colors.red;
      case '13':
        return Colors.green;
      case '30':
        return Colors.yellow;
      case '51':
        return Colors.brown;
      default:
        return Colors.white;
    }
  }

  void _showFetchError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('버스 정류장 정보를 불러오는데 실패했습니다.\n다시 시도해주세요.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentLocation != null
                  ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
                  : _defaultLocation,
              zoom: 17.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            onCameraMove: (position) {
            setState(() {
                _currentMapPosition = position.target;
              });
            },
            onCameraIdle: () {
              _fetchStations();
            },
          ),
          if (isBottomSheetVisible && selectedStation != null)
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.4,
              maxChildSize: 0.7,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D1B20),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Center(
                            child: Text(
                              selectedStation!['stationName'],
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Center(
                            child: Text(
                              '${selectedStation!['distance']}m | ${selectedStation!['mobileNo']} | ${selectedStation!['regionName']} | ${selectedStation!['stationId']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 8.0),
                          if (isLoading)
                            Center(child: CircularProgressIndicator())
                          else if (hasError)
                            Center(
                              child: Text(
                                '결과가 존재하지 않습니다.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          else
                            ...busArrivalList.map((bus) {
                              return ListTile(
                                leading: Icon(
                                  Icons.directions_bus,
                                  color: getRouteColor(bus['routeTypeCd']),
                                  size: 56,
                                ),
                                title: Text(
                                  (bus['routeName'] == null || bus['routeName'].toString().contains('null'))
                                    ? '불러오는중...'
                                    : '${bus['routeName']}번',
                                  style: TextStyle(fontSize: 24, color: getRouteColor(bus['routeTypeCd'])),
                                ),
                                subtitle: Text(
                                  '도착까지 ${bus['predictTime1']}분',
                                  style: const TextStyle(fontSize: 14, color: Colors.white),
                                ),
                                trailing:
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black
                                    ),
                                    onPressed: () {
                                      final busRouteName = bus['routeName'];
                                      int selectedNotificationTime = 5; // 기본 알림 시간

                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: const Color(0xFF1D1B20),
                                            title: const Text('승차 예약', style: TextStyle(color: Colors.white)),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('$busRouteName', style: TextStyle(fontSize: 48, color: getRouteColor(bus['routeTypeCd']))),
                                                Text('도착까지 ${bus['predictTime1']}분', style: const TextStyle(fontSize: 14, color: Colors.white54
                                                )),
                                                const SizedBox(height: 16.0),
                                                Text('몇 분 전에 알림을 받을까요?', style: const TextStyle(color: Colors.white)),
                                                DropdownButton<int>(
                                                  dropdownColor: const Color(0xFF1D1B20),
                                                  value: selectedNotificationTime,
                                                  items: List.generate(13, (index) => index + 3).map((int value) {
                                                    return DropdownMenuItem<int>(
                                                      value: value,
                                                      child: Text('$value분 전', style: const TextStyle(color: Colors.white)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedNotificationTime = value!;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  saveBusNotificationSettings(busRouteName, selectedNotificationTime);
                                                  startBackgroundBusTracking(busRouteName, selectedNotificationTime);
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('확인', style: TextStyle(color: Colors.white)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('취소', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('알림 등록', style: TextStyle(color: Colors.white)),
                                  ),
                              );
                            }).toList(),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                isBottomSheetVisible = false;
                                selectedStation = null;
                                busArrivalList = [];
                              });
                            },
                            child: const Text(
                              '닫기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

void saveBusNotificationSettings(String busRouteName, int notificationTime) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('busRouteName', busRouteName);
  await prefs.setInt('notificationTime', notificationTime);
}

void startBackgroundBusTracking(String busRouteName, int notificationTime) {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'bus_arrival_channel',
    'Bus Arrival Notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    icon: 'app_icon', // Ensure this icon exists in your Android resources
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(
    0,
    '버스 도착 알림',
    '$busRouteName 버스가 $notificationTime분 후에 도착합니다.',
    platformChannelSpecifics,
  );
}