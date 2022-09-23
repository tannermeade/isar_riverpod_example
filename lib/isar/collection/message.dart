
import 'package:isar/isar.dart';

part 'message.g.dart';

@Collection()
class Message {
  Id id;
  String content;
  int fromProfileId;

  Message({
    required this.id,
    required this.content,
    required this.fromProfileId,
  });
}