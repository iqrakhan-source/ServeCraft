import 'package:flutter/material.dart';
import 'package:prop_crm/core/constants/app_colors.dart';
import 'package:prop_crm/core/constants/app_typography.dart';
import 'package:prop_crm/features/home/presentation/screens/story_viewer_screen.dart';

class CuratedStoriesSection extends StatelessWidget {
  const CuratedStoriesSection({super.key});

  static const List<Map<String, String>> stories = [
    {
      'title': 'Fresh Spaces',
      'subtitle': 'Home Cleaning',
      'image':
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
    },
    {
      'title': 'Cool Comfort',
      'subtitle': 'AC Service',
      'image':
      'https://images.unsplash.com/photo-1631545806609-7c8d7e5f4b5f?w=500',
    },
    {
      'title': 'Perfect Finish',
      'subtitle': 'Home Painting',
      'image':
      'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=500',
    },
    {
      'title': 'Little Fixes',
      'subtitle': 'Electrical',
      'image':
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Curated for you',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thoughtful curation of our finest creations',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              itemCount: stories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final story = stories[index];

                return _StoryCard(
                  title: story['title']!,
                  subtitle: story['subtitle']!,
                  image: story['image']!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryViewerScreen(
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final VoidCallback onTap;

  const _StoryCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 125,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 125,
              height: 145,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: AppColors.surfaceMuted,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textTertiary,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}