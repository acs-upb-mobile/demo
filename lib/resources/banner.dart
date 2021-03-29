import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:student_hub_demo/generated/l10n.dart';

class UniBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/icons/acs_logo.png',
                  height: 80,
                ),
                Image.asset(
                  S.of(context).fileAcsBanner,
                  color: Theme.of(context).textTheme.headline6.color,
                  height: 50,
                ),
              ],
            ),
          ),
        ],
      );
}
