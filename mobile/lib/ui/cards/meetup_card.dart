import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

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
      decoration: BoxDecoration(
        color: VibeTokens.neutral000,
        borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
        border: const Border(
          top: BorderSide(color: VibeTokens.brandPurple200, width: 2),
          left: BorderSide(color: VibeTokens.neutral200, width: 1),
          right: BorderSide(color: VibeTokens.neutral200, width: 1),
          bottom: BorderSide(color: VibeTokens.neutral200, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(VibeTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeLabel,
                style: VibeTokens.labelSm.copyWith(color: VibeTokens.brandPurple700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: VibeTokens.brandPurple050,
                  borderRadius: BorderRadius.circular(VibeTokens.radiusSm),
                ),
                child: Text(
                  'Confirmed',
                  style: VibeTokens.labelSm.copyWith(color: VibeTokens.brandPurple800),
                ),
              ),
            ],
          ),
          const SizedBox(height: VibeTokens.space1),
          Text(title, style: VibeTokens.titleMd.copyWith(color: VibeTokens.neutral900)),
          const SizedBox(height: 2),
          Text(placeAddress, style: VibeTokens.bodySm.copyWith(color: VibeTokens.neutral500)),
          const SizedBox(height: VibeTokens.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You + $attendeesCount going',
                style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
              ),
              ElevatedButton(
                onPressed: onOpen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VibeTokens.brandPurple800,
                  foregroundColor: VibeTokens.neutral000,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(VibeTokens.radiusMd)),
                ),
                child: const Text('Open'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
