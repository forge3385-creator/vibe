import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/light_theme.dart';
import '../buttons/primary_button.dart';
import '../chips/energy_chip.dart';
import '../cards/suggestion_card.dart';
import '../cards/meetup_card.dart';
import '../empty_state.dart';

class VibeStorybookScreen extends StatefulWidget {
  const VibeStorybookScreen({super.key});

  @override
  State<VibeStorybookScreen> createState() => _VibeStorybookScreenState();
}

class _VibeStorybookScreenState extends State<VibeStorybookScreen> {
  bool isDark = false;
  EnergyType selectedEnergy = EnergyType.medium;

  @override
  Widget build(BuildContext context) {
    final theme = isDark ? vibeDarkTheme : vibeLightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vibe Component Storybook'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => isDark = !isDark),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(VibeTokens.space4),
          children: [
            Text('1. Primary Buttons', style: VibeTokens.titleMd),
            const SizedBox(height: VibeTokens.space2),
            PrimaryButton(label: 'Send invite', onTap: () {}),
            const SizedBox(height: VibeTokens.space2),
            PrimaryButton(label: 'Loading state', loading: true, onTap: () {}),
            const SizedBox(height: VibeTokens.space4),

            Text('2. Energy Chips', style: VibeTokens.titleMd),
            const SizedBox(height: VibeTokens.space2),
            Wrap(
              spacing: 8,
              children: [
                EnergyChip(
                  energy: EnergyType.low,
                  isSelected: selectedEnergy == EnergyType.low,
                  onSelected: (e) => setState(() => selectedEnergy = e),
                ),
                EnergyChip(
                  energy: EnergyType.medium,
                  isSelected: selectedEnergy == EnergyType.medium,
                  onSelected: (e) => setState(() => selectedEnergy = e),
                ),
                EnergyChip(
                  energy: EnergyType.high,
                  isSelected: selectedEnergy == EnergyType.high,
                  onSelected: (e) => setState(() => selectedEnergy = e),
                ),
              ],
            ),
            const SizedBox(height: VibeTokens.space4),

            Text('3. Suggestion Cards', style: VibeTokens.titleMd),
            const SizedBox(height: VibeTokens.space2),
            SuggestionCard(
              title: 'Maya',
              age: 19,
              affinity: 92,
              rationale: 'Organic chem study + coffee, 1.2 km away',
              onOpen: () {},
            ),
            const SizedBox(height: VibeTokens.space4),

            Text('4. Meetup Card', style: VibeTokens.titleMd),
            const SizedBox(height: VibeTokens.space2),
            MeetupCard(
              title: 'Coffee @ Blue Bottle',
              timeLabel: 'Today · 18:00',
              placeAddress: '450 W 15th St, New York',
              attendeesCount: 2,
              onOpen: () {},
            ),
            const SizedBox(height: VibeTokens.space4),

            Text('5. Empty State', style: VibeTokens.titleMd),
            const SizedBox(height: VibeTokens.space2),
            VibeEmptyState(
              headline: 'No one nearby matches right now',
              body: 'Try expanding your radius or trying Medium Energy.',
              ctaLabel: 'Broaden filters',
              onAction: () {},
            ),
          ],
        ),
      ),
    );
  }
}
