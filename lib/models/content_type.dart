import 'package:hive/hive.dart';

part 'content_type.g.dart';

@HiveType(typeId: 4)
enum ContentType {
  @HiveField(0) Comic,
  @HiveField(1) Novel,
}
