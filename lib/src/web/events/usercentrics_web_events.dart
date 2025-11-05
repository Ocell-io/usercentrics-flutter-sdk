import 'dart:async';
import 'dart:js_interop';

import 'package:usercentrics_sdk/src/web/helpers/usercentrics_web_js_extension.dart';
import 'package:usercentrics_sdk/usercentrics_sdk.dart';
import 'package:web/web.dart' as web;

class UsercentricsWebEvents {
  static final _controller = StreamController<UsercentricsEvent>.broadcast();

  static Stream<UsercentricsEvent> get stream => _controller.stream;

  static bool _initialized = false;

  static void init({required String windowEventName}) {
    if (_initialized) {
      return;
    }

    _initialized = true;

    final JSFunction cb = ((web.Event e) {
      final custom = e as web.CustomEvent;
      final detail = custom.detail;
      _controller.add(UsercentricsEvent(custom.type, detail.dartify()));
    }).toJS;

    addWindowEventListener(windowEventName.toJS, cb);
  }
}
