import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_hub_demo/pages/people/model/person.dart';
import 'package:student_hub_demo/resources/utils.dart';
import 'package:student_hub_demo/widgets/icon_text.dart';

class PersonView extends StatelessWidget {
  const PersonView({Key key, this.person}) : super(key: key);

  final Person person;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              shape: BoxShape.rectangle,
              border:
                  Border.all(color: Theme.of(context).accentColor, width: 10),
            ),
            child: Center(
              child: Text(person.name,
                  style: Theme.of(context).textTheme.headline6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 16),
                        child: person.photo != null
                            ? CircleAvatar(
                                maxRadius: 50,
                                backgroundImage:
                                    CachedNetworkImageProvider(person.photo),
                              )
                            : const CircleAvatar(
                                radius: 50,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconText(
                            icon: Icons.email,
                            text: person.email ?? '-',
                            style: Theme.of(context).textTheme.bodyText1,
                            onTap: () => Utils.launchURL(
                                'mailto:${person.email}',
                                context: context),
                          ),
                          const SizedBox(height: 16),
                          IconText(
                            icon: Icons.phone,
                            text: person.phone ?? '-',
                            style: Theme.of(context).textTheme.bodyText1,
                            onTap: () => Utils.launchURL('tel:${person.phone}',
                                context: context),
                          ),
                          const SizedBox(height: 16),
                          IconText(
                              icon: Icons.location_on,
                              text: person.office ?? '-',
                              style: Theme.of(context).textTheme.bodyText1),
                          const SizedBox(height: 16),
                          IconText(
                              icon: Icons.work,
                              text: person.position ?? '-',
                              style: Theme.of(context).textTheme.bodyText1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
