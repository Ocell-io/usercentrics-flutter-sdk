import 'dart:js_interop';
import 'package:usercentrics_sdk/src/model/model.dart';

Future<List<UsercentricsServiceConsent>> parseUsercentricsConsents(
    JSAny jsDetails) async {
  final services = jsDetails.dartify();

  if (services is! List) {
    throw StateError('Unexpected getServicesBaseInfo() shape: $services');
  }

  final results = <UsercentricsServiceConsent>[];

  for (final entry in services) {
    if (entry is! Map) continue;

    final name = entry['name']?.toString() ?? '';
    final category = entry['category']?.toString() ?? '';
    final version = entry['version']?.toString() ?? '';
    final consent = entry['consent'] as Map?;
    final essential = entry['essential'] == true;
    final processorTemplateId = entry['processorId'] as String?;

    final given = consent?['given'] == true;
    final typeStr = consent?['type']?.toString();

    results.add(
      UsercentricsServiceConsent(
        templateId: processorTemplateId ?? '',
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
