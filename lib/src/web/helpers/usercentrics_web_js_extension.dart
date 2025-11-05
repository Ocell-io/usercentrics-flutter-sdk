import 'dart:js_interop';

@JS('__ucCmp')
external UCcmpJS? get ucCmpJs;

@JS()
@staticInterop
class UCcmpJS {}

extension UCcmpJSExtension on UCcmpJS {
  external JSPromise showFirstLayer();

  external JSPromise showSecondLayer();

  external JSPromise acceptAllConsents();

  external JSPromise denyAllConsents();

  external JSPromise saveConsents();

  external JSPromise getConsentDetails();

  external JSPromise getControllerId();

  external JSPromise changeLanguage(JSString lang);

  external JSPromise clearUserSession();

  external JSPromise updateServicesConsents(JSArray services);

  external JSPromise updateTcfConsents(JSObject tcfConsents);
}

@JS('window.addEventListener')
external void addWindowEventListener(JSString type, JSFunction callback);

Future<T> awaitJs<T>(JSPromise p) async => (await p.toDart) as T;
