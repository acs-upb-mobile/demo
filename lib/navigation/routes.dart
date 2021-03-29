import 'package:student_hub_demo/authentication/view/login_view.dart';
import 'package:student_hub_demo/authentication/view/sign_up_view.dart';
import 'package:student_hub_demo/pages/faq/view/faq_page.dart';
import 'package:student_hub_demo/pages/filter/view/filter_page.dart';
import 'package:student_hub_demo/pages/news_feed/view/news_feed_page.dart';
import 'package:student_hub_demo/pages/settings/view/request_permissions.dart';
import 'package:student_hub_demo/pages/settings/view/settings_page.dart';

class Routes {
  Routes._();

  static const String root = '/';
  static const String home = '/home';
  static const String settings = SettingsPage.routeName;
  static const String filter = FilterPage.routeName;
  static const String login = LoginView.routeName;
  static const String signUp = SignUpView.routeName;
  static const String faq = FaqPage.routeName;
  static const String newsFeed = NewsFeedPage.routeName;
  static const String requestPermissions = RequestPermissionsPage.routeName;
}
