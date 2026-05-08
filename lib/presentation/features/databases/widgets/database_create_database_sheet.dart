import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/app_toast.dart';
import '../../../common/components/action_sheet_launcher.dart';
import '../../../common/components/action_sheet_scaffold.dart';
import '../../../common/components/app_picker.dart';
import '../../../common/components/cupertino_grouped_form.dart';

/// 显示创建数据库 Sheet。
Future<void> showCreateDatabaseSheet(
  BuildContext context, {
  required String dbType,
  required String dbName,
  required String dbFrom,
  VoidCallback? onSuccess,
}) async {
  await showActionSheet<void>(
    context: context,
    builder: (_) => _CreateDatabaseSheet(
      dbType: dbType,
      dbName: dbName,
      dbFrom: dbFrom,
      onSuccess: onSuccess,
    ),
  );
}

class _CreateDatabaseSheet extends ConsumerStatefulWidget {
  const _CreateDatabaseSheet({
    required this.dbType,
    required this.dbName,
    required this.dbFrom,
    this.onSuccess,
  });

  final String dbType;
  final String dbName;
  final String dbFrom;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<_CreateDatabaseSheet> createState() =>
      _CreateDatabaseSheetState();
}

class _CreateDatabaseSheetState extends ConsumerState<_CreateDatabaseSheet> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ipController = TextEditingController();
  final _descriptionController = TextEditingController();

  // 格式/排序规则选项
  List<FormatCollationOption> _formatOptions = [];
  String _selectedFormat = 'utf8mb4';
  List<String> _collations = [];
  String _selectedCollation = '';

  // 权限
  String _permission = '%'; // '%' | 'localhost' | 'ip'

  // 状态
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _optionsLoading = true;
  bool _pickerExpanded = false;

  // 用户名同步追踪
  String _lastSyncedName = '';

  @override
  void initState() {
    super.initState();
    _passwordController.text = _generatePassword();
    _loadFormatOptions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _ipController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── 数据加载 ────────────────────────────────────────────────

  Future<void> _loadFormatOptions() async {
    try {
      final repo = await ref.read(databaseRepositoryProvider.future);
      final options = await repo.getFormatOptions(widget.dbName);
      if (!mounted) return;

      // 如果 API 返回空，使用默认值
      final effective = options.isEmpty
          ? const [
              FormatCollationOption(format: 'utf8mb4'),
              FormatCollationOption(format: 'utf8mb3'),
              FormatCollationOption(format: 'gbk'),
              FormatCollationOption(format: 'big5'),
            ]
          : options;

      setState(() {
        _formatOptions = effective;
        // 默认选择 utf8mb4（如果存在）
        _selectedFormat = effective.any((o) => o.format == 'utf8mb4')
            ? 'utf8mb4'
            : effective.first.format;
        _updateCollations();
        _optionsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _formatOptions = const [
          FormatCollationOption(format: 'utf8mb4'),
          FormatCollationOption(format: 'utf8mb3'),
          FormatCollationOption(format: 'gbk'),
          FormatCollationOption(format: 'big5'),
        ];
        _selectedFormat = 'utf8mb4';
        _updateCollations();
        _optionsLoading = false;
      });
    }
  }

  void _updateCollations() {
    final option = _formatOptions
        .where((o) => o.format == _selectedFormat)
        .firstOrNull;
    _collations = option?.collations ?? const [];
    // 排序规则默认留空
    _selectedCollation = '';
  }

  // ── 工具方法 ────────────────────────────────────────────────

  String _generatePassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789-_';
    final random = Random.secure();
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void _syncUsername(String name) {
    // 仅当用户名还等于上一次同步的名字（或初始空）时才同步
    if (_usernameController.text == _lastSyncedName ||
        _usernameController.text.isEmpty) {
      _usernameController.text = name;
      _lastSyncedName = name;
    }
  }

  // ── 校验 ────────────────────────────────────────────────────

  String? _validate() {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final l10n = context.l10n;
    if (name.isEmpty) return l10n.databases_enterDatabaseName;
    if (name.contains(' ')) return l10n.databases_databaseNameNoSpaces;
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) {
      return l10n.databases_databaseNameAllowedChars;
    }

    if (username.isEmpty) return l10n.databases_enterUsername;
    if (widget.dbFrom == 'local' && username == 'root') {
      return l10n.databases_localRootUsernameForbidden;
    }

    if (password.isEmpty) return l10n.databases_enterPassword;
    if (password.contains(' ')) return l10n.databases_passwordNoSpaces;
    if (password.length < 6) return l10n.databases_passwordMinLength;

    if (_permission == 'ip') {
      final ip = _ipController.text.trim();
      if (ip.isEmpty) return l10n.databases_enterIpOrCidr;
      if (ip.contains(' ')) return l10n.databases_ipNoSpaces;
    }

    return null;
  }

  // ── 提交 ────────────────────────────────────────────────────

  Map<String, dynamic> _buildBody() {
    final permission = _permission == 'ip'
        ? _ipController.text.trim()
        : _permission;

    return {
      'name': _nameController.text.trim(),
      'from': widget.dbFrom,
      'database': widget.dbName,
      'format': _selectedFormat,
      'collation': _selectedCollation,
      'username': _usernameController.text.trim(),
      'password': base64Encode(utf8.encode(_passwordController.text)),
      'permission': permission,
      'description': _descriptionController.text.trim(),
    };
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      showAppWarningToast(error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = await ref.read(databaseRepositoryProvider.future);
      await repo.createDatabase(_buildBody());

      if (mounted) {
        showAppSuccessToast(context.l10n.databases_created);
        widget.onSuccess?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showAppErrorToast(
          context.l10n.databases_createFailed,
          description: '$e',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── UI 构建 ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ActionSheetScaffold(
      isAdaptive: true,
      showHandle: false,
      hasHorizontalPadding: true,
      contentPadding: EdgeInsets.zero,
      scrollPhysics: _pickerExpanded
          ? const NeverScrollableScrollPhysics()
          : null,
      panelHeader: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.l10n.common_cancel,
                  style: TextStyle(
                    color: AppColors.secondaryLabel(context),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Text(
              context.l10n.databases_createDatabase,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.label(context),
                letterSpacing: -0.4,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CupertinoActivityIndicator(radius: 10)
                    : Text(
                        context.l10n.common_create,
                        style: TextStyle(
                          color: CupertinoColors.activeBlue.resolveFrom(
                            context,
                          ),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 基本信息 ──
          AppCupertinoSectionHeader(title: context.l10n.databases_basicInfo),
          AppCupertinoGroupedBox(
            children: [
              AppCupertinoFormTile(
                label: context.l10n.databases_databaseName,
                child: SizedBox(
                  height: 44,
                  child: CupertinoTextField(
                    controller: _nameController,
                    placeholder: context.l10n.databases_enterDatabaseName,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.label(context),
                    ),
                    decoration: const BoxDecoration(),
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: _syncUsername,
                  ),
                ),
              ),
              AppCupertinoFormTile(
                label: context.l10n.databases_username,
                child: SizedBox(
                  height: 44,
                  child: CupertinoTextField(
                    controller: _usernameController,
                    placeholder: context.l10n.databases_enterUsername,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.label(context),
                    ),
                    decoration: const BoxDecoration(),
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (_) => _lastSyncedName = '',
                  ),
                ),
              ),
              AppCupertinoFormTile(
                label: context.l10n.databases_password,
                isLast: true,
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _passwordController,
                          placeholder: context.l10n.databases_enterPassword,
                          obscureText: _obscurePassword,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.label(context),
                          ),
                          decoration: const BoxDecoration(),
                          autocorrect: false,
                          enableSuggestions: false,
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? TablerIcons.eye_off
                              : TablerIcons.eye,
                          size: 18,
                          color: AppColors.secondaryLabel(context),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        onPressed: () => setState(
                          () => _passwordController.text = _generatePassword(),
                        ),
                        child: Icon(
                          TablerIcons.refresh,
                          size: 18,
                          color: CupertinoColors.activeBlue.resolveFrom(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── 字符集 ──
          const SizedBox(height: 24),
          AppCupertinoSectionHeader(title: context.l10n.databases_charset),
          AppCupertinoGroupedBox(
            children: [
              AppCupertinoFormTile(
                label: context.l10n.databases_charset,
                child: _optionsLoading
                    ? _skeletonField()
                    : AppInlinePicker<String>(
                        value: _selectedFormat,
                        anchorHeight: 44,
                        backgroundColor: Colors.transparent,
                        options: _formatOptions
                            .map(
                              (o) => AppPickerOption(
                                value: o.format,
                                label: o.format,
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedFormat = v;
                          _updateCollations();
                        }),
                        onExpandChanged: (expanded) =>
                            setState(() => _pickerExpanded = expanded),
                      ),
              ),
              if (_optionsLoading || _collations.isNotEmpty)
                AppCupertinoFormTile(
                  label: context.l10n.databases_collation,
                  isLast: true,
                  child: _optionsLoading
                      ? _skeletonField()
                      : AppInlinePicker<String>(
                          value: _selectedCollation,
                          anchorHeight: 44,
                          backgroundColor: Colors.transparent,
                          options: [
                            AppPickerOption(
                              value: '',
                              label: context.l10n.databases_default,
                            ),
                            ..._collations.map(
                              (c) => AppPickerOption(value: c, label: c),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedCollation = v),
                          onExpandChanged: (expanded) =>
                              setState(() => _pickerExpanded = expanded),
                        ),
                ),
            ],
          ),
          if (!_optionsLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Text(
                context.l10n.databases_collationHint,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tertiaryLabel(context),
                ),
              ),
            ),

          // ── 访问权限 ──
          const SizedBox(height: 24),
          AppCupertinoSectionHeader(
            title: context.l10n.databases_accessPermissions,
          ),
          AppCupertinoGroupedBox(
            children: [
              AppCupertinoFormTile(
                label: context.l10n.databases_grantScope,
                isLast: _permission != 'ip',
                child: AppInlinePicker<String>(
                  value: _permission,
                  anchorHeight: 44,
                  backgroundColor: Colors.transparent,
                  options: [
                    AppPickerOption(
                      value: '%',
                      label: context.l10n.databases_anyHost,
                    ),
                    if (widget.dbFrom != 'local')
                      AppPickerOption(
                        value: 'localhost',
                        label: context.l10n.databases_localhostOnly,
                      ),
                    AppPickerOption(
                      value: 'ip',
                      label: context.l10n.databases_specifiedIp,
                    ),
                  ],
                  onChanged: (v) => setState(() => _permission = v),
                  onExpandChanged: (expanded) =>
                      setState(() => _pickerExpanded = expanded),
                ),
              ),
              if (_permission == 'ip')
                AppCupertinoFormTile(
                  label: context.l10n.databases_ipAddress,
                  isLast: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: CupertinoTextField(
                      controller: _ipController,
                      placeholder: context.l10n.databases_ipExample,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: 3,
                      minLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.label(context),
                      ),
                      decoration: const BoxDecoration(),
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                  ),
                ),
            ],
          ),

          // ── 描述 ──
          const SizedBox(height: 24),
          AppCupertinoSectionHeader(
            title: context.l10n.databases_descriptionOptional,
          ),
          AppCupertinoGroupedBox(
            children: [
              AppCupertinoFormTile(
                label: context.l10n.databases_description,
                isLast: true,
                child: SizedBox(
                  height: 44,
                  child: CupertinoTextField(
                    controller: _descriptionController,
                    placeholder: context.l10n.databases_optionalRemark,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.label(context),
                    ),
                    decoration: const BoxDecoration(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _skeletonField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.tertiaryBackground(context).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
