import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:isar_riverpod_example/isar/collection/message.dart';
import 'package:isar_riverpod_example/isar/collection/profile.dart';
import 'package:isar_riverpod_example/riverpod/common/list_notifier.dart';
import 'package:isar_riverpod_example/riverpod/common/obj_notifier.dart';
import 'package:isar_riverpod_example/riverpod/notifiers/message_notifier.dart';
import 'package:isar_riverpod_example/riverpod/notifiers/profile_notifier.dart';
import 'package:isar_riverpod_example/riverpod/providers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        home: const QuadrupleChatPage(),
      ),
    );
  }
}

class QuadrupleChatPage extends StatelessWidget {
  const QuadrupleChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: const [
                Expanded(child: ChatPage(profileId: 0)),
                Expanded(child: ChatPage(profileId: 1)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: const [
                Expanded(child: ChatPage(profileId: 2)),
                Expanded(child: ChatPage(profileId: 3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.profileId});

  final Id profileId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late ObjectProvider<Profile, Id> profileProvider;
  late ListProvider<Message, Id> messagesProvider;
  late ListProvider<Profile, Id> profilesProvider;

  @override
  void initState() {
    profileProvider = ProfileNotifier.getFromId(widget.profileId);
    messagesProvider = MessageNotifier.getAll();
    profilesProvider = ProfileNotifier.getAllExcept(widget.profileId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            var asyncData = ref.watch(profileProvider);
            return asyncData.when(
              data: (profile) => Text(profile.name),
              error: (error, stackTrace) => const SizedBox(),
              loading: () => const CircularProgressIndicator.adaptive(),
            );
          },
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          var asyncMsgs = ref.watch(messagesProvider);
          var asyncProfiles = ref.watch(profilesProvider);
          return asyncMsgs.when(
            data: (msgs) => SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...msgs.map((msgProv) => MessageWidget(
                          msgProvider: msgProv,
                          recieverProfileId: widget.profileId,
                        )),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator.adaptive(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var isar = await ref.read(isarProvider.future);
          await isar.writeTxn(() async => await isar.messages.put(Message(
                id: Isar.autoIncrement,
                content: "Hi",
                fromProfileId: widget.profileId,
              )));
        },
        tooltip: 'Send Message',
        child: const Icon(Icons.message),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.msgProvider,
    required this.recieverProfileId,
  });

  final ObjectProvider<Message, Id> msgProvider;
  final Id recieverProfileId;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => ref.watch(msgProvider).when(
            data: _buildMsgBubble,
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator.adaptive(),
          ),
    );
  }

  Widget _buildMsgBubble(Message msg) {
    return Row(
      mainAxisAlignment: recieverProfileId == msg.fromProfileId ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.blueGrey,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(msg.content),
              ),
              Consumer(builder: (context, ref, child) {
                var asyncProfile = ref.watch(ProfileNotifier.getFromId(msg.fromProfileId));
                return asyncProfile.when(
                  data: (profile) => Text(
                    "From:${profile.name}",
                    style: const TextStyle(fontSize: 10),
                  ),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const CircularProgressIndicator.adaptive(),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
