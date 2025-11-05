import 'dart:convert';

class UsercentricsEvent {
  final String type;
  final dynamic payload;
  const UsercentricsEvent(this.type, this.payload);

  @override
  String toString() =>
      'UsercentricsEvent(type: $type, payload: ${jsonEncode(payload)})';
}