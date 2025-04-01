import "package:flutter/material.dart";
import "package:routemaster/routemaster.dart";

class ToolsScreen extends StatelessWidget {
  final String name;
  const ToolsScreen({
    Key? key,
    required this.name,
  }) : super(key: key);

  void navToEditDepart(BuildContext context){
    Routemaster.of(context).push('/$name/edit-depart');
  }

  void navToAddMods(BuildContext context){
    Routemaster.of(context).push('/$name/add-mods');
  }

  void navToReportScreen(BuildContext context){
    Routemaster.of(context).push('/$name/report-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mod Tools'), backgroundColor: Colors.black),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_moderator),
            title: const Text('Add Moderators'),
            onTap: () =>  navToAddMods(context),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Department'),
            onTap: () => navToEditDepart(context),
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('View Reports'),
            onTap: () => navToReportScreen(context),
          )
        ],
      ),
    );
  }
}
