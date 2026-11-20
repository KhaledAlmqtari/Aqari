class PinCredential {
  final String salt;
  final String hash;

  const PinCredential({
    required this.salt,
    required this.hash,
  });
}
