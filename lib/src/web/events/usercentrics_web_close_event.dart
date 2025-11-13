import 'dart:async';
import 'package:usercentrics_sdk/src/web/helpers/usercentrics_web_js_extension.dart';
import 'package:usercentrics_sdk/usercentrics_sdk.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class UsercentricsWebCloseEvent {
  static const String _windowCloseEventName = 'UC_UI_CMP_EVENT';

  final Completer<UsercentricsUserInteraction> _completer =
      Completer<UsercentricsUserInteraction>();

  late final JSFunction _closeCallback;

  UsercentricsUserInteraction _userInteraction =
      UsercentricsUserInteraction.noInteraction;

  Future<UsercentricsUserInteraction> get userInteraction => _completer.future;

  bool _disposed = false;

  bool cmpShown = false;

  UsercentricsWebCloseEvent() {
    _closeCallback = ((web.Event e) {
      final custom = e as web.CustomEvent;
      final mapDetails = custom.detail.dartify();

      if (mapDetails is! Map) {
        return;
      }

      final type = mapDetails['type'];

      if (type is! String) {
        return;
      }

      if (cmpShown) {
        switch (type) {
          case 'CMP_ELIGIBLE':
            Future.delayed(const Duration(milliseconds: 500), dispose);
            break;
          case 'ACCEPT_ALL':
            _userInteraction = UsercentricsUserInteraction.acceptAll;
            break;
          case 'DENY_ALL':
            _userInteraction = UsercentricsUserInteraction.denyAll;
            break;
          case 'SAVE':
            _userInteraction = UsercentricsUserInteraction.granular;
            break;
          default:
            break;
        }
      } else if (type == 'CMP_SHOWN') {
        cmpShown = true;
      }
    }).toJS;

    addWindowEventListener(_windowCloseEventName.toJS, _closeCallback);
  }

  void dispose() {
    if (!_disposed) {
      _disposed = true;
      removeEventListener(_windowCloseEventName.toJS, _closeCallback);
      if (!_completer.isCompleted) {
        _completer.complete(_userInteraction);
      }
    }
  }
}
