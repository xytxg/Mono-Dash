import 'package:flutter/cupertino.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/components/file_browser_picker_sheet.dart';

class RuntimeSectionCard extends StatelessWidget {
  const RuntimeSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    required this.themeColor,
    this.onAdd,
    this.description,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color themeColor;
  final VoidCallback? onAdd;
  final Object? description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: themeColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label(context),
                  ),
                ),
              ),
              if (onAdd != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(28, 28),
                  onPressed: onAdd,
                  child: Icon(TablerIcons.plus, size: 20, color: themeColor),
                ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            if (description is String)
              Text(
                description! as String,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tertiaryLabel(
                    context,
                  ).withValues(alpha: 0.8),
                ),
              )
            else
              description! as Widget,
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class RuntimeInputRow extends StatelessWidget {
  const RuntimeInputRow({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.keyboardType,
    this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuntimeFieldLabel(label),
        const SizedBox(height: 7),
        SizedBox(
          height: 40,
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            keyboardType: keyboardType,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: onChanged,
            enabled: enabled,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.tertiaryBackground(
                      context,
                    ).withValues(alpha: 0.58)
                  : AppColors.tertiaryBackground(
                      context,
                    ).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            style: TextStyle(
              fontSize: 14,
              color: enabled
                  ? AppColors.label(context)
                  : AppColors.tertiaryLabel(context),
            ),
            placeholderStyle: TextStyle(
              fontSize: 14,
              color: AppColors.tertiaryLabel(context),
            ),
          ),
        ),
      ],
    );
  }
}

class RuntimeFieldLabel extends StatelessWidget {
  const RuntimeFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.secondaryLabel(context),
      ),
    );
  }
}

class RuntimeStaticRow extends StatelessWidget {
  const RuntimeStaticRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuntimeFieldLabel(label),
        const SizedBox(height: 7),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.tertiaryBackground(
              context,
            ).withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryLabel(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RuntimeCodeDirRow extends StatelessWidget {
  const RuntimeCodeDirRow({
    super.key,
    required this.controller,
    required this.isEdit,
    required this.onSelected,
    this.onEditingComplete,
  });

  final TextEditingController controller;
  final bool isEdit;
  final ValueChanged<String> onSelected;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RuntimeFieldLabel(context.l10n.runtime_codeDirectory),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: CupertinoTextField(
                  controller: controller,
                  placeholder: '/path/to/project',
                  autocorrect: false,
                  enableSuggestions: false,
                  enabled: !isEdit,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isEdit
                        ? AppColors.tertiaryBackground(
                            context,
                          ).withValues(alpha: 0.25)
                        : AppColors.tertiaryBackground(
                            context,
                          ).withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isEdit
                        ? AppColors.tertiaryLabel(context)
                        : AppColors.label(context),
                  ),
                  placeholderStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.tertiaryLabel(context),
                  ),
                  onEditingComplete: onEditingComplete,
                ),
              ),
            ),
            if (!isEdit) ...[
              const SizedBox(width: 8),
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
                color: AppColors.tertiaryBackground(
                  context,
                ).withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(10),
                onPressed: () async {
                  final result = await FileBrowserPickerSheet.show(
                    context,
                    initialPath: controller.text.trim().isEmpty
                        ? '/'
                        : controller.text.trim(),
                    title: context.l10n.runtime_chooseCodeDirectory,
                  );
                  if (result != null) onSelected(result.path);
                },
                child: Icon(
                  TablerIcons.folder_search,
                  size: 18,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class RuntimePortMappingsSection extends StatelessWidget {
  const RuntimePortMappingsSection({
    super.key,
    required this.ports,
    required this.onTogglePublic,
    required this.onRemove,
    required this.themeColor,
  });

  final List<RuntimePortMapping> ports;
  final ValueChanged<int> onTogglePublic;
  final ValueChanged<int> onRemove;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    if (ports.isEmpty) {
      return RuntimeEmptyPlaceholder(context.l10n.runtime_noPortMappings);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < ports.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RuntimeSmallField(
                  controller: ports[i].hostPort,
                  placeholder: context.l10n.runtime_hostPort,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  TablerIcons.arrow_right,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Expanded(
                child: RuntimeSmallField(
                  controller: ports[i].containerPort,
                  placeholder: context.l10n.runtime_containerPort,
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(36, 36),
                onPressed: () => onTogglePublic(i),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ports[i].isPublic
                        ? themeColor.withValues(alpha: 0.12)
                        : AppColors.secondaryBackground(
                            context,
                          ).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    ports[i].isPublic ? TablerIcons.world : TablerIcons.lock,
                    size: 18,
                    color: ports[i].isPublic
                        ? themeColor
                        : AppColors.tertiaryLabel(context),
                  ),
                ),
              ),
              RuntimeRemoveButton(onPressed: () => onRemove(i)),
            ],
          ),
        ],
      ],
    );
  }
}

class RuntimeEnvironmentSection extends StatelessWidget {
  const RuntimeEnvironmentSection({
    super.key,
    required this.environments,
    required this.onRemove,
  });

  final List<RuntimeEnvMapping> environments;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (environments.isEmpty) {
      return RuntimeEmptyPlaceholder(
        context.l10n.runtime_noEnvironmentVariables,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < environments.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RuntimeSmallField(
                  controller: environments[i].key,
                  placeholder: context.l10n.runtime_envKey,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  TablerIcons.equal,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Expanded(
                child: RuntimeSmallField(
                  controller: environments[i].value,
                  placeholder: context.l10n.runtime_envValue,
                ),
              ),
              RuntimeRemoveButton(onPressed: () => onRemove(i)),
            ],
          ),
        ],
      ],
    );
  }
}

class RuntimeVolumesSection extends StatelessWidget {
  const RuntimeVolumesSection({
    super.key,
    required this.volumes,
    required this.onSourceSelected,
    required this.onRemove,
  });

  final List<RuntimeVolumeMapping> volumes;
  final void Function(int index, String path) onSourceSelected;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (volumes.isEmpty) {
      return RuntimeEmptyPlaceholder(context.l10n.runtime_noMounts);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < volumes.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RuntimeSmallField(
                  controller: volumes[i].source,
                  placeholder: context.l10n.runtime_hostPath,
                  onBrowse: () async {
                    final result = await FileBrowserPickerSheet.show(
                      context,
                      initialPath: volumes[i].source.text.trim().isEmpty
                          ? '/'
                          : volumes[i].source.text.trim(),
                      title: context.l10n.runtime_chooseMountPath,
                      selectionMode:
                          FilePickerSelectionMode.filesAndDirectories,
                    );
                    if (result != null) onSourceSelected(i, result.path);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  TablerIcons.arrow_right,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Expanded(
                child: RuntimeSmallField(
                  controller: volumes[i].target,
                  placeholder: context.l10n.runtime_containerPath,
                ),
              ),
              RuntimeRemoveButton(onPressed: () => onRemove(i)),
            ],
          ),
        ],
      ],
    );
  }
}

class RuntimeExtraHostsSection extends StatelessWidget {
  const RuntimeExtraHostsSection({
    super.key,
    required this.extraHosts,
    required this.onRemove,
  });

  final List<RuntimeHostMapping> extraHosts;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (extraHosts.isEmpty) {
      return RuntimeEmptyPlaceholder(context.l10n.runtime_noHostMappings);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < extraHosts.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RuntimeSmallField(
                  controller: extraHosts[i].hostname,
                  placeholder: context.l10n.runtime_hostname,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  TablerIcons.arrow_right,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Expanded(
                child: RuntimeSmallField(
                  controller: extraHosts[i].ip,
                  placeholder: context.l10n.runtime_ipAddress,
                ),
              ),
              RuntimeRemoveButton(onPressed: () => onRemove(i)),
            ],
          ),
        ],
      ],
    );
  }
}

class RuntimeSmallField extends StatelessWidget {
  const RuntimeSmallField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.onBrowse,
  });

  final TextEditingController controller;
  final String placeholder;
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        autocorrect: false,
        enableSuggestions: false,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        suffix: onBrowse == null
            ? null
            : CupertinoButton(
                padding: const EdgeInsets.only(right: 6),
                minimumSize: const Size(28, 28),
                onPressed: onBrowse,
                child: Icon(
                  TablerIcons.folder_search,
                  size: 16,
                  color: AppColors.secondaryLabel(context),
                ),
              ),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        style: const TextStyle(fontSize: 13),
        placeholderStyle: TextStyle(
          fontSize: 13,
          color: AppColors.tertiaryLabel(context),
        ),
      ),
    );
  }
}

class RuntimeRemoveButton extends StatelessWidget {
  const RuntimeRemoveButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.only(left: 8),
      minimumSize: const Size(28, 28),
      onPressed: onPressed,
      child: const Icon(
        TablerIcons.trash,
        size: 16,
        color: CupertinoColors.destructiveRed,
      ),
    );
  }
}

class RuntimeEmptyPlaceholder extends StatelessWidget {
  const RuntimeEmptyPlaceholder(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground(context).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.separator(context).withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.tertiaryLabel(context).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class RuntimePortMapping {
  RuntimePortMapping({
    TextEditingController? hostPort,
    TextEditingController? containerPort,
    this.isPublic = false,
  }) : hostPort = hostPort ?? TextEditingController(),
       containerPort = containerPort ?? TextEditingController();

  final TextEditingController hostPort;
  final TextEditingController containerPort;
  bool isPublic;

  void dispose() {
    hostPort.dispose();
    containerPort.dispose();
  }
}

class RuntimeEnvMapping {
  RuntimeEnvMapping({TextEditingController? key, TextEditingController? value})
    : key = key ?? TextEditingController(),
      value = value ?? TextEditingController();

  final TextEditingController key;
  final TextEditingController value;

  void dispose() {
    key.dispose();
    value.dispose();
  }
}

class RuntimeVolumeMapping {
  RuntimeVolumeMapping({
    TextEditingController? source,
    TextEditingController? target,
  }) : source = source ?? TextEditingController(),
       target = target ?? TextEditingController();

  final TextEditingController source;
  final TextEditingController target;

  void dispose() {
    source.dispose();
    target.dispose();
  }
}

class RuntimeHostMapping {
  RuntimeHostMapping({
    TextEditingController? hostname,
    TextEditingController? ip,
  }) : hostname = hostname ?? TextEditingController(),
       ip = ip ?? TextEditingController();

  final TextEditingController hostname;
  final TextEditingController ip;

  void dispose() {
    hostname.dispose();
    ip.dispose();
  }
}
