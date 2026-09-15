import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

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
    final int filledDots = (affinity / 10).clamp(0, 10).round();

    return Semantics(
      label: '$title, $age years old, $affinity percent vibe affinity',
      description: rationale,
      button: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: VibeTokens.space3),
        decoration: BoxDecoration(
          color: VibeTokens.neutral050,
          borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
          border: Border.all(color: VibeTokens.neutral200, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A00102D),
              blurRadius: 8,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(VibeTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar (48x48) initials
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: VibeTokens.brandPurple100,
                    borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    title.isNotEmpty ? title[0].toUpperCase() : 'V',
                    style: VibeTokens.titleMd.copyWith(color: VibeTokens.brandPurple800),
                  ),
                ),
                const SizedBox(width: VibeTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: VibeTokens.titleMd.copyWith(color: VibeTokens.neutral900)),
                          const SizedBox(width: VibeTokens.space2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: VibeTokens.neutral100,
                              borderRadius: BorderRadius.circular(VibeTokens.radiusSm),
                            ),
                            child: Text('$age', style: VibeTokens.labelSm.copyWith(color: VibeTokens.neutral600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rationale,
                        style: VibeTokens.bodySm.copyWith(color: VibeTokens.neutral600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Affinity meter: 10 dots
                Row(
                  children: List.generate(5, (index) {
                    final bool isLit = (index * 2) < filledDots;
                    return Container(
                      margin: const EdgeInsets.only(left: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isLit ? VibeTokens.brandPurple500 : VibeTokens.neutral300,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: VibeTokens.space3),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onHide != null)
                  TextButton(
                    onPressed: onHide,
                    child: Text('Hide', style: VibeTokens.labelSm.copyWith(color: VibeTokens.neutral500)),
                  ),
                const SizedBox(width: VibeTokens.space2),
                ElevatedButton(
                  onPressed: onOpen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VibeTokens.brandPurple800,
                    foregroundColor: VibeTokens.neutral000,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(VibeTokens.radiusMd)),
                    padding: const EdgeInsets.symmetric(horizontal: VibeTokens.space4, vertical: VibeTokens.space2),
                  ),
                  child: const Text('Open'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
