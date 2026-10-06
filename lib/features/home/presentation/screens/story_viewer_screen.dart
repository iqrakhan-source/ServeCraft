import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';

class StoryViewerScreen extends StatefulWidget {
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late int _currentIndex;
  Timer? _storyTimer;

  final List<Map<String, String>> _stories = [
    {
      'title': 'Fresh Spaces',
      'subtitle': 'Home Cleaning',
      'description':
      'Give your home the fresh, spotless feeling it deserves.',
      'image':
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=1200',
    },
    {
      'title': 'Cool Comfort',
      'subtitle': 'AC Service',
      'description':
      'Keep your home comfortable with professional AC care.',
      'image':
      'https://images.unsplash.com/photo-1631545806609-7c8d7e5f4b5f?w=1200',
    },
    {
      'title': 'Perfect Finish',
      'subtitle': 'Home Painting',
      'description':
      'Transform your walls with a finish that feels brand new.',
      'image':
      'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=1200',
    },
    {
      'title': 'Little Fixes',
      'subtitle': 'Electrical',
      'description':
      'Reliable electrical services from verified professionals.',
      'image':
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=1200',
    },
  ];

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex.clamp(
      0,
      _stories.length - 1,
    );

    _startTimer();
  }

  void _startTimer() {
    _storyTimer?.cancel();

    _storyTimer = Timer(
      const Duration(seconds: 5),
      _nextStory,
    );
  }

  void _nextStory() {
    if (!mounted) return;

    if (_currentIndex < _stories.length - 1) {
      setState(() {
        _currentIndex++;
      });

      _startTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });

      _startTimer();
    }
  }

  void _handleTap(TapUpDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition.dx;

    if (tapPosition < screenWidth / 2) {
      _previousStory();
    } else {
      _nextStory();
    }
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = _stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: _handleTap,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 500) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // --------------------------------------------------
            // STORY IMAGE
            // --------------------------------------------------

            Image.network(
              story['image']!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surfaceDark,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                );
              },
            ),

            // --------------------------------------------------
            // DARK GRADIENT
            // --------------------------------------------------

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [
                      0.0,
                      0.45,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),

            // --------------------------------------------------
            // TOP CONTENT
            // --------------------------------------------------

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  10,
                  12,
                  0,
                ),
                child: Column(
                  children: [
                    // Progress indicators
                    Row(
                      children: List.generate(
                        _stories.length,
                            (index) {
                          final isCompleted =
                              index < _currentIndex;

                          final isCurrent =
                              index == _currentIndex;

                          return Expanded(
                            child: Container(
                              height: 3,
                              margin:
                              const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isCompleted || isCurrent
                                    ? Colors.white
                                    : Colors.white38,
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Luxe Salon & Spa',
                                style: AppTypography.titleSmall
                                    .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Curated for you',
                                style: AppTypography.bodySmall
                                    .copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --------------------------------------------------
            // BOTTOM CONTENT
            // --------------------------------------------------

            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        story['subtitle']!,
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      story['title']!,
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      story['description']!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // We will connect this to
                          // the service details page next.
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Explore ${story['subtitle']}',
                          style:
                          AppTypography.buttonMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}