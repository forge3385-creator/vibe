import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../services/sound_manager.dart';
import '../glass/glass_container.dart';

class MeetupCard extends StatelessWidget {
  final String title;
  final String timeLabel;
  final String placeAddress;
  final int attendeesCount;
  final VoidCallback onOpen;

  const MeetupCard({
    super.key,
    required this.title,
    required this.timeLabel,
    required this.placeAddress,
    required this.attendeesCount,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: VibeTokens.space3),
      child: GlassContainer(
        padding: const EdgeInsets.all(VibeTokens.space4),
        borderRadius: VibeTokens.radiusLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: VibeTokens.brandPurple300),
                    const SizedBox(width: 4),
                    Text(
                      timeLabel,
                      style: VibeTokens.labelSm.copyWith(color: VibeTokens.brandPurple200),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x3310B981),
                    borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                    border: Border.all(color: const Color(0x6610B981)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 11, color: Color(0xFF6EE7B7)),
                      const SizedBox(width: 4),
                      Text(
                        'Confirmed Plan',
                        style: VibeTokens.labelSm.copyWith(
                          color: const Color(0xFF6EE7B7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: VibeTokens.space2),
            Text(
              title,
              style: VibeTokens.titleMd.copyWith(
                color: VibeTokens.darkTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 14, color: VibeTokens.darkTextMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    placeAddress,
                    style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary),
                    overflow: TextOverflow.ellipsis,
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
                    const Icon(Icons.people_alt_outlined, size: 16, color: VibeTokens.glowCyan),
                    const SizedBox(width: 6),
                    Text(
                      'You + $attendeesCount peer going',
                      style: VibeTokens.bodySm.copyWith(color: VibeTokens.darkTextSecondary),
                    ),
                  ],
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                  onTap: () {
                    SoundManager().playTap();
                    onOpen();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: VibeTokens.glassFillSubtle,
                      borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                      border: Border.all(color: const Color(0x66A78BFA)),
                    ),
                    child: Text(
                      'View Details',
                      style: VibeTokens.labelSm.copyWith(
                        color: VibeTokens.brandPurple200,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
