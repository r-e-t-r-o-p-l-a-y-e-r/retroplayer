/// Local-only path policy: reject remote / non-filesystem URI schemes.
///
/// Plain absolute or relative filesystem paths are allowed. `file:` URIs are
/// allowed. Network and streaming schemes (`http`, `https`, `rtsp`, …) are not.
bool isLocalFilesystemPath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return false;

  final lower = trimmed.toLowerCase();
  const blockedPrefixes = <String>[
    'http:',
    'https:',
    'ftp:',
    'ftps:',
    'rtsp:',
    'rtsps:',
    'rtp:',
    'udp:',
    'tcp:',
    'tls:',
    'data:',
    'smb:',
    'nfs:',
    'mms:',
    'mmsh:',
  ];
  for (final prefix in blockedPrefixes) {
    if (lower.startsWith(prefix)) return false;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.scheme.isEmpty) {
    return true;
  }

  final scheme = uri.scheme.toLowerCase();
  if (scheme == 'file') return true;
  // Windows drive letter paths parse as a single-letter scheme (e.g. `C:`).
  if (scheme.length == 1 &&
      scheme.codeUnitAt(0) >= 97 &&
      scheme.codeUnitAt(0) <= 122) {
    return true;
  }
  return false;
}
