/// AlbumArtFrame shows placeholder when no art is provided.
///
/// Evidence:
/// - `shows placeholder icon when imagePath is null`
///
/// Async path loading is covered by [loadAlbumArtBytes] / ResolveCoverArt unit
/// tests (widget binding can hang on delayed setState + Image scheduling).
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_frame.dart';

void main() {
  testWidgets('shows placeholder icon when imagePath is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AlbumArtFrame(size: 64, placeholderIcon: Icons.album_outlined),
        ),
      ),
    );

    expect(find.byIcon(Icons.album_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
