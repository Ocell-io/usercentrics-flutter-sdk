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
    final category = entry['categorySlug']?.toString() ?? '';
    final version = entry['version']?.toString() ?? '';
    final consent = entry['consent'] as Map?;
    final essential = entry['essential'] == true;
    final processorTemplateId = entry['processorId'] as String?;

    final status = consent?['status'] as bool;

    results.add(
      UsercentricsServiceConsent(
        templateId: processorTemplateId ?? '',
        dataProcessor: name,
        category: category,
        version: version,
        isEssential: essential,
        status: status,
        type: null,
        history: [
          UsercentricsConsentHistoryEntry(
            status: status,
            timestampInMillis: DateTime.now().millisecondsSinceEpoch,
            type: null,
          )
        ],
      ),
    );
  }

  return results;
}
