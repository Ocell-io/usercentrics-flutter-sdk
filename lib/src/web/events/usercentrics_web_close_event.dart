import 'dart:async';
import 'package:usercentrics_sdk/src/web/helpers/usercentrics_web_js_extension.dart';
import 'package:usercentrics_sdk/usercentrics_sdk.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class UsercentricsWebCloseEvent {
  static const String _windowCloseEventName = 'UC_UI_VIEW_CHANGED';
  static const String _windowInteractionEventName = 'UC_UI_CMP_EVENT';

  final Completer<UsercentricsUserInteraction> _completer =
      Completer<UsercentricsUserInteraction>();

  late final JSFunction _closeCallback;
  late final JSFunction _interactionCallback;

  UsercentricsUserInteraction? _userInteraction;

  Future<UsercentricsUserInteraction> get userInteraction => _completer.future;

  bool _disposed = false;

  bool cmpShown = false;

  void disposeView() =>
      Future.delayed(const Duration(milliseconds: 500), dispose);

  UsercentricsWebCloseEvent() {
    _closeCallback = ((web.Event e) {
      final custom = e as web.CustomEvent;
      final mapDetails = custom.detail.dartify();

      if (mapDetails is! Map) {
        return;
      }

      final view = mapDetails['view'];

      if (view is! String) {
        return;
      }

      switch (view) {
        case 'NONE':
          if (cmpShown) {
            disposeView();
          }
          break;
        case 'PRIVACY_BUTTON':
          if (cmpShown) {
            disposeView();
          }
          break;
        default:
          cmpShown = true;
          break;
      }
    }).toJS;

    addWindowEventListener(_windowCloseEventName.toJS, _closeCallback);

    _interactionCallback = ((web.Event e) {
      final custom = e as web.CustomEvent;
      final mapDetails = custom.detail.dartify();

      if (mapDetails is! Map) {
        return;
      }

      final type = mapDetails['type'];

      if (type is! String) {
        return;
      }

      switch (type) {
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
    }).toJS;

    addWindowEventListener(
        _windowInteractionEventName.toJS, _interactionCallback);
  }

  void dispose() {
    if (!_disposed) {
      _disposed = true;
      removeEventListener(_windowCloseEventName.toJS, _closeCallback);
      removeEventListener(
          _windowInteractionEventName.toJS, _interactionCallback);
      if (!_completer.isCompleted) {
        _completer.complete(
            _userInteraction ?? UsercentricsUserInteraction.noInteraction);
      }
    }
  }
}
