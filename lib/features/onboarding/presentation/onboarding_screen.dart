import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../application/profile_providers.dart';
import 'widgets/avatar_painter.dart';

const List<String> _genderOptions = ['Kız', 'Erkek', 'Belirtmek istemiyorum'];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _step = 0;
  int _age = 6;
  String _gender = _genderOptions.first;
  int _avatarId = 0;
  bool _isSaving = false;

  static const int _stepCount = 5;

  bool get _canGoNext {
    switch (_step) {
      case 0:
        return true;
      case 1:
        return _nameController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _createProfile() async {
    setState(() => _isSaving = true);
    await ref
        .read(profileControllerProvider.notifier)
        .createProfile(
          name: _nameController.text.trim(),
          age: _age,
          gender: _gender,
          avatarId: _avatarId,
        );
    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _stepCount),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _GreetingStep(onNext: () => _goToStep(1)),
                  _NameStep(controller: _nameController, onChanged: () => setState(() {})),
                  _AgeStep(
                    age: _age,
                    onChanged: (value) => setState(() => _age = value),
                  ),
                  _GenderStep(
                    selected: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                  _AvatarStep(
                    selectedAvatarId: _avatarId,
                    onChanged: (value) => setState(() => _avatarId = value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.spaceLg),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _goToStep(_step - 1),
                        child: const Text('Geri'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: AppDimens.spaceMd),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: !_canGoNext || _isSaving
                          ? null
                          : () {
                              if (_step == _stepCount - 1) {
                                _createProfile();
                              } else {
                                _goToStep(_step + 1);
                              }
                            },
                      child: Text(
                        _step == _stepCount - 1 ? 'Profili Oluştur' : 'Devam',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingStep extends StatelessWidget {
  const _GreetingStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppDimens.spaceLg),
            Text(
              'Merhaba! Ben NeuroBot 🌱',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.spaceSm),
            Text(
              'Seninle birlikte konuşma pratiği yapmak için buradayım. '
              'Önce seni biraz tanıyalım.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Adın ne?',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.spaceLg),
            TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'İsmini yaz'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeStep extends StatelessWidget {
  const _AgeStep({required this.age, required this.onChanged});

  final int age;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kaç yaşındasın?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimens.spaceLg),
            Text('$age', style: Theme.of(context).textTheme.displayLarge),
            Slider(
              value: age.toDouble(),
              min: 3,
              max: 13,
              divisions: 10,
              label: '$age',
              onChanged: (value) => onChanged(value.round()),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderStep extends StatelessWidget {
  const _GenderStep({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cinsiyetin nedir?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimens.spaceLg),
            Wrap(
              spacing: AppDimens.spaceSm,
              children: _genderOptions.map((option) {
                return ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => onChanged(option),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStep extends StatelessWidget {
  const _AvatarStep({
    required this.selectedAvatarId,
    required this.onChanged,
  });

  final int selectedAvatarId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.spaceXl),
      child: Column(
        children: [
          Text(
            'Avatarını seç',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimens.spaceLg),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: AppDimens.spaceMd,
              crossAxisSpacing: AppDimens.spaceMd,
              children: List.generate(8, (index) {
                final isSelected = index == selectedAvatarId;
                return GestureDetector(
                  onTap: () => onChanged(index),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: AvatarWidget(avatarId: index),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
