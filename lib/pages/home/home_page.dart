import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_hub_demo/authentication/service/auth_provider.dart';
import 'package:student_hub_demo/generated/l10n.dart';
import 'package:student_hub_demo/navigation/routes.dart';
import 'package:student_hub_demo/pages/home/faq_card.dart';
import 'package:student_hub_demo/pages/home/favourite_websites_card.dart';
import 'package:student_hub_demo/pages/home/news_feed_card.dart';
import 'package:student_hub_demo/pages/home/profile_card.dart';
import 'package:student_hub_demo/widgets/scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({this.tabController, Key key}) : super(key: key);

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AppScaffold(
      title: Text(S.of(context).navigationHome),
      actions: [
        AppScaffoldAction(
          icon: Icons.settings,
          tooltip: S.of(context).navigationSettings,
          route: Routes.settings,
        )
      ],
      body: ListView(
        children: [
          if (authProvider.isAuthenticated) ProfileCard(),
          if (authProvider.isAuthenticated)
            FavouriteWebsitesCard(
                onShowMore: () => tabController?.animateTo(2)),
          NewsFeedCard(),
          FaqCard(),
        ],
      ),
    );
  }
}
