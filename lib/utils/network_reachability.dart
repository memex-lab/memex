import 'dart:io';

/// Best-effort check that the device can resolve a public DNS name.
///
/// This is intentionally coarse: captive portals and firewalls may still block
/// LLM APIs even when lookup succeeds.
Future<bool> canReachPublicInternet({
  Duration timeout = const Duration(seconds: 2),
}) async {
  try {
    final result = await InternetAddress.lookup('one.one.one.one').timeout(
      timeout,
    );
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
