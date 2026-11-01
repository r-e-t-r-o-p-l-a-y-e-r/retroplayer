import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_decorations.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_loader.dart';

/// Square album art frame.
///
/// Loads [imagePath] as bytes into a [MemoryImage] (more reliable than
/// [FileImage] for library files on Android). Shows [placeholderIcon] while
/// loading or if the file is missing/unreadable — never an empty grey square.
class AlbumArtFrame extends StatefulWidget {
  const AlbumArtFrame({
    super.key,
    this.image,
    this.imagePath,
    this.size,
    this.compact = false,
    this.placeholderIcon = Icons.music_note_rounded,
  });

  final ImageProvider? image;
  final String? imagePath;
  final double? size;
  final bool compact;
  final IconData placeholderIcon;

  @override
  State<AlbumArtFrame> createState() => _AlbumArtFrameState();
}

class _AlbumArtFrameState extends State<AlbumArtFrame> {
  ImageProvider? _provider;
  int _loadGeneration = 0;

  double get _size {
    if (widget.size != null) return widget.size!;
    if (widget.compact) return RetroSpacing.albumArtMini;
    return RetroSpacing.albumArtSize;
  }

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(AlbumArtFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image ||
        oldWidget.imagePath != widget.imagePath ||
        oldWidget.size != widget.size ||
        oldWidget.compact != widget.compact) {
      _resolve();
    }
  }

  void _resolve() {
    final provided = widget.image;
    if (provided != null) {
      setState(() => _provider = provided);
      return;
    }

    final path = widget.imagePath;
    if (path == null || path.isEmpty) {
      setState(() => _provider = null);
      return;
    }

    final generation = ++_loadGeneration;
    setState(() => _provider = null);

    () async {
      final bytes = await loadAlbumArtBytes(path);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _provider = bytes == null ? null : MemoryImage(bytes);
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    final palette = RetroPalette.of(context);
    final dimension = _size;
    final iconSize = widget.compact ? 18.0 : dimension * 0.35;

    Widget placeholder() {
      return ColoredBox(
        color: Colors.transparent,
        child: Center(
          child: Icon(
            widget.placeholderIcon,
            size: iconSize,
            color: palette.textMuted.withValues(alpha: 0.9),
          ),
        ),
      );
    }

    final provider = _provider;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final decodeWidth = (dimension * dpr).round().clamp(1, 4096);

    return Container(
      width: dimension,
      height: dimension,
      decoration: RetroDecorations.albumFrame(palette, size: dimension),
      clipBehavior: Clip.antiAlias,
      child: provider == null
          ? placeholder()
          : Image(
              image: ResizeImage(
                provider,
                width: decodeWidth,
                allowUpscaling: false,
              ),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) => placeholder(),
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return placeholder();
              },
            ),
    );
  }
}
