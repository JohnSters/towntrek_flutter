import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/core.dart';

class AccessCodeEntryScreen extends StatefulWidget {
  const AccessCodeEntryScreen({super.key});

  @override
  State<AccessCodeEntryScreen> createState() => _AccessCodeEntryScreenState();
}

class _AccessCodeEntryScreenState extends State<AccessCodeEntryScreen> {
  final _codeController = TextEditingController();
  final _deviceController = TextEditingController(
    text: 'TownTrek ${Platform.operatingSystem}',
  );
  bool _submitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    final deviceName = _deviceController.text.trim();
    if (code.isEmpty || deviceName.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await serviceLocator.mobileSessionManager.signInWithCode(
        code: code,
        deviceName: deviceName,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not use that code: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Access Code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Use the mobile access code from your TownTrek profile.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Access code',
                  hintText: 'TREK-7284-KXMP',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _deviceController,
                decoration: const InputDecoration(labelText: 'Device name'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? 'Checking...' : 'Use this code'),
              ),
              const SizedBox(height: 12),
              Text(
                'Need a code? Generate one in TownTrek on the web under My Devices.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
