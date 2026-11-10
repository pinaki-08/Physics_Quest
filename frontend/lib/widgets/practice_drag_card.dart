import 'package:flutter/material.dart';

import '../theme.dart';

bool practiceDragRequiresHold(BuildContext context) =>
    switch (Theme.of(context).platform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };

class PracticeDragCard extends StatefulWidget {
  final String prefix;
  final int index;
  final String text;
  final bool enabled;
  final Widget child;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

  const PracticeDragCard({
    super.key,
    required this.prefix,
    required this.index,
    required this.text,
    required this.enabled,
    required this.child,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  @override
  State<PracticeDragCard> createState() => _PracticeDragCardState();
}

class _PracticeDragCardState extends State<PracticeDragCard> {
  EdgeDraggingAutoScroller? _autoScroller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollable = Scrollable.maybeOf(context);
    if (_autoScroller?.scrollable != scrollable) {
      _autoScroller?.stopAutoScroll();
      _autoScroller = scrollable == null
          ? null
          : EdgeDraggingAutoScroller(scrollable, velocityScalar: 30);
    }
  }

  @override
  void dispose() {
    _autoScroller?.stopAutoScroll();
    super.dispose();
  }

  void _updateDrag(DragUpdateDetails details) {
    _autoScroller?.startAutoScrollIfNecessary(
      Rect.fromCenter(center: details.globalPosition, width: 24, height: 24),
    );
  }

  void _endDrag(DraggableDetails details) {
    _autoScroller?.stopAutoScroll();
    if (mounted) widget.onDragEnded();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final feedback = SizedBox(
          width: constraints.maxWidth,
          child: Material(
            key: ValueKey('${widget.prefix}-drag-feedback-${widget.index}'),
            elevation: 5,
            color: AppColors.surface,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.learnDeep),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                widget.text,
                style: const TextStyle(
                  color: AppColors.learnDeep,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ),
        );
        final fadingCard = Opacity(opacity: 0.35, child: widget.child);
        final key = ValueKey('${widget.prefix}-drag-source-${widget.index}');
        return MouseRegion(
          cursor: widget.enabled ? SystemMouseCursors.grab : MouseCursor.defer,
          child: practiceDragRequiresHold(context)
              ? LongPressDraggable<int>(
                  key: key,
                  data: widget.index,
                  maxSimultaneousDrags: widget.enabled ? 1 : 0,
                  feedback: feedback,
                  childWhenDragging: fadingCard,
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  rootOverlay: true,
                  onDragStarted: widget.onDragStarted,
                  onDragUpdate: _updateDrag,
                  onDragEnd: _endDrag,
                  child: widget.child,
                )
              : Draggable<int>(
                  key: key,
                  data: widget.index,
                  maxSimultaneousDrags: widget.enabled ? 1 : 0,
                  feedback: feedback,
                  childWhenDragging: fadingCard,
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  affinity: Axis.horizontal,
                  rootOverlay: true,
                  onDragStarted: widget.onDragStarted,
                  onDragUpdate: _updateDrag,
                  onDragEnd: _endDrag,
                  child: widget.child,
                ),
        );
      },
    );
  }
}
