import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:isar_riverpod_example/isar/collection/message.dart';
import 'package:isar_riverpod_example/riverpod/providers.dart';

import '../common/list_notifier.dart';
import '../common/obj_notifier.dart';

class MessageNotifier extends ObjectNotifier<Message, Id> {
  static IsarCollection<Message> _collection(Isar isar) => isar.messages;

  static final provider = ObjectProviderFamily<Message, Id>(
    (ref, notifierId) => MessageNotifier(ref.read, notifierId),
  );

  static ListProvider<Message, Id> getAll() => _queryProvider(
        getAllObjects: (ref) async {
          var isar = await ref.read(isarProvider.future);
          return await _collection(isar).where().findAll();
        },
        buildQueryOnlyNewObjects: (ref, identifiers) async {
          var isar = await ref.read(isarProvider.future);
          return _collection(isar)
              .filter()
              .not()
              .group((q1) => q1.anyOf(identifiers, (q2, el) => q2.idEqualTo(el)))
              .build();
        },
      );

  static ListProviderFamily<Message, Id> _queryProviderFamily({
    required Future<List<Message>> Function(AutoDisposeStateNotifierProviderRef ref) getAllObjects,
    required Future<Query<Message>> Function(AutoDisposeStateNotifierProviderRef ref, List<Id> identifiers)
        buildQueryOnlyNewObjects,
  }) =>
      ListProviderFamily<Message, Id>((ref, objId) => ListNotifier<Message, Id>(
            read: ref.read,
            getAllObjects: () => getAllObjects(ref),
            buildQueryOnlyNewObjects: (identifiers) => buildQueryOnlyNewObjects(ref, identifiers),
            getObjIdentifer: (obj) => obj.id,
            providersFromIdentifiers: providersFromIdentifiers,
            providersFromObjects: providersFromObjects,
          ));

  static ListProvider<Message, Id> _queryProvider({
    required Future<List<Message>> Function(AutoDisposeStateNotifierProviderRef ref) getAllObjects,
    required Future<Query<Message>> Function(AutoDisposeStateNotifierProviderRef ref, List<Id>)
        buildQueryOnlyNewObjects,
  }) =>
      ListProvider<Message, Id>((ref) => ListNotifier<Message, Id>(
            read: ref.read,
            getAllObjects: () => getAllObjects(ref),
            buildQueryOnlyNewObjects: (identifiers) => buildQueryOnlyNewObjects(ref, identifiers),
            getObjIdentifer: (obj) => obj.id,
            providersFromIdentifiers: providersFromIdentifiers,
            providersFromObjects: providersFromObjects,
          ));

  static ObjectProvider<Message, Id> providerFromIdentifier(Id identifier) =>
      ObjectNotifier.providerFromIdentifier<Message, Id>(identifier, provider);

  static List<ObjectProvider<Message, Id>> providersFromIdentifiers(
          {required List<Id> identifiers, required Reader read}) =>
      ObjectNotifier.providersFromIdentifiers<Message, Id>(
        read: read,
        identifiers: identifiers,
        getAllByIdentifierQuery: (List<Id> identifiers) async {
          var isar = await read(isarProvider.future);
          return await _collection(isar).where().anyOf(identifiers, (q, el) => q.idEqualTo(el)).findAll();
        },
        identifierEqualToComparator: (obj, otherIdentifier) => obj.id == otherIdentifier,
        getProvider: provider,
      );

  static List<ObjectProvider<Message, Id>> providersFromObjects(
          {required List<Message> objects, required Reader read}) =>
      ObjectNotifier.providersFromObjects<Message, Id>(
          objects: objects, getIdFromObj: (Message obj) => obj.id, getProvider: provider);

  MessageNotifier(super.read, super.notifierId);

  @override
  Future<Query<Message>> buildQueryGetByIdentifier(Id identifier) async {
    var isar = await read(isarProvider.future);
    return _collection(isar).where().idEqualTo(identifier).build();
  }

  @override
  Stream<Message?> watchByIsarId(Isar isar, Id isarId) => _collection(isar).watchObject(isarId);

  @override
  Id getIsarId(Message obj) => obj.id;
}
