import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:isar_riverpod_example/isar/type_converters/color_converter.dart';

part 'profile.g.dart';

@Collection()
class Profile {
  Id id;
  String name;

  @Ignore()
  Color favoriteColor;

  String get favoriteColorHex => ColorConverter.toIsar(favoriteColor);
  set favoriteColorHex(String hex) => favoriteColor = ColorConverter.fromIsar(hex);

  Profile({
    required this.id,
    required this.name,
    this.favoriteColor = const Color.fromARGB(255, 33, 91, 255),
  });
}
