import 'package:flutter/cupertino.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text("SkillCast")),
      child: Center(
        child: Text("Dashboard Coming Soon", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
