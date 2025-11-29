import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../live/domain/live_class_bloc.dart';
import '../../../live/domain/live_class_event.dart';
import '../../../live/domain/live_class_state.dart';
import 'live_class_detail_screen.dart';

class LiveClassesScreen extends HookWidget {
  const LiveClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read<LiveClassBloc>().add(LoadLiveClassesRequested());
      return null;
    }, []);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Live Classes")),
      child: BlocBuilder<LiveClassBloc, LiveClassState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          return ListView.builder(
            itemCount: state.classes.length,
            itemBuilder: (context, index) {
              final live = state.classes[index];

              return CupertinoListTile(
                title: Text(live.title),
                additionalInfo: Text(
                  live.scheduledAt != null
                      ? live.scheduledAt!.toLocal().toString()
                      : "No date",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) =>
                          LiveClassDetailScreen(liveClassId: live.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
