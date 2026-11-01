import 'dart:io';
import 'dart:typed_data';

/// Writes a tiny valid mono PCM WAV file MPV can open.
Future<File> writeMinimalWav(
  Directory directory, {
  String name = 'silence.wav',
}) async {
  const sampleRate = 8000;
  const numSamples = 800;
  const bytesPerSample = 2;
  const dataSize = numSamples * bytesPerSample;
  const riffChunkSize = 36 + dataSize;

  final bytes = BytesBuilder();
  void write32(int value) {
    bytes.add([
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
    ]);
  }

  void write16(int value) {
    bytes.add([value & 0xff, (value >> 8) & 0xff]);
  }

  bytes.add('RIFF'.codeUnits);
  write32(riffChunkSize);
  bytes.add('WAVE'.codeUnits);
  bytes.add('fmt '.codeUnits);
  write32(16);
  write16(1);
  write16(1);
  write32(sampleRate);
  write32(sampleRate * bytesPerSample);
  write16(bytesPerSample);
  write16(16);
  bytes.add('data'.codeUnits);
  write32(dataSize);
  bytes.add(List<int>.filled(dataSize, 0));

  final file = File('${directory.path}/$name');
  await file.writeAsBytes(bytes.toBytes());
  return file;
}
