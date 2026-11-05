import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'package:english_buddy/core/utils/ui_helpers.dart';
import '../../../data/models/word_model.dart';
import '../../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';

class AddWordDialog extends StatefulWidget {
  final int topicId;
  final String topicName;

  const AddWordDialog({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _termController = TextEditingController();
  final _ipaController = TextEditingController();
  final _meaningController = TextEditingController();
  final _exampleEnController = TextEditingController();
  final _exampleViController = TextEditingController();
  final _guideController = TextEditingController();
  String _selectedPos = 'noun';

  final List<String> _partsOfSpeech = ['noun', 'verb', 'adj', 'adv', 'phrase'];

  @override
  void dispose() {
    _termController.dispose();
    _ipaController.dispose();
    _meaningController.dispose();
    _exampleEnController.dispose();
    _exampleViController.dispose();
    _guideController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final studyProvider = Provider.of<StudyProvider>(context, listen: false);

    final newWord = WordModel(
      id: 0,
      topicId: widget.topicId,
      term: _termController.text.trim(),
      ipa: _ipaController.text.trim(),
      partOfSpeech: _selectedPos,
      meaning: _meaningController.text.trim(),
      exampleEn: _exampleEnController.text.trim(),
      exampleVi: _exampleViController.text.trim(),
      pronunciationGuide: _guideController.text.trim(),
      isFavorite: false,
      status: AppConstants.statusNew,
    );

    await studyProvider.addNewWord(newWord);

    if (mounted) {
      Navigator.of(context).pop(true);
      UiHelpers.showSnackBar(
        context,
        message: context.l10n.addWordSuccess(newWord.term),
        isSuccess: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: context.cardBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.addWordTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        Text(
                          l10n.addWordTopicTarget(widget.topicName),
                          style: const TextStyle(fontSize: 13, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: context.textSecondaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(height: 20, color: context.borderCol),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _termController,
                        style: TextStyle(color: context.textPrimaryColor),
                        decoration: _inputDecoration(l10n.addWordEnglishLabel, l10n.addWordEnglishHint),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.addWordRequiredEnglish;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _ipaController,
                              style: TextStyle(color: context.textPrimaryColor),
                              decoration: _inputDecoration(l10n.addWordIpaLabel, l10n.addWordIpaHint),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedPos,
                              dropdownColor: context.cardBg,
                              style: TextStyle(color: context.textPrimaryColor),
                              decoration: _inputDecoration(l10n.addWordPartOfSpeechLabel, ''),
                              items: _partsOfSpeech.map((pos) {
                                return DropdownMenuItem(
                                  value: pos,
                                  child: Text(pos, style: TextStyle(color: context.textPrimaryColor)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedPos = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _meaningController,
                        style: TextStyle(color: context.textPrimaryColor),
                        decoration: _inputDecoration(l10n.addWordMeaningLabel, l10n.addWordMeaningHint),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.addWordRequiredMeaning;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _exampleEnController,
                        style: TextStyle(color: context.textPrimaryColor),
                        decoration: _inputDecoration(l10n.addWordExampleEnLabel, l10n.addWordExampleEnHint),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _exampleViController,
                        style: TextStyle(color: context.textPrimaryColor),
                        decoration: _inputDecoration(l10n.addWordExampleViLabel, l10n.addWordExampleViHint),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _guideController,
                        style: TextStyle(color: context.textPrimaryColor),
                        decoration: _inputDecoration(l10n.addWordNotesLabel, l10n.addWordNotesHint),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: l10n.addWordSaveButton,
                icon: Icons.save_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: context.textSecondaryColor),
      hintText: hint,
      hintStyle: TextStyle(color: context.textMutedColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderCol),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderCol),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      filled: true,
      fillColor: context.scaffoldBg,
    );
  }
}
