import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'list_notifier.dart';
import 'obj_notifier.dart';

class AsyncObjConsumer<A, B> extends StatelessWidget {
  const AsyncObjConsumer({
    super.key,
    required this.provider,
    required this.data,
    this.orElse,
    this.error,
    this.loading,
  });

  final ObjectProvider<A, B> provider;
  final Widget Function(A obj, WidgetRef ref) data;
  final Widget Function(Object, StackTrace?)? error;
  final Widget Function()? loading;
  final Widget Function()? orElse;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => ref.watch(provider).when(
            data: (obj) => data(obj, ref),
            error: error ?? (orElse != null ? (_, __) => orElse!() : (error, stackTrace) => const SizedBox()),
            loading: loading ?? orElse ?? () => const CircularProgressIndicator.adaptive(),
          ),
    );
  }
}

class AsyncListConsumer<A, B> extends StatelessWidget {
  const AsyncListConsumer({
    super.key,
    required this.provider,
    required this.data,
    this.orElse,
    this.error,
    this.loading,
  });

  final ListProvider<A, B> provider;
  final Widget Function(List<ObjectProvider<A, B>> listObjProviders, WidgetRef ref) data;
  final Widget Function(Object, StackTrace?)? error;
  final Widget Function()? loading;
  final Widget Function()? orElse;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => ref.watch(provider).when(
            data: (listObjProviders) => data(listObjProviders, ref),
            error: error ?? (orElse != null ? (_, __) => orElse!() : (error, stackTrace) => const SizedBox()),
            loading: loading ?? orElse ?? () => const CircularProgressIndicator.adaptive(),
          ),
    );
  }
}
