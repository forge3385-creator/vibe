import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../state/onboarding_cubit.dart';
import '../../ui/cards/suggestion_card.dart';
import '../../ui/cards/meetup_card.dart';
import '../../ui/chips/energy_chip.dart';
import '../../ui/empty_state.dart';
import '../../ui/buttons/primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  EnergyType? _filterEnergy;
  final Set<String> _hiddenCandidates = {};

  void _showInviteModal(BuildContext context, String candidateName, int affinity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VibeTokens.neutral000,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VibeTokens.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(VibeTokens.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VibeTokens.neutral200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: VibeTokens.space4),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: VibeTokens.brandPurple100,
                      borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      candidateName.isNotEmpty ? candidateName[0] : 'V',
                      style: VibeTokens.titleMd.copyWith(color: VibeTokens.brandPurple800),
                    ),
                  ),
                  const SizedBox(width: VibeTokens.space3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invite $candidateName', style: VibeTokens.titleLg.copyWith(fontWeight: FontWeight.w700)),
                      Text('$affinity% Vibe Affinity · Safe Public Spot', style: VibeTokens.bodySm.copyWith(color: VibeTokens.brandPurple700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: VibeTokens.space4),
              Text(
                'Propose a meetup location (public coffee shop, park, or campus center):',
                style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
              ),
              const SizedBox(height: VibeTokens.space3),
              Container(
                padding: const EdgeInsets.all(VibeTokens.space3),
                decoration: BoxDecoration(
                  color: VibeTokens.neutral050,
                  borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
                  border: Border.all(color: VibeTokens.neutral200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.coffee, color: VibeTokens.brandPurple800),
                    const SizedBox(width: VibeTokens.space2),
                    Expanded(
                      child: Text('Blue Bottle Coffee · 450 W 15th St', style: VibeTokens.labelLg),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: VibeTokens.space6),
              PrimaryButton(
                label: 'Send Vibe Meetup Invite',
                icon: Icons.send_rounded,
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Meetup invite sent to $candidateName!'),
                      backgroundColor: VibeTokens.brandPurple800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: VibeTokens.space2),
            ],
          ),
        );
      },
    );
  }

  void _showSafetyReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: VibeTokens.neutral000,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VibeTokens.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(VibeTokens.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.shield_outlined, color: VibeTokens.semanticDanger, size: 24),
                  SizedBox(width: 8),
                  Text('Safety & Crisis Resources', style: VibeTokens.titleLg),
                ],
              ),
              const SizedBox(height: VibeTokens.space3),
              Text(
                'Vibe prioritizes genuine offline safety. If you feel unsafe or in distress:',
                style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600),
              ),
              const SizedBox(height: VibeTokens.space4),
              _buildHelpRow('988 Suicide & Crisis Lifeline', 'Call or text 988 (24/7 Free)'),
              const SizedBox(height: VibeTokens.space2),
              _buildHelpRow('Emergency Services', 'Call 911 / Local Emergency'),
              const SizedBox(height: VibeTokens.space2),
              _buildHelpRow('Block & Report User', 'Instantly hide and flag behavior to moderation'),
              const SizedBox(height: VibeTokens.space4),
              PrimaryButton(
                label: 'Close',
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpRow(String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(VibeTokens.space3),
      decoration: BoxDecoration(
        color: VibeTokens.neutral050,
        borderRadius: BorderRadius.circular(VibeTokens.radiusMd),
        border: Border.all(color: VibeTokens.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: VibeTokens.labelLg.copyWith(color: VibeTokens.neutral900, fontWeight: FontWeight.w700)),
          Text(sub, style: VibeTokens.bodySm.copyWith(color: VibeTokens.neutral600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<OnboardingCubit>();
    final state = cubit.state;

    return Scaffold(
      backgroundColor: VibeTokens.neutral000,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: VibeTokens.brandPurple800, size: 20),
            const SizedBox(width: 6),
            Text(
              'VIBE',
              style: VibeTokens.titleLg.copyWith(
                color: VibeTokens.brandPurple900,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: VibeTokens.semanticDanger),
            tooltip: 'Safety',
            onPressed: () => _showSafetyReport(context),
          ),
          IconButton(
            icon: Icon(state.isDark ? Icons.light_mode : Icons.dark_mode_outlined),
            onPressed: () => cubit.toggleTheme(),
          ),
        ],
      ),
      body: _buildCurrentTab(context, state),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (idx) => setState(() => _currentTab = idx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            activeIcon: Icon(Icons.bolt),
            label: 'My Intent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Meetups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(BuildContext context, OnboardingState state) {
    switch (_currentTab) {
      case 0:
        return _buildDiscoverTab(context, state);
      case 1:
        return _buildIntentTab(context, state);
      case 2:
        return _buildMeetupsTab(context);
      case 3:
      default:
        return _buildProfileTab(context, state);
    }
  }

  Widget _buildDiscoverTab(BuildContext context, OnboardingState state) {
    final activeIntent = state.currentIntent;
    final candidates = state.candidates.where((c) {
      if (_hiddenCandidates.contains(c.id)) return false;
      if (_filterEnergy != null && c.energy != _filterEnergy!.name) return false;
      return true;
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(VibeTokens.space4),
      children: [
        // Active Vibe Header Card
        if (activeIntent != null)
          Container(
            padding: const EdgeInsets.all(VibeTokens.space4),
            margin: const EdgeInsets.only(bottom: VibeTokens.space4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
              border: Border.all(color: VibeTokens.brandPurple300),
            ),
            child: Row(
              children: [
                Text(activeIntent.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: VibeTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Vibe: ${activeIntent.title}',
                        style: VibeTokens.titleMd.copyWith(
                          color: VibeTokens.brandPurple900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Broadcasting nearby · ${activeIntent.energy.name.toUpperCase()} Energy',
                        style: VibeTokens.bodySm.copyWith(color: VibeTokens.neutral700),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: VibeTokens.brandPurple800,
                    borderRadius: BorderRadius.circular(VibeTokens.radiusFull),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.radar, color: VibeTokens.neutral000, size: 12),
                      SizedBox(width: 4),
                      Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Energy Filter Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suggestions nearby (${candidates.length})',
              style: VibeTokens.titleMd.copyWith(fontWeight: FontWeight.w700),
            ),
            if (_filterEnergy != null)
              TextButton(
                onPressed: () => setState(() => _filterEnergy = null),
                child: const Text('Clear Filter', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: VibeTokens.space2),
        Wrap(
          spacing: 8,
          children: [
            EnergyChip(
              energy: EnergyType.low,
              isSelected: _filterEnergy == EnergyType.low,
              onSelected: (e) => setState(() => _filterEnergy = _filterEnergy == e ? null : e),
            ),
            EnergyChip(
              energy: EnergyType.medium,
              isSelected: _filterEnergy == EnergyType.medium,
              onSelected: (e) => setState(() => _filterEnergy = _filterEnergy == e ? null : e),
            ),
            EnergyChip(
              energy: EnergyType.high,
              isSelected: _filterEnergy == EnergyType.high,
              onSelected: (e) => setState(() => _filterEnergy = _filterEnergy == e ? null : e),
            ),
          ],
        ),
        const SizedBox(height: VibeTokens.space4),

        // Candidate Cards or Empty State
        if (candidates.isEmpty)
          VibeEmptyState(
            headline: 'No one matches right now',
            body: 'Try expanding your radius or selecting Medium Energy.',
            ctaLabel: 'Reset filters',
            onAction: () => setState(() {
              _filterEnergy = null;
              _hiddenCandidates.clear();
            }),
          )
        else
          ...candidates.map((c) => SuggestionCard(
                title: c.name,
                age: c.age,
                affinity: c.affinity,
                rationale: c.rationale,
                onOpen: () => _showInviteModal(context, c.name, c.affinity),
                onHide: () => setState(() => _hiddenCandidates.add(c.id)),
              )),
      ],
    );
  }

  Widget _buildIntentTab(BuildContext context, OnboardingState state) {
    final intent = state.currentIntent;

    return Padding(
      padding: const EdgeInsets.all(VibeTokens.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Current Intention', style: VibeTokens.displaySm.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: VibeTokens.space2),
          Text('You can update what you want to do whenever your vibe changes.', style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral600)),
          const SizedBox(height: VibeTokens.space5),
          if (intent != null)
            Container(
              padding: const EdgeInsets.all(VibeTokens.space4),
              decoration: BoxDecoration(
                color: VibeTokens.neutral050,
                borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
                border: Border.all(color: VibeTokens.brandPurple200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(intent.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: VibeTokens.space3),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(intent.title, style: VibeTokens.titleLg.copyWith(fontWeight: FontWeight.w700)),
                          Text('${intent.energy.name.toUpperCase()} Energy · ${intent.radiusKm} km radius', style: VibeTokens.bodySm.copyWith(color: VibeTokens.neutral600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const Spacer(),
          PrimaryButton(
            label: 'Change My Vibe',
            icon: Icons.refresh,
            onTap: () => context.go('/set-vibe'),
          ),
          const SizedBox(height: VibeTokens.space4),
        ],
      ),
    );
  }

  Widget _buildMeetupsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(VibeTokens.space4),
      children: [
        Text('Upcoming Meetups', style: VibeTokens.titleLg.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: VibeTokens.space2),
        Text('Scheduled safe meetups in verified public places.', style: VibeTokens.bodySm.copyWith(color: VibeTokens.neutral600)),
        const SizedBox(height: VibeTokens.space4),
        MeetupCard(
          title: 'Coffee & Chill @ Blue Bottle',
          timeLabel: 'Today · 18:00',
          placeAddress: '450 W 15th St, New York',
          attendeesCount: 2,
          onOpen: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening Meetup details...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileTab(BuildContext context, OnboardingState state) {
    return ListView(
      padding: const EdgeInsets.all(VibeTokens.space4),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: VibeTokens.brandPurple100,
                  shape: BoxShape.circle,
                  border: Border.all(color: VibeTokens.brandPurple300, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  state.profile.name.isNotEmpty ? state.profile.name[0] : 'V',
                  style: VibeTokens.displaySm.copyWith(color: VibeTokens.brandPurple800),
                ),
              ),
              const SizedBox(height: VibeTokens.space2),
              Text(
                state.profile.name.isNotEmpty ? state.profile.name : 'Alex Rivera',
                style: VibeTokens.titleLg.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${state.profile.city} · ${state.profile.age} y/o',
                style: VibeTokens.bodyMd.copyWith(color: VibeTokens.neutral500),
              ),
            ],
          ),
        ),
        const SizedBox(height: VibeTokens.space6),

        // Settings / Debug Card
        Container(
          padding: const EdgeInsets.all(VibeTokens.space4),
          decoration: BoxDecoration(
            color: VibeTokens.neutral050,
            borderRadius: BorderRadius.circular(VibeTokens.radiusLg),
            border: Border.all(color: VibeTokens.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FIRST-LAUNCH EXPERIENCE', style: VibeTokens.labelSm.copyWith(color: VibeTokens.neutral500)),
              const SizedBox(height: VibeTokens.space3),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restart_alt, color: VibeTokens.brandPurple800),
                title: const Text('Re-play Full Onboarding Flow'),
                subtitle: const Text('Tests splash, intro, age gate, auth, profile & matching'),
                onTap: () {
                  context.read<OnboardingCubit>().resetOnboarding();
                  context.go('/splash');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
