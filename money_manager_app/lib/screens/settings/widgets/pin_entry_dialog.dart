import 'package:flutter/material.dart';

class PinEntryDialog extends StatefulWidget {
  final bool isFirstTime;

  const PinEntryDialog({super.key, this.isFirstTime = false});

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  String? _error;
  String? _confirmedPin;

  bool get _isFirstTime => widget.isFirstTime;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        _confirmedPin != null
            ? 'Confirm PIN'
            : _isFirstTime
                ? 'Set PIN'
                : 'Enter PIN',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _confirmedPin != null
                ? 'Re-enter your 4-digit PIN'
                : _isFirstTime
                    ? 'Set a 4-digit PIN for sync'
                    : 'Enter your 4-digit PIN to enable sync',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) {
              return SizedBox(
                width: 48,
                height: 56,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  textAlign: TextAlign.center,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 3) {
                      _focusNodes[i + 1].requestFocus();
                    }
                    setState(() {
                      _error = null;
                    });
                  },
                ),
              );
            }),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade400, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_confirmedPin != null ? 'Confirm' : 'Continue'),
        ),
      ],
    );
  }

  void _submit() {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length != 4) {
      setState(() => _error = 'Enter all 4 digits');
      return;
    }

    if (_isFirstTime && _confirmedPin == null) {
      setState(() {
        _confirmedPin = pin;
        _error = null;
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      });
      return;
    }

    if (_isFirstTime && _confirmedPin != null) {
      if (pin != _confirmedPin) {
        setState(() {
          _error = 'PINs do not match';
          for (final c in _controllers) {
            c.clear();
          }
          _focusNodes[0].requestFocus();
        });
        return;
      }
    }

    Navigator.pop(context, pin);
  }
}
