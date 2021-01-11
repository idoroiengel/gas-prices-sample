import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapWidget extends StatefulWidget {
  static const String ACCESS_TOKEN =
      "pk.eyJ1IjoiaWRvcm9pZW5nZWwiLCJhIjoiY2tpZXA2Nnp5MDE2czMxbXA3Y25yZDc2OCJ9.PvuPJinVM4wOTRPQH4kDMA";

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  PackageInfo packageInfo;
  MapboxMapController controller;
  Circle _selectedCircle;
  Line _selectedLine;

  LatLng _selectedLocation;
  LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();

    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true,
    ).then(
      (value) => _currentLocation = LatLng(value.latitude, value.longitude),
    );
  }

  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    print(position);
  }

  @override
  void dispose() {
    controller?.onLineTapped?.remove(_onLineTapped);
    controller?.onCircleTapped?.remove(_onCircleTapped);
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    this.controller.onCircleTapped.add(_onCircleTapped);
    this.controller.onLineTapped.add(_onLineTapped);
  }

  void _onStyleLoaded() {
    addImageFromAsset("firstAssetImage", "assets/symbols/custom-icon.png");
    addImageFromUrl("firstNetworkImage", "https://via.placeholder.com/50");
  }

  Future<void> addImageFromUrl(String name, String url) async {
    var response = await get(url);
    return controller.addImage(name, response.bodyBytes);
  }

  Future<void> addImageFromAsset(String imageName, String image) async {
    final ByteData bytes = await rootBundle.load(image);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage("firstAssetImage", list);
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  void _onMapClicked(Point<double> point, LatLng coordinates) {
    setState(() {
      _selectedLocation = coordinates;
    });
  }

  void _addLine() {
    controller.addLine(
      LineOptions(
        geometry: [
          LatLng(
            _selectedLocation.latitude,
            _selectedLocation.longitude,
          ),
          LatLng(
            _selectedLocation.latitude + 10,
            _selectedLocation.longitude + 10,
          )
        ],
        lineColor: "#000000",
        lineWidth: 10.0,
        lineOpacity: 0.9,
        draggable: true,
      ),
    );
  }

  void _addCircle() {
    controller.addCircle(
      CircleOptions(
        geometry: LatLng(
          _selectedLocation.latitude,
          _selectedLocation.longitude,
        ),
        draggable: true,
        circleColor: "#ffff00",
        circleRadius: 50.0,
        circleOpacity: 0.4,
        circleStrokeColor: "#000000",
        circleStrokeWidth: 3.0,
      ),
    );
  }

  void _addSymbol(String iconImage) {
    controller.addSymbol(
      SymbolOptions(
        draggable: false,
        geometry: LatLng(
          32.0757555,
          34.814919,
        ),
        textField: iconImage,
        textColor: "#0000ff",
        iconImage: iconImage,
      ),
    );
  }

  void _onCircleTapped(Circle circle) {
    if (_selectedCircle != null) {
      _updateCircle(CircleOptions(
        circleRadius: 60.0,
      ));
    }
    setState(() {
      _selectedCircle = circle;
    });
  }

  void _onLineTapped(Line line) {
    if (_selectedLine != null) {
      _updateLine(
        LineOptions(
          lineWidth: 1.0,
        ),
      );
    }
    setState(() {
      _selectedLine = line;
    });
  }

  void _updateCircle(CircleOptions circleOptions) {
    controller.updateCircle(_selectedCircle, circleOptions);
  }

  void _updateLine(LineOptions lineOptions) {
    controller.updateLine(_selectedLine, lineOptions);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(packageInfo.appName),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Text("current location: " + _currentLocation.toString()),
          ),
          Center(
            child: SizedBox(
              // width: 300.0,
              height: ScreenUtil().setHeight(1000.0),
              child: MapboxMap(
                accessToken: MapWidget.ACCESS_TOKEN,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoaded,
                onMapClick: _onMapClicked,
                compassEnabled: true,
                initialCameraPosition: CameraPosition(
                  // target: LatLng(32.0757555, 34.814919),
                  target: _currentLocation != null
                      ? _currentLocation
                      : LatLng(-33.852, 151.211),
                  zoom: 11.0,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: _addLine,
                color: Colors.blue,
                child: Text(
                  "add line",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              FlatButton(
                onPressed: _addCircle,
                color: Colors.blue,
                child: Text(
                  "add circle",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () => _addSymbol("firstNetworkImage"),
                color: Colors.blue,
                child: Text(
                  "add remote symbol",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () => _addSymbol("firstAssetImage"),
                color: Colors.blue,
                child: Text(
                  "add local symbol",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
