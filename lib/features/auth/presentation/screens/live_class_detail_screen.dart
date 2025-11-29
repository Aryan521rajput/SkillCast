import 'package:flutter/cupertino.dart';
// ignore: library_prefixes
// import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as CupertinoDialog;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../live/domain/live_class_bloc.dart';
import '../../../live/domain/live_class_event.dart';
import '../../../live/domain/live_class_state.dart';

class LiveClassDetailScreen extends StatelessWidget {
  final String liveClassId;
  const LiveClassDetailScreen({super.key, required this.liveClassId});

  @override
  Widget build(BuildContext context) {
    // Trigger load event when screen opens
    context.read<LiveClassBloc>().add(
      LoadLiveClassDetailRequested(liveClassId),
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Live Class Details"),
      ),
      child: SafeArea(
        child: BlocBuilder<LiveClassBloc, LiveClassState>(
          builder: (context, state) {
            if (state.loading || state.selectedClass == null) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final live = state.selectedClass!;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    live.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(live.description),
                  const SizedBox(height: 20),

                  Text(
                    "Instructor: ${live.instructorName}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  const SizedBox(height: 30),

                  CupertinoButton.filled(
                    child: const Text("Join / Reminder"),
                    onPressed: () {
                      // feature coming later
                      CupertinoDialog.showDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text("Feature Coming"),
                          content: const Text(
                            "Joining feature will be added soon.",
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
