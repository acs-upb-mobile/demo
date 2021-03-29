import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:provider/provider.dart';
import 'package:student_hub_demo/authentication/service/auth_provider.dart';
import 'package:student_hub_demo/generated/l10n.dart';
import 'package:student_hub_demo/pages/classes/model/class.dart';
import 'package:student_hub_demo/pages/classes/service/class_provider.dart';
import 'package:student_hub_demo/pages/classes/view/grading_view.dart';
import 'package:student_hub_demo/pages/classes/view/shortcut_view.dart';
import 'package:student_hub_demo/pages/people/service/person_provider.dart';
import 'package:student_hub_demo/pages/people/view/person_view.dart';
import 'package:student_hub_demo/resources/custom_icons.dart';
import 'package:student_hub_demo/resources/utils.dart';
import 'package:student_hub_demo/widgets/button.dart';
import 'package:student_hub_demo/widgets/class_icon.dart';
import 'package:student_hub_demo/widgets/dialog.dart';
import 'package:student_hub_demo/widgets/icon_text.dart';
import 'package:student_hub_demo/widgets/scaffold.dart';
import 'package:student_hub_demo/widgets/toast.dart';

class ClassView extends StatefulWidget {
  const ClassView({Key key, this.classHeader}) : super(key: key);

  final ClassHeader classHeader;

  @override
  _ClassViewState createState() => _ClassViewState();
}

class _ClassViewState extends State<ClassView> {
  Class classInfo;

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);

    return AppScaffold(
      title: Text(S.of(context).navigationClassInfo),
      body: FutureBuilder(
          future: classProvider.fetchClassInfo(widget.classHeader,
              context: context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              classInfo = snapshot.data;

              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        lecturerCard(context),
                        const SizedBox(height: 8),
                        shortcuts(context),
                        const SizedBox(height: 8),
                        GradingChart(
                          grading: classInfo.grading,
                          lastUpdated: classInfo.gradingLastUpdated,
                          onSave: (grading) => classProvider.setGrading(
                              classId: widget.classHeader.id, grading: grading),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget shortcuts(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).sectionShortcuts,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  GestureDetector(
                    onTap: authProvider.currentUserFromCache.canEditClassInfo
                        ? () {}
                        : () => AppToast.show(
                            S.of(context).warningNoPermissionToEditClassInfo),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed:
                          authProvider.currentUserFromCache.canEditClassInfo
                              ? () => Navigator.of(context).push(
                                      MaterialPageRoute<ChangeNotifierProvider>(
                                    builder: (context) =>
                                        ChangeNotifierProvider.value(
                                      value: classProvider,
                                      child: ShortcutView(onSave: (shortcut) {
                                        setState(() =>
                                            classInfo.shortcuts.add(shortcut));
                                        classProvider.addShortcut(
                                            classId: widget.classHeader.id,
                                            shortcut: shortcut,
                                            context: context);
                                      }),
                                    ),
                                  ))
                              : null,
                    ),
                  ),
                ],
              ),
              const Divider()
            ] +
            (classInfo.shortcuts.isEmpty
                ? <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          S.of(context).labelUnknown,
                          style:
                              TextStyle(color: Theme.of(context).disabledColor),
                        ),
                      ),
                    )
                  ]
                : classInfo.shortcuts
                    .asMap()
                    .map((i, s) => MapEntry(
                        i, shortcut(index: i, shortcut: s, context: context)))
                    .values
                    .toList()),
      ),
    );
  }

  IconData shortcutIcon(ShortcutType type) {
    switch (type) {
      case ShortcutType.main:
        return Icons.home;
      case ShortcutType.classbook:
        return CustomIcons.book;
      case ShortcutType.resource:
        return Icons.insert_drive_file;
      default:
        return Icons.public;
    }
  }

  AppDialog _deletionConfirmationDialog(
          {BuildContext context, String shortcutName, Function onDelete}) =>
      AppDialog(
        icon: const Icon(Icons.delete),
        title: S.of(context).actionDeleteShortcut,
        message: S.of(context).messageDeleteShortcut(shortcutName),
        info: S.of(context).messageThisCouldAffectOtherStudents,
        actions: [
          AppButton(
            text: S.of(context).actionDeleteShortcut,
            width: 130,
            onTap: onDelete,
          )
        ],
      );

  Widget shortcut({int index, Shortcut shortcut, BuildContext context}) {
    final classProvider = Provider.of<ClassProvider>(context);
    final classViewContext = context;

    return PositionedTapDetector(
      onTap: (_) => Utils.launchURL(shortcut.link, context: context),
      onLongPress: (position) async {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject();
        final option = await showMenu(
            context: context,
            position: RelativeRect.fromRect(
                Rect.fromPoints(position.global, position.global),
                Offset.zero & overlay.size),
            items: [
              PopupMenuItem(
                value: S.of(context).actionDeleteShortcut,
                child: Text(S.of(context).actionDeleteShortcut),
              )
            ]);
        if (option == S.of(context).actionDeleteShortcut) {
          await showDialog(
            context: context,
            builder: (context) => _deletionConfirmationDialog(
              context: context,
              shortcutName: shortcut.name,
              onDelete: () async {
                Navigator.pop(context); // Pop dialog window

                final success = await classProvider.deleteShortcut(
                    classId: widget.classHeader.id,
                    shortcutIndex: index,
                    context: context);
                if (success) {
                  setState(() {
                    classInfo.shortcuts.removeAt(index);
                  });
                  AppToast.show(S.of(classViewContext).messageShortcutDeleted);
                }
              },
            ),
          );
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(shortcutIcon(shortcut.type)),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).iconTheme.color,
        ),
        title: Text((shortcut.name?.isEmpty ?? true)
            ? shortcut.type.toLocalizedString(context)
            : shortcut.name),
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget lecturerCard(BuildContext context) {
    final personProvider = Provider.of<PersonProvider>(context);

    return Card(
      key: const Key('LecturerCard'),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClassIcon(classHeader: widget.classHeader),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconText(
                    icon: Icons.class_,
                    text: widget.classHeader.name ?? '-',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  FutureBuilder(
                    future: personProvider
                        .mostRecentLecturer(widget.classHeader.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final lecturerName = snapshot.data;
                        return GestureDetector(
                          onTap: () async {
                            final lecturer =
                                await personProvider.fetchPerson(lecturerName);
                            if (lecturer != null) {
                              await showModalBottomSheet<dynamic>(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext buildContext) =>
                                      PersonView(person: lecturer));
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconText(
                                icon: Icons.person,
                                text: lecturerName ?? '-',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
