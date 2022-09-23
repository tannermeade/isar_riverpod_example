# isar_riverpod_example

This is an example of using Isar and Riverpod together. It creates 4 chat pages and has a message button to create a message from the different people. It's a very basic example for a system designed for very complex state management.

## Motivations

The state management system used in this basic example was originally design to handle a complex app that had to use highly variable and dynamic data in many different areas of the app at the same time. It also required that all the data be immediatly changes no matter where it might have been updated/created/deleted (any local widget or remotely as well).

As a solution, this sytem is being developed to take advantage of both riverpod and isar's watching capabilities.

## Basic Concepts

The two basic concepts of state are:
- a discrete object: has an individual identifer that separates it from the rest
- a discrete list of objects: has an isar query that identifies it from the rest

The brains of the state system is in `lib/riverpod/common`. The two basic ideas are:
- ObjectNotifier: Handles an object's state and subscribes to changes
- ListNotifier: Handles a list's state and subscribes to create events

### Other concepts
- ObjectsInMemoryObserver: Observers the ProviderScope and listens to create & dispose events for providers. It uses these event to keep track of which objects are loaded in memory, and which are not.
- The code uses generics to model both the object type and the identifier type. The identifier is most often the Id of the object. Just in case the user wants to use a different data type to uniquely identify an object (just as a string) it can be changed easily. The `ObjectNotifierId` class is used to identify an object's provider. It holds the identifier of the object and is internally used to initialize a provider when it is more efficient to query multiple objects at once. It is also used to keep track of which objects are loaded into memory (so we don't query for objects that are already loaded and we know the identifier for).

The CRUD state events that take place are:
- Create events cause subscribers to a ListProvider to rebuild.
- Update events cause subscribers to an ObjectProvider to rebuild.
- Delete events cause subscribers to an ObjectProvider to rebuild.

If you want to rebuild a list when a delete happens you can use the `ListNotifier.listenForDeleteInList()` helper function to execute a rebuild in a StatefulWidget that has the ListProvider.

All data is wrapped in an AsycValue object (from the Riverpod package). The three forms it can take is:
- AsyncData: value is not null. Could still have isLoading as true, and that is when isRefreshing is also true.
- AsyncLoading: isLoading is true
- AsyncError: hasError is true

You can use AsyncValue's methods to easily build whatever you want such as:
- when
- whenData
- whenOrNull
- maybeWhen

## How to use it in your app

To use it in your app, you'll need to be using Isar (3.0.0) and Riverpod (3.0.0). You ought to understand the concepts behind Riverpod as well such as families.

1. Copy the files found in `lib/riverpod/common` to your code.
2. Duplicate the `template.dart` file for every isar collection you have.
3. Do a find+replace for `Template` and your collection name.
4. Correct the _collection method's reference to `isar.Your_Collection_Name` so the first letter of the colelction name is lowercase.
5. The template uses a `String` for the identifier data type. This is so it is easy to find+replace to whatever data type you want. So if you're using an Isar Id data type do a quick find+replace. There are a few places that need to specifically use the isar Id data type and are always named something like `isarId`. So if you change it away from an Id (after you've already replaced all the `String` occurances) you might change those when they're not. The linter should tell you if you do.
6. Wrap your `ProviderScope` with another `ProviderScope` + `Consumer`. Give the inside `ProviderScope` this for it's observers... `observers: [ref.read(ObjectsInMemoryObserver.provider)],`.
7. If you want to implement special object queries (apart from just getting individual objects by id) you can write static methods for each of your Collection Obejct's Notifiters.

## How to build your own methods to get data

There are a few different categories of data you may want to get:
- `ObjectProvider` A single object
- `List<ObjectProvider>` A list of objects from identifiers you already have
- `ListProvider` A dynamic list of objects. You don't know the discrete identifiers, but you know how to find them using isar's queries.

### A Single Object

To do this just use this method: `MessageNotifier.providerFromIdentifier()`. The Object's Notifier's provider is used for this. As an example: If you have an object named `Message` and the Notifier is called `MessageNotifier`, then call `MessageNotifier.provider()` to get the `Message`. This method does require using the `ObjectNotifierId` class. It is a good practice to limit the exposure of this class to the UI code. This is why there is already a static method called `MessageNotifier.providerFromIdentifier()` in the Notifier classes.

### A List of Objects From Identifiers

A critical difference between getting a single object and a list is that some of them might already be loaded into memory. This is the reason a `Reader` is required to call the `[Your_Object_Name]Notifier.providersFromIdentifiers()` method. It will automatically find the provider for any objects that are already loaded into memory and return a list of all the providers for the objects. Since some of the objects may not be loaded yet, you may want to sort the results yourself if that is important for your usecase.

If you are requesting providers for a list of identifiers, odds are that you have probably stored those providers in a `StatefulWidget` or have them in a `Consumer`. To pass the `Reader` to `prvidersFromIdentifiers()` use `ref.read` from the `ref` in `Consumer` or use a `ConsumerStatefulWidget` where `ref` is available in its `ConsumerState`.

### A Dynamic List of Objects From a Query

This situation is when you need objects that you can only define using isar queries, and not by the identifiers. Make a static method for a unique query object list by using the `_queryProviderFamily` and the `_queryProvider` static methods in your object's notifier class.
- `_queryProviderFamily`: Use when you have a query that has many different permutations based on a value. Queries like get all the objects that have a `value` for a `field`. Then any time you happen to want the same query at the same time, it'll immediately give all the data to you if it's already in use.
- `_queryProvider`: Use for a single query that is unique.

## Helper Types and Widgets

`ListObserver`, `ObjectObserver`, `ListProvider`, and `ObjectProvider` are helper typedefs that are useful when building your UI because most everything is wrapped in classes like `AutoDisposeStateNotifierProvider`, `ObjectNotifier`, `ListNotifier`, and `AsyncValue` the type definitions can get long.

You'll always get back either a `ListProvider`, `ObjectProvider`, or a `List<ObjectProvider>` from the methods in your Notifier classes. So if the data type the dart linter is getting is long and confusing, just replace it with one of these.

`AsyncListConsumer` and `AsyncObjConsumer` are helper widgets that make using the `AsyncValue` wrapping your objects easier to use. If you define the generic data types you'll get dart providing proper typing throughout the widget tree. IE... `AsyncListConsumer<Message, Id>(...)` or `AsyncObjConsumer<Message, Id>(...)`.

### AsyncListConsumer

Use this when you have a `ListProvider`.

### AsyncObjConsumer

Use this when you have a `ObjectProvider` or a `List<ObjectProvider>`.