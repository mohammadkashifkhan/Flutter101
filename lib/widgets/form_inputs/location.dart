import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpClient;
import 'package:map_view/map_view.dart';

class LocationInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  Uri _staticMapUri;
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    super.initState();
  }

  @override //////////////////// just like initState , another lifecycle method which is executed at the destruction of widget
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
  }

  void getStaticMap(String address) async {
    if (address.isEmpty) return;
    final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json',
        {'address': address, 'key': 'AIzaSyDQRXxzkCH0rCBQIBJC1iJgolmkZX_4_YQ'});
    final httpClient.Response response = await httpClient.get(uri);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    final coordinates = decodedResponse['results'][0]['geometry']['location'];

    StaticMapProvider staticMapViewProvider =
        StaticMapProvider('AIzaSyDQRXxzkCH0rCBQIBJC1iJgolmkZX_4_YQ');
    final Uri staticMapUri = staticMapViewProvider.getStaticUriWithMarkers(
        [Marker('position', 'Position', coordinates['lat'], coordinates['lng'])],
        center: Location(coordinates['lat'], coordinates['lng']),
        width: 500,
        height: 300,
        maptype: StaticMapViewType.roadmap);

    setState(() {
      _staticMapUri = staticMapUri;
      _addressInputController.text = formattedAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _addressInputController,
          focusNode: _addressInputFocusNode,
          decoration: InputDecoration(hintText: 'Address'),
        ),
        SizedBox(
          height: 10.0,
        ),
        Image.network(_staticMapUri.toString()),
      ],
    );
  }
}
