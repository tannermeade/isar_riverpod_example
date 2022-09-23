// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:isar/isar.dart';

// import '../common/list_notifier.dart';
// import '../common/obj_notifier.dart';

// class TemplateNotifier extends ObjectNotifier<Template, String> {
//   static IsarCollection<Template> _collection(Isar isar) => isar.templates;

//   static final provider = ObjectProviderFamily<Template, String>(
//     (ref, notifierId) => TemplateNotifier(ref.read, notifierId),
//   );

//   // static ListProvider<Template, String> getAll() => _queryProvider(
//   //       getAllObjects: () async {
//   //         return <Template>[];
//   //       },
//   //       buildQueryOnlyNewObjects: (List<String> identifiers) async {},
//   //     );

//   static ListProviderFamily<Template, String> _queryProviderFamily({
//     required Future<List<Template>> Function(AutoDisposeStateNotifierProviderRef ref) getAllObjects,
//     required Future<Query<Template>> Function(AutoDisposeStateNotifierProviderRef ref, List<String> identifiers)
//         buildQueryOnlyNewObjects,
//   }) =>
//       ListProviderFamily<Template, String>((ref, objId) => ListNotifier<Template, String>(
//             read: ref.read,
//             getAllObjects: () => getAllObjects(ref),
//             buildQueryOnlyNewObjects: (identifiers) => buildQueryOnlyNewObjects(ref, identifiers),
//             getObjIdentifer: (obj) => obj.id,
//             providersFromIdentifiers: providersFromIdentifiers,
//             providersFromObjects: providersFromObjects,
//           ));

//   static ListProvider<Template, String> _queryProvider({
//     required Future<List<Template>> Function(AutoDisposeStateNotifierProviderRef ref) getAllObjects,
//     required Future<Query<Template>> Function(AutoDisposeStateNotifierProviderRef ref, List<String>)
//         buildQueryOnlyNewObjects,
//   }) =>
//       ListProvider<Template, String>((ref) => ListNotifier<Template, String>(
//             read: ref.read,
//             getAllObjects: () => getAllObjects(ref),
//             buildQueryOnlyNewObjects: (identifiers) => buildQueryOnlyNewObjects(ref, identifiers),
//             getObjIdentifer: (obj) => obj.id,
//             providersFromIdentifiers: providersFromIdentifiers,
//             providersFromObjects: providersFromObjects,
//           ));

//   static ObjectProvider<Template, String> providerFromIdentifier(String identifier) =>
//       ObjectNotifier.providerFromIdentifier<Template, String>(identifier, provider);

//   static List<ObjectProvider<Template, String>> providersFromIdentifiers(
//           {required List<String> identifiers, required Reader read}) =>
//       ObjectNotifier.providersFromIdentifiers<Template, String>(
//         read: read,
//         identifiers: identifiers,
//         getAllByIdentifierQuery: (List<String> identifiers) async {
//           var repo = await read(repositoryPod.future);
//           return await _collection(repo.isar).where().anyOf(identifiers, (q, el) => q.idEqualTo(el)).findAll();
//         },
//         identifierEqualToComparator: (obj, otherIdentifier) => obj.id == otherIdentifier,
//         getProvider: provider,
//       );

//   static List<ObjectProvider<Template, String>> providersFromObjects(
//           {required List<Template> objects, required Reader read}) =>
//       ObjectNotifier.providersFromObjects<Template, String>(
//           objects: objects, getIdFromObj: (Template obj) => obj.id, getProvider: provider);

//   TemplateNotifier(super.read, super.notifierId);

//   @override
//   Future<Query<Template>> buildQueryGetByIdentifier(String identifier) async {
//     var isar = await read(isarPod.future);
//     return _collection(isar).where().idEqualTo(identifier).build();
//   }

//   @override
//   Stream<Template?> watchByIsarId(Isar isar, Id isarId) => _collection(isar).watchObject(isarId);

//   @override
//   Id getIsarId(Template obj) => obj.localId;
// }
