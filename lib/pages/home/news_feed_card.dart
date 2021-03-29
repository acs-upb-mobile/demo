import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_hub_demo/generated/l10n.dart';
import 'package:student_hub_demo/navigation/routes.dart';
import 'package:student_hub_demo/pages/news_feed/model/news_feed_item.dart';
import 'package:student_hub_demo/pages/news_feed/service/news_provider.dart';
import 'package:student_hub_demo/resources/utils.dart';
import 'package:student_hub_demo/widgets/info_card.dart';

class NewsFeedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InfoCard<List<NewsFeedItem>>(
        title: S.of(context).navigationNewsFeed,
        showMoreButtonKey: const ValueKey('show_more_news_feed'),
        onShowMore: () => Navigator.of(context).pushNamed(Routes.newsFeed),
        future: Provider.of<NewsProvider>(context).fetchNewsFeedItems(limit: 2),
        builder: (newsFeedItems) {
          return Column(
              children: newsFeedItems
                  .map((item) => ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.date),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onTap: () =>
                            Utils.launchURL(item.link, context: context),
                      ))
                  .toList());
        });
  }
}
