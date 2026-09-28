import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../services/sound_manager.dart';
import '../glass/glass_container.dart';

class SuggestionCard extends StatelessWidget {
  final String title;
  final int age;
  final int affinity; // 0 - 100
  final String rationale;
  final VoidCallback onOpen;
  final VoidCallback? onHide;

  const SuggestionCard({
    super.key,
    required this.title,
    required this.age,
    required this.affinity,
    required this.rationale,
    required this.onOpen,
    this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title, $age years old, $affinity percent vibe affinity',
      hint: rationale,
      button: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: VibeTokens.space3),
        child: GlassContainer(
          padding: const EdgeInsets.all(VibeTokens.space4),
          borderRadius: VibeTokens.radiusLg,
          onTap: () {
            SoundManager().playTap();
            onOpen();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar with Ambient Glow
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: VibeTokens.heroGradient,
                      boxShadow: [
                        BoxShadow(
                          color: VibeTokens.glowPurple.withAlpha(50),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      title.isNotEmpty ? title[0].toUpperCase() : 'V',
                      style: VibeTokens.titleMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: VibeTokens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: VibeTokens.titleMd.copyWith(
                                color: VibeTokens.darkTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: VibeTokens.space2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x28FFFFFF),
                                borderRadius: BorderRadius.circular(VibeTokens.radiusSm),
                              ),
                              child: Text(
                                '$age',
                                style: VibeTokens.labelSm.copyWith(color: VibeTokens.darkTextSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rationale,
                          style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Affinity Score Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x337C3AED),
                      borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                      border: Border.all(color: const Color(0x66A78BFA)),
                    ),
                    child: Text(
                      '$affinity%',
                      style: VibeTokens.labelSm.copyWith(
                        color: VibeTokens.brandPurple200,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: VibeTokens.space3),
              const Divider(color: Color(0x18FFFFFF)),
              const SizedBox(height: VibeTokens.space2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: VibeTokens.glowCyan),
                      const SizedBox(width: 4),
                      Text(
                        'Safe Public Spot Nearby',
                        style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextMuted),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (onHide != null)
                        InkWell(
                          borderRadius: BorderRadius.circular(VibeTokens.radiusSm),
                          onTap: () {
                            SoundManager().playTap();
                            onHide!();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              'Pass',
                              style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextMuted),
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                        onTap: () {
                          SoundManager().playStep();
                          onOpen();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: VibeTokens.heroGradient,
                            borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                            boxShadow: [
                              BoxShadow(
                                color: VibeTokens.glowPurple.withAlpha(60),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Invite',
                                style: VibeTokens.labelSm.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward, size: 12, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
