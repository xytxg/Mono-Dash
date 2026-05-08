part of '../website_rewrite_sheet.dart';

class _RewriteForm extends StatelessWidget {
  const _RewriteForm({
    required this.websiteId,
    required this.codeController,
    required this.selectedName,
    required this.customTemplates,
    required this.builtinTemplates,
    required this.onTemplateChanged,
    required this.onSave,
    required this.onSaveAs,
    required this.onDelete,
    required this.saving,
  });

  final int websiteId;
  final CodeLineEditingController codeController;
  final String selectedName;
  final List<String> customTemplates;
  final List<String> builtinTemplates;
  final ValueChanged<String> onTemplateChanged;
  final VoidCallback onSave;
  final VoidCallback onSaveAs;
  final VoidCallback onDelete;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      AppPickerOption(value: 'current', label: l10n.websites_currentTemplate),
      ...customTemplates.map(
        (e) => AppPickerOption(
          value: e,
          label: l10n.websites_customTemplateName(e),
        ),
      ),
      ...builtinTemplates.map((e) => AppPickerOption(value: e, label: e)),
    ];

    final isCustom = customTemplates.contains(selectedName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.websites_selectTemplate,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
              const SizedBox(height: 10),
              AppInlinePicker<String>(
                value: selectedName,
                options: options,
                onChanged: onTemplateChanged,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.websites_ruleContent,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 360,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.separator(context).withValues(alpha: 0.1),
                  ),
                ),
                child: AppCodeEditor(
                  controller: codeController,
                  language: 'nginx',
                  hint: l10n.websites_rewriteRulesHint,
                ),
              ),
              const SizedBox(height: 24),
              // Bottom action bar.
              Row(
                children: [
                  if (isCustom) ...[
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(40, 40),
                      color: CupertinoColors.systemRed
                          .resolveFrom(context)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      onPressed: saving ? null : onDelete,
                      child: Icon(
                        TablerIcons.trash,
                        size: 18,
                        color: CupertinoColors.systemRed.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 40),
                      color: AppColors.tertiaryBackground(
                        context,
                      ).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      onPressed: saving ? null : onSaveAs,
                      child: Text(
                        l10n.websites_saveAsTemplate,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.label(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 40),
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(10),
                      onPressed: saving ? null : onSave,
                      child: saving
                          ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white,
                            )
                          : Text(
                              l10n.websites_saveAndReload,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              // Bottom safe area.
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
            ],
          ),
        ),
      ],
    );
  }
}
