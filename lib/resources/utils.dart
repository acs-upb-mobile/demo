import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:student_hub_demo/authentication/service/auth_provider.dart';
import 'package:student_hub_demo/generated/l10n.dart';
import 'package:student_hub_demo/navigation/routes.dart';
import 'package:student_hub_demo/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

export 'package:student_hub_demo/resources/platform.dart'
    if (dart.library.io) 'dart:io';

Iterable<int> range(int low, int high) sync* {
  for (int i = low; i < high; ++i) {
    yield i;
  }
}

extension IterableUtils<E> on Iterable<E> {
  Iterable<E> whereIndex(bool Function(int index) test) sync* {
    int i = 0;
    for (final e in this) {
      if (test(i++)) yield e;
    }
  }
}

extension EnumUtils on Object {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Utils {
  Utils._();

  static Future<void> launchURL(String url, {BuildContext context}) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (context != null) {
        AppToast.show(S.of(context).errorCouldNotLaunchURL(url));
      }
    }
  }

  static Future<void> signOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    unawaited(Navigator.pushNamedAndRemoveUntil(
        context, Routes.login, (route) => false));
    unawaited(authProvider.signOut());
  }

  static String wrapUrlWithCORS(String url) {
    return 'https://cors-anywhere.herokuapp.com/$url';
  }
}
