// ignore_for_file: unused_field

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:isar_riverpod_example/riverpod/providers.dart';
import 'notifier_id.dart';
import 'objects_in_memory_observer.dart';

typedef ObjectProvider<A, B> = AutoDisposeStateNotifierProvider<ObjectNotifier<A, B>, AsyncValue<A>>;
typedef ObjectProviderFamily<A, B>
    = AutoDisposeStateNotifierProviderFamily<ObjectNotifier<A, B>, AsyncValue<A>, ObjectNotifierId<A, B>>;

abstract class ObjectNotifier<T, I> extends StateNotifier<AsyncValue<T>> {
  ObjectNotifier(this.read, this.objectNotifierId) : super(const AsyncLoading()) {
    _init();
  }

  final Reader read;
  final ObjectNotifierId objectNotifierId;
  @protected
  StreamSubscription<T?>? onChangeSubscription;

  @protected
  Future<Query<T>> buildQueryGetByIdentifier(I identifier);

  @protected
  Stream<T?> watchByIsarId(Isar isar, Id isarId);

  @protected
  Id getIsarId(T obj);

  static ObjectProvider<A, B> providerFromIdentifier<A, B>(B identifier, ObjectProviderFamily<A, B> provider) =>
      provider(ObjectNotifierId<A, B>(identifier));

  void _init() async {
    if (objectNotifierId.dataFuture != null && objectNotifierId.dataFuture is Future<T?>) {
      T? data = await objectNotifierId.dataFuture;
      if (data != null) {
        if (mounted) state = AsyncData(data);
        await _watch(getIsarId(data));
      }
    } else {
      var query = await buildQueryGetByIdentifier(objectNotifierId.identifier);
      var retrievedObj = await query.findFirst();
      if (retrievedObj != null) {
        if (mounted) state = AsyncLoading<T>().copyWithPrevious(AsyncData(retrievedObj));
        await _watch(getIsarId(retrievedObj));
      }
    }
  }

  Future _watch(Id isarId) async {
    var isar = await read(isarProvider.future);
    var objChanged = watchByIsarId(isar, isarId);
    onChangeSubscription = objChanged.listen(
      onChangedData,
      onError: onChangedError,
      onDone: onChangedDone,
      cancelOnError: false,
    );
  }

  @protected
  void onChangedData(T? event) {
    if (event != null) {
      if (mounted) state = AsyncData(event);
    } else {
      if (mounted) state = AsyncError<T>(ObjectNotifierError.objectDeleted);
    }
  }

  @protected
  void onChangedError(Object error, StackTrace stacktrace) {}
  @protected
  void onChangedDone() {}

  static List<ObjectProvider<A, B>> providersFromIdentifiers<A, B>({
    required Reader read,
    required List<B> identifiers,
    required Future<List<A>> Function(List<B> identifiers) getAllByIdentifierQuery,
    required bool Function(A obj, B otherIdentifier) identifierEqualToComparator,
    required ObjectProviderFamily<A, B> getProvider,
  }) {
    var memoryObserver = read(ObjectsInMemoryObserver.provider);
    List<B> loadedIdentifiers = [];
    List<B> notLoadedIdentifiers = [];
    for (B identifier in identifiers) {
      if (memoryObserver.isObjectInMemory(A, identifier)) {
        loadedIdentifiers.add(identifier);
      } else {
        notLoadedIdentifiers.add(identifier);
      }
    }

    var getAllObjsFuture = getAllByIdentifierQuery(notLoadedIdentifiers);

    var loadedProviders = loadedIdentifiers.map((identifier) => getProvider(ObjectNotifierId<A, B>(identifier)));
    var notLoadedProviders = notLoadedIdentifiers.map((identifier) => getProvider(ObjectNotifierId<A, B>(
        identifier,
        Future(() async =>
            (await getAllObjsFuture).firstWhereOrNull((el) => identifierEqualToComparator(el, identifier))))));

    return [...loadedProviders, ...notLoadedProviders];
  }

  static List<ObjectProvider<A, B>> providersFromObjects<A, B>({
    required List<A> objects,
    required B Function(A obj) getIdFromObj,
    required ObjectProviderFamily<A, B> getProvider,
  }) {
    return objects.map((obj) {
      return getProvider(ObjectNotifierId<A, B>(getIdFromObj(obj), Future(() => obj)));
    }).toList();
  }
}

enum ObjectNotifierError {
  objectDeleted,
}
