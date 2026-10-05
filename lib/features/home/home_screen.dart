import 'package:flutter/material.dart';

import '../../core/theme/sprout_theme.dart';
import '../../core/widgets/demo_message.dart';
import '../../core/widgets/sprout_icon.dart';
import '../session/demo_user.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.watered,
    required this.onToggleWatering,
  });

  final DemoUser user;
  final bool watered;
  final VoidCallback onToggleWatering;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey('home-scroll'),
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${user.firstName}',
              style: sproutText(28, weight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'You have ${watered ? 0 : 1} plant${watered ? 's' : ''} to water today',
              style: sproutText(
                15,
                weight: FontWeight.w500,
                color: SproutColors.muted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Today's Task",
              style: sproutText(18, weight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _WateringTask(watered: watered, onToggle: onToggleWatering),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Plants',
                    style: sproutText(18, weight: FontWeight.w700),
                  ),
                  _AddPlantButton(
                    onPressed: () => showDemoMessage(context, laterLabMessage),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (var row = 0; row < 2; row++) ...[
              if (row != 0) const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _PlantCard(plant: _plants[row * 2])),
                  const SizedBox(width: 16),
                  Expanded(child: _PlantCard(plant: _plants[row * 2 + 1])),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _WateringTask extends StatelessWidget {
  const _WateringTask({required this.watered, required this.onToggle});

  final bool watered;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: SproutColors.softGreen,
      border: Border.all(color: SproutColors.border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/task-monstera.png',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monstera Deliciosa',
                style: sproutText(16, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const SproutIcon('droplet-task'),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      watered ? 'Watered today' : 'Needs watering today',
                      style: sproutText(
                        13,
                        weight: FontWeight.w500,
                        color: SproutColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Semantics(
          label: 'Water Monstera Deliciosa',
          checked: watered,
          enabled: true,
          onTap: onToggle,
          excludeSemantics: true,
          child: IconButton(
            key: const ValueKey('watering-toggle'),
            tooltip: watered ? 'Mark as not watered' : 'Mark as watered',
            onPressed: onToggle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: SproutColors.green, width: 2),
              ),
              child: watered ? const SproutIcon('check') : null,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AddPlantButton extends StatelessWidget {
  const _AddPlantButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Add plant',
    child: GestureDetector(
      key: const ValueKey('add-plant'),
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 6,
              top: 6,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x262D6A4F),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: -6,
              top: -2,
              child: SproutIcon('add-background'),
            ),
            Positioned(
              left: 6,
              top: 5,
              width: 32,
              height: 32,
              child: Center(
                child: Text(
                  '+',
                  style: sproutText(
                    20,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Plant {
  const _Plant(this.name, this.species, this.days, this.asset);

  final String name;
  final String species;
  final int days;
  final String asset;
}

const _plants = [
  _Plant('Monstera', 'Monstera Deliciosa', 3, 'monstera'),
  _Plant('Snake Plant', 'Sansevieria', 10, 'snake-plant'),
  _Plant('Fiddle Leaf', 'Ficus Lyrata', 7, 'fiddle-leaf'),
  _Plant('Pothos', 'Epipremnum', 5, 'pothos'),
];

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant});

  final _Plant plant;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: SproutColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: ValueKey('plant-${plant.asset}'),
      onTap: () => showDemoMessage(context, laterLabMessage),
      child: Semantics(
        button: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/${plant.asset}.png',
              width: double.infinity,
              height: 130,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sproutText(15, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plant.species,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sproutText(12, color: SproutColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SproutIcon('droplet-card'),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Every ${plant.days} days',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sproutText(
                            12,
                            weight: FontWeight.w600,
                            color: SproutColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
