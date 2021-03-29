import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:student_hub_demo/generated/l10n.dart';
import 'package:student_hub_demo/widgets/button.dart';
import 'package:student_hub_demo/widgets/icon_text.dart';

class AppDialog extends StatelessWidget {
  const AppDialog(
      {@required this.title,
      Key key,
      this.icon,
      this.message,
      this.info,
      this.content,
      this.actions,
      this.enableCancelButton = true})
      : super(key: key);

  /// Icon to show to the left of the dialog title
  final Icon icon;

  /// Title of dialog
  final String title;

  /// Dialog message
  final String message;

  /// Additional information
  final String info;

  /// Content to be shown under dialog message
  final List<Widget> content;

  /// Action buttons (note: a cancel button is displayed by default, there is no
  /// need to include it here)
  final List<AppButton> actions;

  /// Whether to display a cancel button or not
  final bool enableCancelButton;

  @override
  AlertDialog build(BuildContext context) => AlertDialog(
        title: icon == null
            ? Text(title)
            : Row(
                children: <Widget>[
                  icon,
                  const SizedBox(width: 4),
                  Text(title),
                ],
              ),
        content: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                  if (message != null)
                    Expanded(
                      child: Column(
                        children: [
                          Container(height: 8),
                          Text(message),
                        ],
                      ),
                    ),
                  if (info != null)
                    Column(children: [
                      const SizedBox(height: 8),
                      IconText(
                          icon: Icons.info,
                          text: info,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(color: Theme.of(context).hintColor))
                    ])
                ] +
                (content ?? <Widget>[]),
          ),
        ),
        actions: <Widget>[
              FlatButton(
                key: const ValueKey('cancel_button'),
                child: Text(
                  S.of(context).buttonCancel.toUpperCase(),
                  style: Theme.of(context).textTheme.button,
                ),
                onPressed: () => Navigator.pop(context),
              )
            ] +
            (actions ?? <Widget>[]),
      );
}
