library usercentrics_web;

import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/cupertino.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:usercentrics_sdk/src/web/events/usercentrics_web_close_event.dart';
import 'package:usercentrics_sdk/src/web/helpers/parse_helper.dart';
import 'package:usercentrics_sdk/src/web/helpers/usercentrics_web_js_extension.dart';
import 'package:usercentrics_sdk/usercentrics_sdk.dart';
import 'package:web/web.dart' as web;

class UsercentricsWeb extends UsercentricsPlatform {
  static void registerWith(Registrar registrar) {
    UsercentricsPlatform.instance = UsercentricsWeb();
  }

  UCcmpJS? get _ucCmp => ucCmpJs;

  @override
  // TODO: implement aBTestingVariant
  Future<String?> get aBTestingVariant => throw UnimplementedError();

  @override
  Future<List<UsercentricsServiceConsent>> acceptAll(
      {required UsercentricsConsentType consentType}) {
    // TODO: implement acceptAll
    throw UnimplementedError();
  }

  @override
  Future<List<UsercentricsServiceConsent>> acceptAllForTCF(
      {required UsercentricsConsentType consentType,
      required TCFDecisionUILayer fromLayer}) {
    // TODO: implement acceptAllForTCF
    throw UnimplementedError();
  }

  @override
  // TODO: implement additionalConsentModeData
  Future<AdditionalConsentModeData> get additionalConsentModeData =>
      throw UnimplementedError();

  @override
  // TODO: implement ccpaData
  Future<CCPAData> get ccpaData => throw UnimplementedError();

  @override
  Future<void> changeLanguage({required String language}) async {
    _ucCmp?.updateLanguage(language.toJS);
  }

  @override
  Future<UsercentricsReadyStatus> clearUserSession() {
    // TODO: implement clearUserSession
    throw UnimplementedError();
  }

  @override
  // TODO: implement cmpData
  Future<UsercentricsCMPData> get cmpData => throw UnimplementedError();

  @override
  Future<List<UsercentricsServiceConsent>> get consents async {
    if (_ucCmp == null) {
      return const [];
    }

    try {
      final jsDetails = await _ucCmp!.getServicesBaseInfo().toDart;
      final consents = await parseUsercentricsConsents(jsDetails!);
      return consents;
    } catch (e) {
      debugPrint('Usercentrics Web: Consents could not be loaded: $e');
    }

    return const [];
  }

  @override
  // TODO: implement controllerId
  Future<String> get controllerId => throw UnimplementedError();

  @override
  Future<List<UsercentricsServiceConsent>> denyAll(
      {required UsercentricsConsentType consentType}) {
    // TODO: implement denyAll
    throw UnimplementedError();
  }

  @override
  Future<List<UsercentricsServiceConsent>> denyAllForTCF(
      {required UsercentricsConsentType consentType,
      required TCFDecisionUILayer fromLayer}) {
    // TODO: implement denyAllForTCF
    throw UnimplementedError();
  }

  @override
  void initialize({
    String settingsId = '',
    String ruleSetId = '',
    String? defaultLanguage,
    UsercentricsLoggerLevel? loggerLevel,
    int? timeoutMillis,
    String? version,
    NetworkMode? networkMode,
    bool? consentMediation,
    int? initTimeoutMillis,
  }) {
    if (_ucCmp == null && (settingsId.isNotEmpty || ruleSetId.isNotEmpty)) {
      _ensureUsercentricsScript(
        settingsId: settingsId.isNotEmpty ? settingsId : null,
        ruleSetId: ruleSetId.isNotEmpty ? ruleSetId : null,
        defaultLanguage: defaultLanguage,
      );
    }
  }

  @override
  Future<UsercentricsReadyStatus> restoreUserSession(
      {required String controllerId}) {
    // TODO: implement restoreUserSession
    throw UnimplementedError();
  }

  @override
  Future<List<UsercentricsServiceConsent>> saveDecisions(
      {required List<UserDecision> decisions,
      required UsercentricsConsentType consentType}) {
    // TODO: implement saveDecisions
    throw UnimplementedError();
  }

  @override
  Future<List<UsercentricsServiceConsent>> saveDecisionsForTCF(
      {required TCFUserDecisions tcfDecisions,
      required TCFDecisionUILayer fromLayer,
      required List<UserDecision> serviceDecisions,
      required UsercentricsConsentType consentType}) {
    // TODO: implement saveDecisionsForTCF
    throw UnimplementedError();
  }

  @override
  Future<List<UsercentricsServiceConsent>> saveOptOutForCCPA(
      {required bool isOptedOut,
      required UsercentricsConsentType consentType}) {
    // TODO: implement saveOptOutForCCPA
    throw UnimplementedError();
  }

  @override
  Future<void> setABTestingVariant({required String variant}) {
    // TODO: implement setABTestingVariant
    throw UnimplementedError();
  }

  @override
  Future<void> setCmpIdForTCF({required int id}) {
    // TODO: implement setCmpIdForTCF
    throw UnimplementedError();
  }

  @override
  Future<UsercentricsConsentUserResponse?> showFirstLayer(
      {BannerSettings? settings}) {
    // TODO: implement showFirstLayer
    throw UnimplementedError();
  }

  @override
  Future<UsercentricsConsentUserResponse?> showSecondLayer(
      {BannerSettings? settings}) async {
    if (_ucCmp == null) {
      return null;
    }

    try {
      final closeEvent = UsercentricsWebCloseEvent();

      await _ucCmp!.showSecondLayer().toDart;

      final userInteraction = await closeEvent.userInteraction;
      final controllerId = _ucCmp!.getControllerId().toDart;

      return UsercentricsConsentUserResponse(
        consents: await consents,
        userInteraction: userInteraction,
        controllerId: controllerId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  // TODO: implement status
  Future<UsercentricsReadyStatus> get status => throw UnimplementedError();

  @override
  // TODO: implement tcfData
  Future<TCFData> get tcfData => throw UnimplementedError();

  @override
  Future<void> track({required UsercentricsAnalyticsEventType event}) {
    // TODO: implement track
    throw UnimplementedError();
  }

  @override
  // TODO: implement userSessionData
  Future<String> get userSessionData => throw UnimplementedError();

  void _ensureUsercentricsScript({
    String? settingsId,
    String? ruleSetId,
    String? defaultLanguage,
  }) {
    final doc = web.document;

    if (doc.getElementById('usercentrics-cmp') != null) {
      return;
    }

    final script = web.HTMLScriptElement()
      ..id = 'usercentrics-cmp'
      ..src = 'https://web.cmp.usercentrics.eu/ui/loader.js';

    if (settingsId != null && settingsId.isNotEmpty) {
      script.setAttribute('data-settings-id', settingsId);
    } else if (ruleSetId != null && ruleSetId.isNotEmpty) {
      script.setAttribute('data-ruleset-id', ruleSetId);
    }

    if (defaultLanguage != null && defaultLanguage.isNotEmpty) {
      script.setAttribute('data-language', defaultLanguage);
    }

    doc.head!.append(script);
  }
}
