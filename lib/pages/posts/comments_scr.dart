import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resky/controller/posts_controller.dart';
import 'package:resky/pages/comp/comment.card.dart';
import 'package:resky/pages/comp/error_text.dart';
import 'package:resky/pages/comp/loader.dart';
import 'package:resky/pages/comp/post_card.dart';
import 'package:resky/models/comment_model.dart';
import 'package:resky/pages/comp/prodrawer.dart';
import 'package:resky/services/summarization_service.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

void addComment(String postId) async {
  final post = ref.read(getPostByIdProvider(postId)).requireValue;
  String commentText = commentController.text.trim();

  RegExp taskPattern = RegExp(r"(?:task\s*((?:\d+\s*)+))", caseSensitive: false);
  Match? taskMatch = taskPattern.firstMatch(commentText);

  if (taskMatch != null) {
    List<String> tasks = taskMatch
        .group(1)!
        .split(RegExp(r"\s+"))
        .where((t) => t.isNotEmpty)
        .map((t) => "Task $t") // Ensure format matches summary
        .toList();

    Map<String, Set<String>> prevTaskAllocations = {};

    // Extract previous task assignments from the manual summary
    if (post.manualSummary != null) {
      for (var line in post.manualSummary!.split("\n")) {
        if (line.startsWith("-")) {
          var parts = line.split(":");
          if (parts.length == 2) {
            String task = parts[0].substring(2).trim(); // e.g., "Task 3"
            Set<String> assignedUsers =
                parts[1].split(",").map((e) => e.trim()).toSet();
            prevTaskAllocations[task] = assignedUsers;
          }
        }
      }
    }

    // Check for conflicts
    Map<String, List<String>> conflicts = {};
    for (String task in tasks) {
      if (prevTaskAllocations.containsKey(task)) {
        conflicts[task] = prevTaskAllocations[task]!.toList();
      }
    }

    // Handle conflicts
    if (conflicts.isNotEmpty) {
      for (var entry in conflicts.entries) {
        String conflictingTask = entry.key;
        List<String> assignedUsers = entry.value;

        String response = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("$conflictingTask Already Assigned"),
            content: Text(
                "$conflictingTask is already assigned to ${assignedUsers.join(', ')}. Do you want to:\n\n"
                "1. Split the responsibility\n"
                "2. Keep it as is"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, "split"),
                child: Text("Split"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, "cancel"),
                child: Text("Cancel"),
              ),
            ],
          ),
        );

        if (response == "split") {
          commentText = "$conflictingTask";
        } else {
          commentText += "¤"; // Mark as ignored
        }
      }
    }
  }

  ref.read(postControllerProvider.notifier).addComment(
        context: context,
        text: commentText,
        post: post,
        type: 'post',
      );

  setState(() {
    commentController.text = '';
  });

  summarizeWithoutAI(shouldUpdatePost: true);
}


  void summarizeWithAI() async {
    final post = ref.read(getPostByIdProvider(widget.postId)).requireValue;
    final comments =
        ref.read(getPostCommentsProvider(widget.postId)).requireValue;

    if (comments.isEmpty) {
      showSummaryDialog("Post Summary", post.description);
      return;
    }

    comments.sort((a, b) => b.upvotes.length.compareTo(a.upvotes.length));

    List<String> topComments = comments.take(5).map((c) => c.text).toList();

    String inputText = """
  Post: ${post.title ?? "No Title"}
  ${post.description}

  Top Comments:
  ${topComments.join("\n")}
  """;

    String aiSummary = await SummarizationService.summarizeText(inputText);

    showSummaryDialog("AI Discussion Summary", aiSummary);
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  String formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  void summarizeWithoutAI({bool shouldUpdatePost = false}) {
    final post = ref.read(getPostByIdProvider(widget.postId)).requireValue;
    final comments =
        ref.read(getPostCommentsProvider(widget.postId)).requireValue;

    String postSummary = """
👤 Team Lead:     ${post.username}
📄 Project Title:   Chat Application

═════════════════════════

📅 Session Date:       ${formatDateTime(post.createdAt)}
🕒 Start Time:           ${formatTime(post.createdAt)}
🕒 End Time:             ${post.endsAt != null ? formatTime(post.endsAt!) : "Not Provided"}
📄 Description:          

${post.description ?? "No description available."}
""";

    Map<String, Set<String>> taskToUsers = {};
    Map<String, Set<String>> moduleToUsers = {};
    Map<String, List<String>> taskComments = {};
    Map<String, List<String>> moduleComments = {};
    Map<String, String> taskStatuses = {};
    Map<String, String> moduleStatuses = {};
    List<String> majorDecisions = [];

    RegExp taskPattern =
        RegExp(r"(?:task\s*((?:\d+\s*)+))", caseSensitive: false);
    RegExp modulePattern =
        RegExp(r"(?:module\s*((?:\d+\s*)+))", caseSensitive: false);
    RegExp statusPattern = RegExp(
    r"(task|module)\s*(\d+)\s*(?:is|has been)?\s*(completed|done|over|on hold)",
    caseSensitive: false);

    Map<String, Set<String>> prevTaskToUsers = {};
    Map<String, Set<String>> prevModuleToUsers = {};

    if (post.prevManSummary != null) {
      for (var line in post.prevManSummary!.split("\n")) {
        if (line.startsWith("-")) {
          var parts = line.split(":");
          if (parts.length == 2) {
            String item = parts[0].substring(2).trim();
            Set<String> users =
                parts[1].split(",").map((e) => e.trim()).toSet();
            if (item.startsWith("Task")) {
              prevTaskToUsers[item] = users;
            } else if (item.startsWith("Module")) {
              prevModuleToUsers[item] = users;
            }
          }
        }
      }
    }

    for (var comment in comments) {
      String user = comment.username;
      String text = comment.text;

       Match? statusMatch = statusPattern.firstMatch(comment.text);
  if (statusMatch != null) {
    String type = statusMatch.group(1)!.toLowerCase(); 
    String id = statusMatch.group(2)!;
    String status = statusMatch.group(3)!.toLowerCase();

    String formattedStatus =
        (status == "done" || status == "completed" || status == "over")
            ? "✅ Completed"
            : (status == "tested") ? "🧪 Tested" : "⏳ On Hold";

    if (type == "task") {
      taskStatuses["Task $id"] = formattedStatus;
    } else {
      moduleStatuses["Module $id"] = formattedStatus;
    }
    continue;
  }

      Match? taskMatch = taskPattern.firstMatch(text);
      if (taskMatch != null && !text.endsWith("¤")) {
        Set<String> tasks = taskMatch
            .group(1)!
            .split(RegExp(r"\s+"))
            .where((t) => t.isNotEmpty)
            .map((t) => "Task $t")
            .toSet();

        for (String task in tasks) {
    prevTaskToUsers.forEach((prevTask, users) {
        if (users.contains(user) && prevTask != task) {
            prevTaskToUsers[prevTask]!.remove(user);
        }
    });

    taskToUsers.putIfAbsent(task, () => {}).add(user);
    taskComments
        .putIfAbsent(task, () => [])
        .add("- $user says \"$text\"");
}
      }

      if (user == post.username) {
        RegExp leaderAssignPattern = RegExp(
          r"(\w+)\s+will\s+be\s+doing\s+Task\s+(\d+)",
          caseSensitive: false,
        );
        Match? leaderMatch = leaderAssignPattern.firstMatch(text);

        if (leaderMatch != null) {
          String assignedMember = leaderMatch.group(1)!;
          String assignedTask = "Task ${leaderMatch.group(2)!}";

          prevTaskToUsers.removeWhere((key, value) => value.contains(assignedMember));
          taskToUsers.putIfAbsent(assignedTask, () => {}).add(assignedMember);
        }
      }

      Match? moduleMatch = modulePattern.firstMatch(text);
      if (moduleMatch != null && !text.endsWith("¤")) {
        Set<String> modules = moduleMatch
            .group(1)!
            .split(RegExp(r"\s+"))
            .where((m) => m.isNotEmpty)
            .map((m) => "Module $m")
            .toSet();

        for (String module in modules) {
          prevModuleToUsers.removeWhere((key, value) => value.contains(user));
          moduleToUsers.putIfAbsent(module, () => {}).add(user);
          moduleComments
              .putIfAbsent(module, () => [])
              .add("- $user says \"$text\"");
        }
      }

     

      if (comment.upvotes.length - comment.downvotes.length > 3) {
        majorDecisions.add(
            '''- $user says "${comment.text}" (${comment.upvotes.length} votes)\n''');
      }
    }

    List<String> summarySections = [postSummary];

    if (prevTaskToUsers.isNotEmpty || taskStatuses.isNotEmpty) {
  summarySections.add("""
📌 Task Status:

${prevTaskToUsers.keys.map((task) => "- $task: ${taskStatuses[task] ?? "🟡 Pending"}").join("\n")}
""");
}

// Add Module Status section if any module statuses exist
if (prevModuleToUsers.isNotEmpty || moduleStatuses.isNotEmpty) {
  summarySections.add("""
📌 Module Status:

${prevModuleToUsers.keys.map((module) => "- $module: ${moduleStatuses[module] ?? "🟡 Pending"}").join("\n")}
""");
}

    if (taskToUsers.isNotEmpty || prevTaskToUsers.isNotEmpty) {
      summarySections.add("""
📌 Task Assignments:

${[
        ...prevTaskToUsers.entries,
        ...taskToUsers.entries
      ].map((entry) => "- ${entry.key}: ${entry.value.join(", ")}").join("\n")}
""");
    }

    if (moduleToUsers.isNotEmpty || prevModuleToUsers.isNotEmpty) {
      summarySections.add("""
📌 Module Assignments:

${[
        ...prevModuleToUsers.entries,
        ...moduleToUsers.entries
      ].map((entry) => "- ${entry.key}: ${entry.value.join(", ")}").join("\n")}
""");
    }

    if (taskComments.isNotEmpty) {
      summarySections.add("""
📝 Relevant Task Comments:

${taskComments.entries.map((entry) => "${entry.key}:\n  ${entry.value.join("\n  ")}").join("\n\n")}
""");
    }

    if (moduleComments.isNotEmpty) {
      summarySections.add("""
📝 Relevant Module Comments:

${moduleComments.entries.map((entry) => "${entry.key}:\n  ${entry.value.join("\n  ")}").join("\n\n")}
""");
    }

    if (majorDecisions.isNotEmpty) {
      summarySections.add("""
📌 Major Decisions:

${majorDecisions.join("\n")}
""");
    }

    String finalSummary = summarySections.join("\n\n");

    ref.read(postControllerProvider.notifier).updatePostSummary(
          postId: post.id,
          manualSummary: finalSummary + "\n\n═════════════════════════\n\nPrevious Session(s):\n\n" + (post.prevManSummary ?? ""),
        );

    if (!shouldUpdatePost) {
      showSummaryBottomSheet("Discussion Summary", finalSummary);
    }
}


  void showSummaryBottomSheet(String title, String summary) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(summary, style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.check),
                      label: Text("Got it"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showSummaryDialog(String title, String summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(summary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize, color: Colors.white),
            onPressed: summarizeWithAI,
            tooltip: "AI Summary",
          ),
          IconButton(
            icon: const Icon(Icons.comment, color: Colors.white),
            onPressed: summarizeWithoutAI,
            tooltip: "Regular Summary",
          ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => {Scaffold.of(context).openEndDrawer()},
              icon: const Icon(Icons.menu, color: Colors.white),
            );
          }),
        ],
      ),
      endDrawer: const ProfileList(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (data2) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverPadding(
                    padding: const EdgeInsets.all(0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [PostCard(post: data2)],
                      ),
                    ),
                  ),
                ];
              },
              body: ref.watch(getPostCommentsProvider(widget.postId)).when(
                    data: (data) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Comments . . .',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (data.isEmpty)
                              const Center(child: Text('No comments yet.'))
                            else
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final comment = data[index];
                                    return CommentCard(
                                        comment: comment, depth: 0,leader:data2.username);
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    error: (error, stackTrace) =>
                        ErrorText(error: error.toString()),
                    loading: () => const Loader(),
                  ),
            ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          alignment: Alignment.center,
          height: 45,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(
                    width: 0.5, color: Color.fromARGB(68, 158, 158, 158))),
          ),
          child: Row(
            children: [
              const SizedBox(width: 5),
              Expanded(
                child: SizedBox(
                  height: 35,
                  width: 50,
                  child: TextField(
                    style: const TextStyle(fontSize: 15),
                    controller: commentController,
                    decoration: InputDecoration(
                      fillColor: const Color.fromARGB(68, 158, 158, 158),
                      hintText: 'What are your thoughts?',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide:
                            const BorderSide(width: 0, style: BorderStyle.none),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0.0, horizontal: 7),
                  onPressed: () => addComment(widget.postId),
                  icon: const Icon(Icons.send, color: Colors.black),
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }
}
