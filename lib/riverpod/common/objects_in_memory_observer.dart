// ignore_for_file: invalid_use_of_protected_member, prefer_final_fields

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'obj_notifier.dart';

class ObjectsInMemoryObserver extends ProviderObserver {
  static final provider = Provider((ref) => ObjectsInMemoryObserver());

  Map<Type, Set> _idMap = {};

  bool isObjectInMemory(Type objType, dynamic identifier) =>
      _idMap.containsKey(objType) && _idMap[objType]!.contains(identifier);

  @override
  void didAddProvider(ProviderBase provider, Object? value, ProviderContainer container) {
    if (provider is ObjectProvider && provider.notifier is ObjectNotifier) {
      var objectNotifierId = (provider.notifier as ObjectNotifier).objectNotifierId;
      _idMap[objectNotifierId.dataType] ??= {};
      _idMap[objectNotifierId.dataType]!.add(objectNotifierId.identifier);
    }
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    if (provider is ObjectProvider && provider.notifier is ObjectNotifier) {
      var objectNotifierId = (provider.notifier as ObjectNotifier).objectNotifierId;
      if (_idMap[objectNotifierId.dataType] != null &&
          _idMap[objectNotifierId.dataType]!.contains(objectNotifierId.identifier)) {
        _idMap[objectNotifierId.dataType]!.remove(objectNotifierId.identifier);
      }
    }
  }
}
