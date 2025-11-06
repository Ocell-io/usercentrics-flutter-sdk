import 'dart:js_interop';

@JS('UC_UI')
external UCcmpJS? get ucCmpJs;

@JS()
@staticInterop
class UCcmpJS {}

extension UCcmpJSExtension on UCcmpJS {
  external JSPromise showSecondLayer();

  external JSPromise getServicesBaseInfo();

  external JSString getControllerId();

  external JSPromise updateLanguage(JSString lang);
}

@JS('window.addEventListener')
external void addWindowEventListener(JSString type, JSFunction callback);

@JS('window.removeEventListener')
external void removeEventListener(JSString type, JSFunction callback);
