import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_hub_demo/authentication/service/auth_provider.dart';
import 'package:student_hub_demo/generated/l10n.dart';
import 'package:student_hub_demo/pages/portal/model/website.dart';
import 'package:student_hub_demo/pages/portal/service/website_provider.dart';
import 'package:student_hub_demo/pages/portal/view/website_view.dart';
import 'package:student_hub_demo/resources/utils.dart';
import 'package:student_hub_demo/widgets/info_card.dart';

class FavouriteWebsitesCard extends StatelessWidget {
  const FavouriteWebsitesCard({Key key, this.onShowMore}) : super(key: key);

  final void Function() onShowMore;

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    final String uid = authProvider.uid;
    final WebsiteProvider websiteProvider =
        Provider.of<WebsiteProvider>(context);
    return InfoCard<List<Website>>(
      title: S.of(context).sectionFrequentlyAccessedWebsites,
      onShowMore: onShowMore,
      future:
          websiteProvider.fetchFavouriteWebsites(uid: uid, context: context),
      builder: (websites) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: websites
            .map((website) => Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: WebsiteIcon(
                        website: website,
                        onTap: () {
                          websiteProvider.incrementNumberOfVisits(website,
                              uid: uid);
                          Utils.launchURL(website.link, context: context);
                        },
                      )),
                ))
            .toList(),
      ),
    );
  }
}
