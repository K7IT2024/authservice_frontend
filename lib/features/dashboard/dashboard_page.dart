import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/auth_api.dart';
import '../../core/models/user_profile.dart';
import 'package:auth_flutter/core/storage/secure_storage_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  bool loading = true;

  UserProfile? profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    try {

      profile = await AuthApi.getProfile();

    } catch (e) {

      debugPrint(e.toString());

    }

    if (!mounted) return;

    setState(() {

      loading = false;

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF4F6F8),

      appBar: AppBar(

        backgroundColor: Colors.blue,

        foregroundColor: Colors.white,

        elevation: 0,

        title: const Row(

          children: [

            Icon(Icons.security),

            SizedBox(width: 10),

            Text(

              "K7 IAM Portal",

              style: TextStyle(

                fontWeight: FontWeight.bold,

              ),

            )

          ],

        ),

       actions: [

      Stack(

        children: [

          IconButton(

            icon: const Icon(Icons.notifications),

            onPressed: () {},

          ),

          Positioned(

            right: 10,

            top: 10,

            child: Container(

              width: 10,

              height: 10,

              decoration: const BoxDecoration(

                color: Colors.red,

                shape: BoxShape.circle,

              ),

            ),

          )

    ],

  ),

  PopupMenuButton(

    child: Padding(

      padding: const EdgeInsets.symmetric(

          horizontal: 12),

      child: CircleAvatar(

        backgroundColor: Colors.white,

        child: Text(

          "${profile?.firstName.substring(0,1) ?? "U"}",

          style: const TextStyle(

            color: Colors.blue,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

    ),

    itemBuilder: (_) => [

      const PopupMenuItem(

        value: "profile",

        child: Text("My Profile"),

      ),

      const PopupMenuItem(

        value: "settings",

        child: Text("Settings"),

      ),

      const PopupMenuItem(

        value: "logout",

        child: Text("Logout"),

      ),

    ],

    onSelected: (value) {

      switch(value){

        case "profile":

          context.go("/profile");

          break;

        case "settings":

          context.go("/settings");

          break;

        case "logout":

          logout();

      }

    },

  )

],

      ),

      body: loading

          ? const Center(

              child: CircularProgressIndicator(),

            )

          : LayoutBuilder(

              builder: (context, constraints) {

                if (constraints.maxWidth > 1000) {

                  return desktopLayout();

                }

                if (constraints.maxWidth > 650) {

                  return tabletLayout();

                }

                return mobileLayout();

              },

            ),

    );

  }

  //--------------------------------------------------
  // Desktop Layout
  //--------------------------------------------------

  Widget desktopLayout() {

    return SingleChildScrollView(

      padding: const EdgeInsets.all(20),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Expanded(

            flex: 2,

            child: Column(

              children: [

                profileCard(),

                const SizedBox(height: 20),

                quickActions(),

              ],

            ),

          ),

          const SizedBox(width: 20),

          Expanded(

            flex: 3,

            child: Column(

              children: [

                welcomeCard(),

                const SizedBox(height: 20),

                statisticsSection(),

                const SizedBox(height:20),

                applicationsCard(),

                const SizedBox(height: 20),

                activityCard(),

              ],

            ),

          ),

        ],

      ),

    );

  }

  //--------------------------------------------------
  // Tablet Layout
  //--------------------------------------------------

  Widget tabletLayout() {

    return SingleChildScrollView(

      padding: const EdgeInsets.all(20),

      child: Column(

        children: [

          welcomeCard(),

          const SizedBox(height: 20),

          profileCard(),

          const SizedBox(height: 20),

          quickActions(),

          const SizedBox(height: 20),

          statisticsSection(),

          const SizedBox(height:20),

          applicationsCard(),

          const SizedBox(height: 20),

          activityCard(),

        ],

      ),

    );

  }

  //--------------------------------------------------
  // Mobile Layout
  //--------------------------------------------------

  Widget mobileLayout() {

    return SingleChildScrollView(

      padding: const EdgeInsets.all(16),

      child: Column(

        children: [

          welcomeCard(),

          const SizedBox(height: 16),

          profileCard(),

          const SizedBox(height: 16),

          quickActions(),

          const SizedBox(height: 16),

          applicationsCard(),

          const SizedBox(height: 16),

          activityCard(),

        ],

      ),

    );

  }

  //==========================================================
  // Welcome Card
  //==========================================================

Widget welcomeCard() {

  String initials = "U";

  if (profile != null) {

    final first =
        profile!.firstName.isNotEmpty
            ? profile!.firstName[0]
            : "";

    final last =
        profile!.lastName.isNotEmpty
            ? profile!.lastName[0]
            : "";

    initials = "$first$last".toUpperCase();

    if (initials.isEmpty) {
      initials = "U";
    }
  }

  return Container(

  decoration: BoxDecoration(

    borderRadius: BorderRadius.circular(20),

    gradient: const LinearGradient(

      colors: [

        Color(0xff1565C0),

        Color(0xff42A5F5),

      ],

    ),

  ),

    child: Padding(

      padding: const EdgeInsets.all(20),

      child: Row(

        children: [

          CircleAvatar(

            radius: 35,

            backgroundColor: Colors.blue,

            child: Text(

              initials,

              style: const TextStyle(

                fontSize: 26,

                color: Colors.white,

                fontWeight: FontWeight.bold,

              ),

            ),

          ),

          const SizedBox(width: 20),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(

                  "Welcome Back 👋",

                  style: TextStyle(

                    color: Colors.grey,

                    fontSize: 16,

                  ),

                ),

                const SizedBox(height: 5),

                Text(

                  "${profile?.firstName ?? ""} ${profile?.lastName ?? ""}",

                  style: const TextStyle(

                    fontWeight: FontWeight.bold,

                    fontSize: 26,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  profile?.active == true

                      ? "Your IAM account is active."

                      : "Please verify your account.",

                  style: const TextStyle(

                    color: Colors.grey,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    ),

  );

}

  //==========================================================
  // Profile Card
  //==========================================================
Widget profileCard() {

  return Card(

    elevation: 3,

    shape: RoundedRectangleBorder(

      borderRadius: BorderRadius.circular(15),

    ),

    child: Padding(

      padding: const EdgeInsets.all(20),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(

            "Profile",

            style: TextStyle(

              fontSize: 22,

              fontWeight: FontWeight.bold,

            ),

          ),

          const Divider(),

          infoTile(

            Icons.person,

            "Name",

            "${profile?.firstName ?? ""} ${profile?.lastName ?? ""}",

          ),

          infoTile(

            Icons.email,

            "Email",

            profile?.email ?? "",

          ),

          infoTile(

            Icons.phone,

            "Mobile",

            profile?.mobile ?? "",

          ),

          infoTile(

            Icons.verified_user,

            "Status",

            profile?.active == true

                ? "ACTIVE"

                : "INACTIVE",

          ),

          const SizedBox(height: 20),

          Wrap(

            spacing: 10,

            runSpacing: 10,

            children: [

              verificationChip(

                profile?.emailVerified ?? false,

                "Email",

              ),

              verificationChip(

                profile?.mobileVerified ?? false,

                "Mobile",

              ),

            ],

          ),

        ],

      ),

    ),

  );

}

  //==========================================================
  // Info Tile Card
  //==========================================================
Widget infoTile(

    IconData icon,

    String title,

    String value) {

  return Padding(

    padding:
        const EdgeInsets.symmetric(vertical: 8),

    child: Row(

      children: [

        Icon(

          icon,

          color: Colors.blue,

        ),

        const SizedBox(width: 10),

        Expanded(

          child: Text(

            title,

            style: const TextStyle(

              fontWeight: FontWeight.bold,

            ),

          ),

        ),

        Expanded(

          flex: 2,

          child: Text(value),

        ),

      ],

    ),

  );

}

Widget verificationChip(

    bool verified,

    String label) {

  return Chip(

    avatar: Icon(

      verified

          ? Icons.check_circle

          : Icons.error,

      color:

          verified

              ? Colors.green

              : Colors.orange,

      size: 18,

    ),

    label: Text(

      verified

          ? "$label Verified"

          : "$label Pending",

    ),

    backgroundColor:

        verified

            ? Colors.green.shade50

            : Colors.orange.shade50,

  );

} 

  //==========================================================
  // Quick Action Card
  //==========================================================
 Widget quickActions() {

  return Card(

    elevation: 3,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),

    child: Padding(

      padding: const EdgeInsets.all(20),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(

            "Quick Actions",

            style: TextStyle(

              fontSize: 22,

              fontWeight: FontWeight.bold,

            ),

          ),

          const SizedBox(height: 20),

          GridView.count(

            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            crossAxisCount: 2,

            mainAxisSpacing: 15,

            crossAxisSpacing: 15,

            childAspectRatio: 1.3,

            children: [

              quickActionCard(
                icon: Icons.person,
                title: "My Profile",
                color: Colors.blue,
                onTap: () {
                  context.go("/profile");
                },
              ),

              quickActionCard(
                icon: Icons.lock_reset,
                title: "Change Password",
                color: Colors.orange,
                onTap: () {
                  context.go("/change-password");
                },
              ),

              quickActionCard(
                icon: Icons.history,
                title: "Login History",
                color: Colors.green,
                onTap: () {
                  context.go("/login-history");
                },
              ),

              quickActionCard(
                icon: Icons.logout,
                title: "Logout",
                color: Colors.red,
                onTap: () async {

                  await SecureStorageService.clear();

                  if (!mounted) return;

                  context.go("/login");

                },
              ),

            ],

          )

        ],

      ),

    ),

  );

}
Widget quickActionCard({

  required IconData icon,

  required String title,

  required Color color,

  required VoidCallback onTap,

}) {

  return InkWell(

    borderRadius: BorderRadius.circular(15),

    onTap: onTap,

    child: Card(

      color: color.withOpacity(.08),

      elevation: 0,

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          CircleAvatar(

            radius: 25,

            backgroundColor: color,

            child: Icon(

              icon,

              color: Colors.white,

            ),

          ),

          const SizedBox(height: 12),

          Text(

            title,

            style: const TextStyle(

              fontWeight: FontWeight.bold,

            ),

            textAlign: TextAlign.center,

          ),

        ],

      ),

    ),

  );

}
  //==========================================================
  // Application Card
  //==========================================================
  Widget applicationsCard() {

  return Card(

    elevation: 3,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),

    child: Padding(

      padding: const EdgeInsets.all(20),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(

            "Applications",

            style: TextStyle(

              fontSize: 22,

              fontWeight: FontWeight.bold,

            ),

          ),

          const Divider(),

          applicationTile(

            "Employee Management",

            Icons.people,

          ),

          applicationTile(

            "HR Portal",

            Icons.badge,

          ),

          applicationTile(

            "E-Commerce",

            Icons.shopping_cart,

          ),

          applicationTile(

            "Lokal",

            Icons.location_city,

          ),

        ],

      ),

    ),

  );

}
Widget applicationTile(

    String name,

    IconData icon) {

  return Card(

    elevation: 0,

    child: ListTile(

      leading: CircleAvatar(

        backgroundColor: Colors.blue.shade50,

        child: Icon(

          icon,

          color: Colors.blue,

        ),

      ),

      title: Text(name),

      trailing: const Icon(

        Icons.arrow_forward_ios,

        size: 16,

      ),

      onTap: () {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text("$name Coming Soon"),

          ),

        );

      },

    ),

  );

}
 //==========================================================
  // Activity Card
  //==========================================================
 Widget activityCard() {

  return Card(

    elevation: 3,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),

    child: Padding(

      padding: const EdgeInsets.all(20),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(

            "Recent Activity",

            style: TextStyle(

              fontWeight: FontWeight.bold,

              fontSize: 22,

            ),

          ),

          const Divider(),

          activityTile(

            Icons.login,

            "Logged in successfully",

            Colors.green,

          ),

          activityTile(

            Icons.email,

            "Email verified",

            Colors.blue,

          ),

          activityTile(

            Icons.phone_android,

            "Mobile verified",

            Colors.orange,

          ),

          activityTile(

            Icons.lock,

            "Password updated",

            Colors.purple,

          ),

        ],

      ),

    ),

  );

}
Widget activityTile(

    IconData icon,

    String title,

    Color color) {

  return ListTile(

    leading: CircleAvatar(

      radius: 18,

      backgroundColor: color.withOpacity(.15),

      child: Icon(

        icon,

        color: color,

        size: 20,

      ),

    ),

    title: Text(title),

    subtitle: const Text(

      "Just now",

    ),

  );

}
Widget statisticsSection() {

  return GridView.count(

    shrinkWrap: true,

    physics: const NeverScrollableScrollPhysics(),

    crossAxisCount: 2,

    crossAxisSpacing: 15,

    mainAxisSpacing: 15,

    childAspectRatio: 1.8,

    children: [

      statisticCard(
        "Applications",
        "4",
        Icons.apps,
        Colors.blue,
      ),

      statisticCard(
        "Security Score",
        "100%",
        Icons.security,
        Colors.green,
      ),

      statisticCard(
        "Last Login",
        "Today",
        Icons.login,
        Colors.orange,
      ),

    ],

  );

}
Widget statisticCard(

    String title,

    String value,

    IconData icon,

    Color color) {

  return Card(

    elevation: 3,

    shape: RoundedRectangleBorder(

      borderRadius: BorderRadius.circular(15),

    ),

    child: Padding(

      padding: const EdgeInsets.all(20),

      child: Row(

        children: [

          CircleAvatar(

            radius: 25,

            backgroundColor: color,

            child: Icon(

              icon,

              color: Colors.white,

            ),

          ),

          const SizedBox(width: 15),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Text(

                  value,

                  style: const TextStyle(

                    fontSize: 22,

                    fontWeight: FontWeight.bold,

                  ),

                ),

                const SizedBox(height: 5),

                Text(title),

              ],

            ),

          )

        ],

      ),

    ),

  );

}
Future<void> logout() async {

  await SecureStorageService.clear();

  if(!mounted) return;

  context.go("/login");

}
}