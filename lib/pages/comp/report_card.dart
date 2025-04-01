import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:resky/controller/auth_controller.dart';
import 'package:resky/controller/community_controller.dart';
import 'package:resky/controller/posts_controller.dart';
import 'package:resky/core/constants/constants.dart';
import 'package:resky/models/report_model.dart';
import 'package:resky/models/post_model.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:resky/pages/comp/loader.dart';
import 'package:resky/pages/comp/post_card.dart';
import 'package:resky/pages/comp/post_image.dart';
import 'package:resky/controller/reports_controller.dart';

class ReportCard extends ConsumerStatefulWidget {
  final Report report;

  const ReportCard({
    super.key,
    required this.report,
  });

  @override
  ConsumerState<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<ReportCard> {
  late final StateProvider<bool> isTextVisibleProvider;

  @override
  void initState() {
    super.initState();
    // Create a unique provider for this card instance
    isTextVisibleProvider = StateProvider<bool>((ref) => false);
  }

  void deletePost(BuildContext context) async {
    ref
        .read(reportControllerProvider.notifier)
        .deleteReport(widget.report, context);
  }

  @override
  Widget build(BuildContext context) {
    final isTextVisible = ref.watch(isTextVisibleProvider);

    final postAsyncValue = ref.watch(getPostByIdProvider(widget.report.postId));

    return postAsyncValue.when(
      data: (post) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[70],
            border: Border(
                bottom: BorderSide(width: 0.7, color: Colors.grey[300]!)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostCard(post: post, reportId: widget.report.id),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => deletePost(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Resolve Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(isTextVisibleProvider.notifier).state =
                          !isTextVisible;
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      foregroundColor: const Color.fromARGB(68, 158, 158, 158),
                      backgroundColor: isTextVisible
                          ? Colors.white
                          : const Color.fromARGB(68, 158, 158, 158),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: !isTextVisible
                              ? Colors.white
                              : const Color.fromARGB(68, 158, 158, 158),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Text(
                      isTextVisible ? 'Hide Reports' : 'Show Reports',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isTextVisible)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < widget.report.text.length; i++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Text(
                                '${i + 1}. ',
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.report.text[i],
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < widget.report.text.length - 1) Divider(),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Loader(),
      error: (error, stackTrace) => ErrorText(error: error.toString()),
    );
  }
}
