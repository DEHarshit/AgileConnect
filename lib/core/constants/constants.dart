import 'package:flutter/material.dart';
import 'package:resky/pages/communities/communities_scr.dart';
import 'package:resky/pages/feeds/feeds_screen.dart';
import 'package:resky/pages/posts/add_posts.dart';

class Constants {
  static const logoPath= 'assets/images/logoholder.png';
  static const google='assets/images/google.png';
  static const loadin='assets/images/loading.gif';

  static const bannerDefault =
      'https://thumbs.dreamstime.com/b/scenary-sunset-sea-twilight-sky-sunset-90913477.jpg';
  static const avatarDefault =
      'https://thumbs.dreamstime.com/b/promenade-river-sunny-autumn-day-empty-bench-riverside-under-tree-yellow-leaves-drava-ptuj-slovenia-299750914.jpg';
      
  static const tabWidgets = [
    FeedScreen(),
    AddPostScreen(),
    AllCommunity(),
  ];

  static const IconData up = IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down = IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);
}