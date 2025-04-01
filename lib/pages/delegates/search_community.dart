import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:routemaster/routemaster.dart";
import "package:resky/controller/community_controller.dart";
import "package:resky/pages/comp/error_text.dart";
import "package:resky/pages/comp/loader.dart";

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityDelegate(this.ref);
  @override
  List<Widget>? buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
   return ref.read(searchCommunityProvider(query)).when(data: (departments)=> ListView.builder(
      itemCount: departments.length,
      itemBuilder: (BuildContext context, int index) {
        final department = departments[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(department.avatar),
          ),
          title: Text(department.name),
          onTap: ()=> navToDepartment(context, department.name),
        );
      },
    ), error: (error,StackTrace) => ErrorText(error: error.toString()), loading: () => Loader(),);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return ref.watch(searchCommunityProvider(query)).when(data: (departments)=> ListView.builder(
      itemCount: departments.length,
      itemBuilder: (BuildContext context, int index) {
        final department = departments[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(department.avatar),
          ),
          title: Text(department.id),
          onTap: ()=> navToDepartment(context, department.name),
        );
      },
    ), error: (error,StackTrace) => ErrorText(error: error.toString()), loading: () => Loader(),);
  }

  void navToDepartment(BuildContext context, String departmentname) {
    Routemaster.of(context).push(departmentname);
  }
}
