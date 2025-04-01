import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:resky/controller/auth_controller.dart";
import "package:resky/controller/user_controller.dart";
import "package:resky/core/constants/constants.dart";
import "package:resky/pages/comp/prodrawer.dart";
import "package:resky/pages/delegates/search_community.dart";
import "package:routemaster/routemaster.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;
  String role = "Developer"; 

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navToCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void updateRole(BuildContext context){
    ref.read(userProfileControllerProvider.notifier).updateRole(
          context: context,
          role: role.toString(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    if(user.role == null || user.role == "null") {
      return Scaffold(
        backgroundColor: Colors.black, 
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20), 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Welcome ${user.name},",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Choose Your Role:",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: role ?? "Developer",
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black), 
                  items: ["Developer", "Tester","Analyst","Designer","Support","Maintenance"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.black), 
                      ),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    setState(() {
                      if (val != null) {
                        role = val;
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                      updateRole(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), 
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );


    } else {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        shape: const Border(bottom: BorderSide(color: Color.fromARGB(68, 158, 158, 158), width: 0.7)),
        elevation: 0,
        title: const Text('Home',style: TextStyle(color: Colors.white)),
        actions: [
          //search

          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => navToCommunity(context),
              icon: const Icon(Icons.add_box_rounded, color: Colors.white)
            );
            
          }),

          Builder(builder: (context) {
            return IconButton(
              onPressed: () => displayDrawer(context),
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.propic),
                backgroundColor: const Color.fromARGB(68, 158, 158, 158),
              ),
            );
            
          }),

          
        ],
      ),
      body: Constants.tabWidgets[_page],
      endDrawer: const ProfileList(),
      bottomNavigationBar: CupertinoTabBar(
        activeColor: Colors.black,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: ''),
        ],
        onTap: onPageChanged,
        currentIndex: _page,
      ),
    );
    }
  }
}
