class SystemLogState {
  const SystemLogState({
    this.files = const [],
    this.selectedFile = '',
    this.content = '',
    this.isLoadingContent = false,
    this.isAgent = true,
  });

  final List<String> files;
  final String selectedFile;
  final String content;
  final bool isLoadingContent;
  final bool isAgent;

  SystemLogState copyWith({
    List<String>? files,
    String? selectedFile,
    String? content,
    bool? isLoadingContent,
    bool? isAgent,
  }) {
    return SystemLogState(
      files: files ?? this.files,
      selectedFile: selectedFile ?? this.selectedFile,
      content: content ?? this.content,
      isLoadingContent: isLoadingContent ?? this.isLoadingContent,
      isAgent: isAgent ?? this.isAgent,
    );
  }
}
