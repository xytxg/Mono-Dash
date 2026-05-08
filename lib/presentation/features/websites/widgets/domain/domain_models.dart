class NewDomainInput {
  const NewDomainInput({
    required this.domain,
    required this.port,
    required this.ssl,
  });

  final String domain;
  final int port;
  final bool ssl;
}
