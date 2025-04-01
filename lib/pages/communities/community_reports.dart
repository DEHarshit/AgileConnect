import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:resky/pages/comp/error_text.dart";
import "package:resky/pages/comp/loader.dart";
import "package:resky/pages/comp/post_card.dart";
import 'package:resky/controller/community_controller.dart';
import 'package:resky/controller/reports_controller.dart';
import "package:resky/pages/comp/report_card.dart";

class ReportsScreen extends ConsumerWidget {
  final String name;
  const ReportsScreen({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityReports = ref.watch(getCommunityReportsProvider(name));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("User Reports"),
      ),
      body: communityReports.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              final report = data[index];
              return Column(
                children: [
                  ReportCard(
                    report: report,
                  ),
                  const SizedBox(
                    height: 3,
                  )
                ],
              );
            },
          );
        },
        error: (error, stackTrace) {
          return ErrorText(error: error.toString());
        },
        loading: () => const Loader(),
      ),
    );
  }
}
