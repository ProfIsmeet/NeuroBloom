import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/security/parent_pin_providers.dart';
import '../../../core/theme/app_dimens.dart';

const int _pinLength = 4;

/// "Parent Area" gate: shows a PIN-creation flow on first use, or a
/// verification flow afterwards. Any child can reach this screen (it's
/// just a PIN pad), but the dashboard itself is only reachable once
/// [parentUnlockedProvider] is set true here — see AppRouter's redirect.
///
/// Uses an explicit on-screen numeric keypad rather than the OS soft
/// keyboard: an earlier hidden-TextField implementation could get stuck
/// after a wrong PIN, because a torn-down platform text-input connection
/// doesn't reliably reopen just by re-requesting Flutter-side focus. A
/// real keypad has no platform input connection to lose, and matches
/// most banking/parental-lock PIN UIs anyway.
class ParentPinScreen extends ConsumerStatefulWidget {
  const ParentPinScreen({super.key});

  @override
  ConsumerState<ParentPinScreen> createState() => _ParentPinScreenState();
}

enum _Stage { loading, createStep1, createStep2, verify }

class _ParentPinScreenState extends ConsumerState<ParentPinScreen> {
  _Stage _stage = _Stage.loading;
  String _entered = '';
  String _firstPin = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final hasPin = await ref.read(parentAuthControllerProvider).hasPin();
    if (!mounted) return;
    setState(() => _stage = hasPin ? _Stage.verify : _Stage.createStep1);
  }

  void _onDigit(String digit) {
    if (_entered.length >= _pinLength) return;
    setState(() {
      _entered += digit;
      _error = null;
    });
    if (_entered.length == _pinLength) {
      _submit(_entered);
    }
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _submit(String pin) async {
    switch (_stage) {
      case _Stage.createStep1:
        setState(() {
          _firstPin = pin;
          _stage = _Stage.createStep2;
          _entered = '';
        });
      case _Stage.createStep2:
        if (pin == _firstPin) {
          await ref.read(parentAuthControllerProvider).createPin(pin);
          if (!mounted) return;
          context.go('/parent/dashboard');
        } else {
          setState(() {
            _error = 'PIN\'ler eşleşmedi, tekrar dene.';
            _stage = _Stage.createStep1;
            _firstPin = '';
            _entered = '';
          });
        }
      case _Stage.verify:
        final correct = await ref
            .read(parentAuthControllerProvider)
            .attemptUnlock(pin);
        if (!mounted) return;
        if (correct) {
          context.go('/parent/dashboard');
        } else {
          setState(() {
            _error = 'Yanlış PIN.';
            _entered = '';
          });
        }
      case _Stage.loading:
        break;
    }
  }

  String get _prompt => switch (_stage) {
    _Stage.loading => '',
    _Stage.createStep1 => 'Bir PIN oluştur',
    _Stage.createStep2 => 'PIN\'i tekrar gir',
    _Stage.verify => 'PIN Gir',
  };

  @override
  Widget build(BuildContext context) {
    if (_stage == _Stage.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ebeveyn Alanı')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.spaceLg),
          child: Column(
            children: [
              const SizedBox(height: AppDimens.spaceLg),
              Icon(
                Icons.lock_rounded,
                size: AppDimens.iconSizeLg,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppDimens.spaceLg),
              Text(_prompt, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimens.spaceLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _entered.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      filled ? Icons.circle : Icons.circle_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }),
              ),
              SizedBox(
                height: AppDimens.spaceXl,
                child: _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: AppDimens.spaceLg),
              _Keypad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: AppDimens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [for (final digit in row) _KeypadButton(label: digit, onTap: () => onDigit(digit))],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceSm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72, height: 72),
              _KeypadButton(label: '0', onTap: () => onDigit('0')),
              _KeypadButton(
                icon: Icons.backspace_outlined,
                onTap: onBackspace,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: label != null
                ? Text(label!, style: Theme.of(context).textTheme.headlineMedium)
                : Icon(icon, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
