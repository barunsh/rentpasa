import 'package:flutter/material.dart';

import '../../models/post_data.dart';
import 'dashboard_items.dart';

class Dashboardlist extends StatelessWidget {
  final List<Post> posts;

  const Dashboardlist({Key? key, required this.posts}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          height: 200,
          child: DashboardItem(
            post: posts[index],
          ),
        ),
      ),
    );
  }
}
