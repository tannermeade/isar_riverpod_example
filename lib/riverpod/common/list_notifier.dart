// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'obj_notifier.dart';

typedef ListProvider<A, B>
    = AutoDisposeStateNotifierProvider<ListNotifier<A, B>, AsyncValue<List<ObjectProvider<A, B>>>>;

typedef ListProviderFamily<A, B>
    = AutoDisposeStateNotifierProviderFamily<ListNotifier<A, B>, AsyncValue<List<ObjectProvider<A, B>>>, String>;

class ListNotifier<A, B> extends StateNotifier<AsyncValue<List<ObjectProvider<A, B>>>> {
  ListNotifier({
    required this.read,
    required this.getAllObjects,
    required this.buildQueryOnlyNewObjects,
    required this.providersFromIdentifiers,
    required this.providersFromObjects,
    required this.getObjIdentifer,
    this.identifiers,
    this.objects,
  }) : super(const AsyncLoading()) {
    _init();
  }

  final Reader read;
  List<B>? identifiers;
  List<A>? objects;
  final Future<List<A>> Function() getAllObjects;
  final Future<Query<A>> Function(List<B> identifiers) buildQueryOnlyNewObjects;
  final B Function(A) getObjIdentifer;
  final List<ObjectProvider<A, B>> Function({required List<B> identifiers, required Reader read})
      providersFromIdentifiers;
  final List<ObjectProvider<A, B>> Function({required List<A> objects, required Reader read}) providersFromObjects;

  @protected
  StreamSubscription<void>? onChangeSubscription;

  void _init() async {
    if (identifiers == null) {
      if (objects != null) {
        identifiers = objects!.map((obj) => getObjIdentifer(obj)).toList();
      } else {
        objects = await getAllObjects();
        identifiers = objects!.map((obj) => getObjIdentifer(obj)).toList();
      }

      var providerList = providersFromObjects(objects: objects!, read: read);
      if (mounted) state = AsyncData(providerList);
      await _watch();

      return;
    } else if (identifiers != null) {
      var providerList = providersFromIdentifiers(identifiers: identifiers!, read: read);
      if (mounted) state = AsyncData(providerList);
      await _watch();

      return;
    }
    if (mounted) {
      state = AsyncError<List<ObjectProvider<A, B>>>("No identifiers found.");
    }
  }

  Future _watch() async {
    if (onChangeSubscription != null) {
      await onChangeSubscription!.cancel();
      onChangeSubscription = null;
    }
    var q = await buildQueryOnlyNewObjects(identifiers ?? []);
    var queryChanged = q.watch();
    onChangeSubscription = queryChanged.listen(
      onChangedData,
      onError: onChangedError,
      onDone: onChangedDone,
      cancelOnError: false,
    );
  }

  void onChangedData(List<A> newObjects) async {
    var newIdentifiers = newObjects.map((obj) => getObjIdentifer(obj)).toList();
    if (newIdentifiers.isNotEmpty) {
      identifiers ??= [];
      identifiers!.addAll(newIdentifiers);
      List<ObjectProvider<A, B>> newProviders = providersFromObjects(objects: newObjects, read: read);
      state = AsyncData((state.value ?? []) + newProviders);

      await _watch();
    }
  }

  void onChangedError(Object error, StackTrace stacktrace) {}

  void onChangedDone() {}

  static listenForDeleteInList(WidgetRef ref, ListProvider listProvider, Function(AsyncValue) onDelete) {
    ref.listenOnce(listProvider, (prevList, nextList) {
      if (nextList.hasValue) {
        for (var prov in nextList.value!) {
          ref.listenOnce(prov, (prevObj, nextObj) {
            if (nextObj.hasError && nextObj.error == ObjectNotifierError.objectDeleted) {
              onDelete(nextObj);
            }
          });
        }
      }
    });
  }
}
