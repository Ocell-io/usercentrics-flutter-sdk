import 'dart:js_interop';
import 'package:usercentrics_sdk/src/model/model.dart';

Future<List<UsercentricsServiceConsent>> parseUsercentricsConsents(JSAny jsDetails) async {
  final data = jsDetails.dartify();

  if (data is! Map) {
    throw StateError('Unexpected getConsentDetails() shape: $data');
  }

  final services = data['services'];
  if (services is! Map) return const [];

  final results = <UsercentricsServiceConsent>[];

  for (final entry in services.entries) {
    final id = entry.key as String;
    final svc = entry.value;
    if (svc is! Map) continue;

    final name = svc['name']?.toString() ?? '';
    final category = svc['category']?.toString() ?? '';
    final version = svc['version']?.toString() ?? '';
    final consent = svc['consent'] as Map?;
    final essential = svc['essential'] == true;

    final given = consent?['given'] == true;
    final typeStr = consent?['type']?.toString();

    results.add(
      UsercentricsServiceConsent(
        templateId: id,
        dataProcessor: name,
        category: category,
        version: version,
        isEssential: essential,
        status: given,
        type: _mapConsentType(typeStr),
        history: [
          UsercentricsConsentHistoryEntry(
            status: given,
            timestampInMillis: DateTime.now().millisecondsSinceEpoch,
            type: _mapConsentType(typeStr),
          )
        ],
      ),
    );
  }

  return results;
}

UsercentricsConsentType? _mapConsentType(String? type) {
  if (type == null) return null;
  switch (type.toUpperCase()) {
    case 'EXPLICIT':
      return UsercentricsConsentType.explicit;
    case 'IMPLICIT':
      return UsercentricsConsentType.implicit;
    default:
      return null;
  }
}
