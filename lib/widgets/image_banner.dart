import 'package:flutter/material.dart';

class ImageBanner extends StatefulWidget {
  const ImageBanner({super.key});

  @override
  State<ImageBanner> createState() => _ImageBannerState();
}

class _ImageBannerState extends State<ImageBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Transform.rotate(
      angle: -0.06,
      child: SizedBox(
        width: deviceWidth * 1.3,
        height: deviceWidth * 0.1,
        child: AnimatedBuilder(
          animation: _controller,
          child: Row(
            children: List.generate(
              3,
              (_) => Image.asset(
                'assets/img/banner.png',
                width: deviceWidth * 1.8,
                height: deviceWidth * 0.1,
                fit: BoxFit.cover,
              ),
            ),
          ),
          builder: (context, child) {
            final offset = _controller.value * deviceWidth * 1.8;

            return ClipRect(
              child: OverflowBox(
                maxWidth: (deviceWidth * 3) * 3,
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: Offset(-offset, 0),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
