import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Dialog for editing device owner information (long name and short name).
class OwnerEditDialog extends StatefulWidget {
  final String? currentLongName;
  final String? currentShortName;
  final Future<void> Function({String? longName, String? shortName}) onSave;

  const OwnerEditDialog({
    super.key,
    this.currentLongName,
    this.currentShortName,
    required this.onSave,
  });

  @override
  State<OwnerEditDialog> createState() => _OwnerEditDialogState();
}

class _OwnerEditDialogState extends State<OwnerEditDialog> {
  late final TextEditingController _longNameController;
  late final TextEditingController _shortNameController;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _longNameController = TextEditingController(text: widget.currentLongName);
    _shortNameController = TextEditingController(text: widget.currentShortName);
  }

  @override
  void dispose() {
    _longNameController.dispose();
    _shortNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    final longName = _longNameController.text.trim();
    final shortName = _shortNameController.text.trim();

    // Validation
    if (longName.isEmpty && shortName.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).ownerEditAtLeastOneName;
        _isSaving = false;
      });
      return;
    }

    try {
      await widget.onSave(
        longName: longName.isNotEmpty ? longName : null,
        shortName: shortName.isNotEmpty ? shortName : null,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).ownerEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _longNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).ownerLongName,
                hintText: AppLocalizations.of(context).ownerLongNameHint,
                helperText: AppLocalizations.of(context).ownerLongNameHelper,
              ),
              enabled: !_isSaving,
              maxLength: 40,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _shortNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).ownerShortName,
                hintText: AppLocalizations.of(context).ownerShortNameHint,
                helperText: AppLocalizations.of(context).ownerShortNameHelper,
              ),
              enabled: !_isSaving,
              maxLength: 4,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppLocalizations.of(context).save),
        ),
      ],
    );
  }
}
