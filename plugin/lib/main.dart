import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart'; //change address to coordinate

//location class
class Location {
  final double lat;
  final double long;

  Location({required this.lat, required this.long});
}

//address class
class Addr {
  final String road;
  final String zipCode;
  final String city;
  final String country;
  final Location loc;

  Addr({required this.road, required this.zipCode, required this.city, required this.country, required this.loc});
}

class AddresConverter {
  //special char for escape address
  static const String withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž-';
  static const String withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz ';

  static Future<Addr> convert({required String address}) async {
    //get coordinate
    Location loc = await addrToLoc(address);

    //split address;
    List<String> splitAddr = address.split(', ');

    //address data
    String road = splitAddr.first;
    String city = format(splitAddr[splitAddr.length - 2]);
    String country = splitAddr.last;
    String zipCode = await getZip(city);

    //return formated Addr Object
    return Addr(road: road, zipCode: zipCode, city: city, country: country, loc: loc);
  }

  static Future<String> getZip(city) async {
    //get FR zip code
    Map decode = await readJson();
    List zipCode = decode['data'];

    //get if zipCode exist in Fr zip code json
    var result = zipCode.firstWhere((el) {
      if (el['fields']['nom_de_la_commune'] == city.toUpperCase()) {
        return true;
      } else {
        return false;
      }
    }, orElse: () => 'not-found');

    //return zipCode
    return result != 'not-found' ? result['fields']['code_postal'] : result;
  }

  static String format(String str) {
    str = str.replaceAll('œ', 'oe');
    for (var i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  //get data from json file
  static Future<Map> readJson() async {
    final String response = await rootBundle.loadString('assets/json/laposte_hexasmal.json');
    final data = await json.decode(response);
    return data is Map ? data : {'data': data};
  }

  //change address to coordinate
  static Future<Location> addrToLoc(String addr) async {
    var loc = await locationFromAddress(addr);
    return Location(lat: loc[0].latitude, long: loc[0].longitude);
  }
}
