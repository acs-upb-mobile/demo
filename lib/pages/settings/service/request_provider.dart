import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:student_hub_demo/generated/l10n.dart';
import 'package:student_hub_demo/pages/settings/model/request.dart';
import 'package:student_hub_demo/resources/utils.dart';
import 'package:student_hub_demo/widgets/toast.dart';

extension RequestExtension on Request {
  Map<String, dynamic> toData() {
    final Map<String, dynamic> data = {};

    if (userId != null) data['addedBy'] = userId;
    if (requestBody != null) data['requestBody'] = requestBody;
    data['done'] = processed;
    data['dateSubmitted'] = Timestamp.now();
    data['type'] = type.toShortString();

    return data;
  }
}

class RequestProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool userAlreadyRequestedCache;

  Future<bool> makeRequest(Request request, {BuildContext context}) async {
    assert(request.requestBody != null);

    try {
      CollectionReference ref;
      ref = _db.collection('forms');

      final data = request.toData();
      await ref.add(data);

      return userAlreadyRequestedCache = true;
    } catch (e) {
      print(e);
      if (context != null) {
        AppToast.show(S.of(context).errorSomethingWentWrong);
      }
      return userAlreadyRequestedCache = false;
    }
  }

  Future<bool> userAlreadyRequested(final String userId,
      {BuildContext context}) async {
    if (userAlreadyRequestedCache != null) return userAlreadyRequestedCache;

    try {
      final DocumentSnapshot snap =
          await _db.collection('forms').doc(userId).get();
      if (snap.data() != null) {
        return userAlreadyRequestedCache = true;
      }
      return userAlreadyRequestedCache = false;
    } catch (e) {
      print(e);
      if (context != null) {
        AppToast.show(S.of(context).errorSomethingWentWrong);
      }
      return userAlreadyRequestedCache = false;
    }
  }
}
