// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatLng _$LatLngFromJson(Map<String, dynamic> json) => LatLng(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$LatLngToJson(LatLng instance) => <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      id: json['id'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
      'name': instance.name,
    };

Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
      zoom_level: (json['zoom_level'] as num).toDouble(),
      locations: (json['locations'] as List<dynamic>)
          .map((e) => Location.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
      'zoom_level': instance.zoom_level,
      'locations': instance.locations,
    };
