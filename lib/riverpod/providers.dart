import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar_riverpod_example/isar/all_schemas.dart';
import 'package:isar_riverpod_example/isar/collection/profile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final appDirPod = FutureProvider((ref) async => kIsWeb ? null : (await getApplicationSupportDirectory()).path);

final isarProvider = FutureProvider((ref) async {
  final appDir = await ref.read(appDirPod.future);
  var isar = await Isar.open(
    allSchemas,
    directory: appDir,
  );

  await isar.writeTxn(() async {
    
    await isar.profiles.putAll([
      Profile(id: 0, name: "John", favoriteColor: Colors.red),
      Profile(id: 1, name: "Susan", favoriteColor: Colors.blue),
      Profile(id: 2, name: "Alex", favoriteColor: Colors.green),
      Profile(id: 3, name: "Rachel", favoriteColor: Colors.yellow),
    ]);
  });

  return isar;
});
