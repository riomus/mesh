import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ConfigEditPage<T> extends StatefulWidget {
  final String title;
  final T config;
  final Future<void> Function(T) onSave;
  final List<Widget> Function(
    BuildContext context,
    T config,
    ValueChanged<T> onChanged,
  )
  buildFields;

  const ConfigEditPage({
    super.key,
    required this.title,
    required this.config,
    required this.onSave,
    required this.buildFields,
  });

  @override
  State<ConfigEditPage<T>> createState() => _ConfigEditPageState<T>();
}

class _ConfigEditPageState<T> extends State<ConfigEditPage<T>> {
  late T _currentConfig;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.config;
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_currentConfig);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).configSaveError(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _handleSave),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: widget.buildFields(
          context,
          _currentConfig,
          (newConfig) => setState(() => _currentConfig = newConfig),
        ),
      ),
    );
  }
}
