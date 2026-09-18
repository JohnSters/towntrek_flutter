import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../member_hub/connect_device_sheet.dart';

class TownFlyerAuthScreen extends StatefulWidget {
  const TownFlyerAuthScreen({super.key, this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  State<TownFlyerAuthScreen> createState() => _TownFlyerAuthScreenState();
}

class _TownFlyerAuthScreenState extends State<TownFlyerAuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  bool _acceptTerms = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await serviceLocator.mobileSessionManager.registerMember(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        acceptTerms: _acceptTerms,
        deviceName: 'TownTrek ${Platform.operatingSystem}',
      );
      widget.onAuthenticated?.call();
    } catch (e) {
      if (mounted) {
        setState(() => _error = resolveUserFacingApiError(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitLogin() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await serviceLocator.mobileSessionManager.loginWithPassword(
        email: _email.text.trim(),
        password: _password.text,
        deviceName: 'TownTrek ${Platform.operatingSystem}',
      );
      widget.onAuthenticated?.call();
    } catch (e) {
      if (mounted) {
        setState(() => _error = resolveUserFacingApiError(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(TownFlyerConstants.authTitle),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: TownFlyerConstants.registerTab),
            Tab(text: TownFlyerConstants.loginTab),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                TownFlyerConstants.authBody,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _AuthForm(
                    isRegister: true,
                    name: _name,
                    email: _email,
                    password: _password,
                    phone: _phone,
                    acceptTerms: _acceptTerms,
                    onTermsChanged: (value) =>
                        setState(() => _acceptTerms = value ?? false),
                    busy: _busy,
                    error: _error,
                    onSubmit: _submitRegister,
                  ),
                  _AuthForm(
                    isRegister: false,
                    name: _name,
                    email: _email,
                    password: _password,
                    phone: _phone,
                    acceptTerms: _acceptTerms,
                    onTermsChanged: (_) {},
                    busy: _busy,
                    error: _error,
                    onSubmit: _submitLogin,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: TextButton(
                onPressed: _busy
                    ? null
                    : () async {
                        final ok = await showConnectDeviceSheet(context);
                        if (ok) widget.onAuthenticated?.call();
                      },
                child: const Text(TownFlyerConstants.trekFallback),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.isRegister,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.acceptTerms,
    required this.onTermsChanged,
    required this.busy,
    required this.error,
    required this.onSubmit,
  });

  final bool isRegister;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController phone;
  final bool acceptTerms;
  final ValueChanged<bool?> onTermsChanged;
  final bool busy;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (isRegister) ...[
          TextField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: TownFlyerConstants.fullNameLabel,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: TownFlyerConstants.emailLabel,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: TownFlyerConstants.passwordLabel,
            border: OutlineInputBorder(),
          ),
        ),
        if (isRegister) ...[
          const SizedBox(height: 12),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: TownFlyerConstants.phoneLabel,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: acceptTerms,
            onChanged: busy ? null : onTermsChanged,
            contentPadding: EdgeInsets.zero,
            title: const Text(TownFlyerConstants.termsLabel),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: busy ? null : onSubmit,
          child: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  isRegister
                      ? TownFlyerConstants.registerSubmit
                      : TownFlyerConstants.loginSubmit,
                ),
        ),
      ],
    );
  }
}
