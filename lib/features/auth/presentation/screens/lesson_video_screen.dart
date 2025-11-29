import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

class LessonVideoScreen extends HookWidget {
  final String videoUrl;
  const LessonVideoScreen({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(
      () => VideoPlayerController.networkUrl(Uri.parse(videoUrl)),
    );

    final initialized = useState(false);

    useEffect(() {
      controller.initialize().then((_) {
        initialized.value = true;
        controller.play();
      });
      return controller.dispose;
    }, []);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Lesson Video")),
      child: SafeArea(
        child: Center(
          child: initialized.value
              ? AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(controller),
                      _ControlsOverlay(controller: controller),
                      VideoProgressIndicator(controller, allowScrubbing: true),
                    ],
                  ),
                )
              : const CupertinoActivityIndicator(),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.2),
        child: Center(
          child: Icon(
            controller.value.isPlaying
                ? CupertinoIcons.pause_circle
                : CupertinoIcons.play_circle,
            color: CupertinoColors.white,
            size: 70,
          ),
        ),
      ),
    );
  }
}
