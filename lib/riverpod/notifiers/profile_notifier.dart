import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:isar_riverpod_example/isar/collection/profile.dart';
import 'package:isar_riverpod_example/riverpod/common/notifier_id.dart';
import 'package:isar_riverpod_example/riverpod/providers.dart';

import '../common/list_notifier.dart';
import '../common/obj_notifier.dart';

class ProfileNotifier extends ObjectNotifier<Profile, Id> {
  static IsarCollection<Profile> _collection(Isar isar) => isar.profiles;

  static final provider = ObjectProviderFamily<Profile, Id>(
    (ref, notifierId) => ProfileNotifier(ref.read, notifierId),
  );

  static ObjectProvider<Profile, Id> getFromId(Id profileId) => provider(ObjectNotifierId<Profile, int>(profileId));

  static ListProvider<Profile, Id> getAllExcept(Id exceptId) => _queryProviderFamily(
        getAllObjects: (ref) async {
          var isar = await ref.read(isarProvider.future);
          return await _collection(isar).filter().not().idEqualTo(exceptId).findAll();
        },
        buildQueryOnlyNewObjects: (ref, identifiers) async {
          var isar = await ref.read(isarProvider.future);
          return _collection(isar)
              .filter()
              .not()
              .group((q1) => q1.anyOf(identifiers, (q2, el) => q2.idEqualTo(el)))
              .build();
        },
      )(exceptId.toString());

  static ListProviderFamily<Profile, Id> _queryProviderFamily({
    required Future<List<Profile>> Function(AutoDisposeStateNotifierProviderRef ref) getAllObjects,
    required Future<Query<Profile>> Function(AutoDisposeStateNotifierProviderRef ref, List<Id> identifiers)
        buildQueryOnlyNewObjects,
  }) =>
      ListProviderFamily<Profile, Id>((ref, objId) => ListNotifier<Profile, Id>(
            read: ref.read,
            getAllObjects: () => getAllObjects(ref),
            buildQueryOnlyNewObjects: (identifiers) => buildQueryOnlyNewObjects(ref, identifiers),
            getObjIdentifer: (obj) => obj.id,
            providersFromIdentifiers: providersFromIdentifiers,
            providersFromObjects: providersFromObjects,
          ));

  static ListProvider<Profile, Id> _queryProvider({
    required Future<List<Profile>> Function(AutoDisposeStateNotifierProviderRef ref) getAllObjects,
    required Future<Query<Profile>> Function(AutoDisposeStateNotifierProviderRef ref, List<Id>)
        buildQueryOnlyNewObjects,
  }) =>
      ListProvider<Profile, Id>((ref) => ListNotifier<Profile, Id>(
            read: ref.read,
            getAllObjects: () => getAllObjects(ref),
            buildQueryOnlyNewObjects: (identifiers) => buildQueryOnlyNewObjects(ref, identifiers),
            getObjIdentifer: (obj) => obj.id,
            providersFromIdentifiers: providersFromIdentifiers,
            providersFromObjects: providersFromObjects,
          ));

  static List<ObjectProvider<Profile, Id>> providersFromIdentifiers(
          {required List<Id> identifiers, required Reader read}) =>
      ObjectNotifier.providersFromIdentifiers<Profile, Id>(
        identifiers: identifiers,
        getAllByIdentifierQuery: (List<Id> identifiers) async {
          var isar = await read(isarProvider.future);
          return await _collection(isar).where().anyOf(identifiers, (q, el) => q.idEqualTo(el)).findAll();
        },
        identifierEqualToComparator: (obj, otherIdentifier) => obj.id == otherIdentifier,
        getProvider: provider,
      );

  static List<ObjectProvider<Profile, Id>> providersFromObjects(
          {required List<Profile> objects, required Reader read}) =>
      ObjectNotifier.providersFromObjects<Profile, Id>(
          objects: objects, getIdFromObj: (Profile obj) => obj.id, getProvider: provider);

  ProfileNotifier(super.read, super.notifierId);

  @override
  Future<Profile?> getByIdentifierQuery(Id identifier) async {
    var isar = await read(isarProvider.future);
    return await _collection(isar).where().idEqualTo(identifier).findFirst();
  }

  @override
  Stream<Profile?> watchByIsarId(Isar isar, Id isarId) => _collection(isar).watchObject(isarId);

  @override
  Id getIsarId(Profile obj) => obj.id;
}
