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
5. If you want to implement special object queries (apart from just getting individual objects by id) you can write static methods for each of your Collection Obejct's Notifiters.

To make the query static methods use the below methods already there:
- _queryProviderFamily: use when you have a query that has many different permutations based on a value. Queries like get all the objects that have a `value` for a `field`. Then anywhere you happen to want the same query at the same time, it'll immediately give all the data to you if it's already in use.
- _queryProvider: use for a single query that is unique