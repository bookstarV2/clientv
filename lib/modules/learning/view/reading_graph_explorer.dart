import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/reading_graph.dart';
import 'reading_graph_canvas.dart';

/// Session-only arrangement. Never changes the underlying reading records.
class ReadingGraphExplorer extends StatefulWidget {
  const ReadingGraphExplorer({
    super.key,
    required this.graph,
    required this.onClose,
    required this.onOpen,
  });
  final ReadingGraph graph;
  final VoidCallback onClose;
  final ValueChanged<ReadingNode> onOpen;

  @override
  State<ReadingGraphExplorer> createState() => _ReadingGraphExplorerState();
}

class _ReadingGraphExplorerState extends State<ReadingGraphExplorer>
    with SingleTickerProviderStateMixin {
  final _offsets = <String, Offset>{};
  final _velocity = <String, Offset>{};
  final _pinned = <String>{};
  late final Ticker _ticker;
  ReadingGraphLayout? _baseline;
  Duration _lastTick = Duration.zero;
  bool _reduceMotion = false;
  int _frames = 0;
  Offset _pan = Offset.zero;
  double _zoom = 1;
  String? _selected;
  String? _dragging;
  String? _pressedNode;
  Offset _anchor = Offset.zero;
  Offset _lastFocal = Offset.zero;
  double _baseZoom = 1;
  double _baseGestureScale = 1;
  int _pointers = 0;
  int _touchCount = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _ticker.stop();
    } else {
      _wake();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _wake() {
    _frames = 0;
    if (!_reduceMotion && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final base = _baseline;
    if (base == null) return;
    final dt = ((elapsed - _lastTick).inMicroseconds / 16667).clamp(.1, 2.0);
    _lastTick = elapsed;
    final forces = <String, Offset>{};
    for (final node in widget.graph.nodes) {
      forces[node.id] = (_offsets[node.id] ?? Offset.zero) * -.025;
    }
    for (final node in widget.graph.nodes) {
      final parent = node.parentId;
      if (parent == null) continue;
      final original = base.positions[node.id]! - base.positions[parent]!;
      final delta = original +
          (_offsets[node.id] ?? Offset.zero) -
          (_offsets[parent] ?? Offset.zero);
      if (delta.distance < .01) continue;
      final force = delta /
          delta.distance *
          ((delta.distance - original.distance) * .035);
      forces[node.id] = forces[node.id]! - force;
      forces[parent] = forces[parent]! + force;
    }
    var movement = 0.0;
    setState(() {
      for (final node in widget.graph.nodes) {
        if (_pinned.contains(node.id)) continue;
        var speed =
            ((_velocity[node.id] ?? Offset.zero) + forces[node.id]! * dt) * .78;
        if (speed.distance > 3) speed = speed / speed.distance * 3;
        _velocity[node.id] = speed;
        _offsets[node.id] = (_offsets[node.id] ?? Offset.zero) + speed * dt;
        movement += speed.distanceSquared;
      }
    });
    _frames++;
    if (_dragging == null && (movement < .0005 || _frames > 600)) {
      _ticker.stop();
    }
  }

  @override
  void didUpdateWidget(covariant ReadingGraphExplorer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.graph, widget.graph)) {
      _reset();
      _baseline = null;
    }
  }

  void _reset() {
    _offsets.clear();
    _pinned.clear();
    _velocity.clear();
    _pan = Offset.zero;
    _zoom = 1;
    _selected = null;
    _dragging = null;
    _pointers = 0;
    _wake();
  }

  void _releaseNode() {
    _pinned.clear();
    _dragging = null;
    if (_reduceMotion) {
      _offsets.clear();
      _velocity.clear();
    } else {
      _wake();
    }
  }

  ReadingNode? _hit(ReadingGraphLayout layout, Offset local) {
    final scene = (local - _pan) / _zoom;
    ReadingNode? nearest;
    var distance = 22 / _zoom;
    for (final node in widget.graph.nodes) {
      final next = (layout.positions[node.id]! - scene).distance;
      if (next < distance) {
        nearest = node;
        distance = next;
      }
    }
    return nearest;
  }

  void _zoomAt(double next, Offset focus) {
    final anchor = (focus - _pan) / _zoom;
    _zoom = next.clamp(.35, 8);
    _pan = focus - anchor * _zoom;
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: '지도 탐색 닫기',
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
                const Expanded(
                  child: Text(
                    '나의 독서 지도',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
                IconButton(
                  tooltip: '처음으로',
                  onPressed: () => setState(_reset),
                  icon: const Icon(Icons.restart_alt),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '점을 끌고 놓아 보세요 · 빈 곳 이동 · 두 손가락 확대·축소',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF737D77)),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final layout = ReadingGraphLayout(widget.graph, size);
                  if (_baseline == null) {
                    if (!_reduceMotion) {
                      for (var i = 0; i < widget.graph.nodes.length; i++) {
                        _offsets[widget.graph.nodes[i].id] = Offset(
                          (i % 3 - 1) * 2.0,
                          (i % 5 - 2).toDouble(),
                        );
                      }
                    }
                  }
                  _baseline = ReadingGraphLayout(widget.graph, size);
                  for (final entry in _offsets.entries) {
                    if (layout.positions.containsKey(entry.key)) {
                      layout.positions[entry.key] =
                          layout.positions[entry.key]! + entry.value;
                    }
                  }
                  final selected = widget.graph.nodes
                      .where((n) => n.id == _selected)
                      .firstOrNull;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRect(
                          child: Listener(
                            onPointerDown: (e) {
                              _touchCount++;
                              if (_touchCount == 1) {
                                _pressedNode =
                                    _hit(layout, e.localPosition)?.id;
                              } else {
                                _pressedNode = null;
                              }
                            },
                            onPointerUp: (_) =>
                                _touchCount = (_touchCount - 1).clamp(0, 10),
                            onPointerCancel: (_) =>
                                _touchCount = (_touchCount - 1).clamp(0, 10),
                            child: GestureDetector(
                              key: const ValueKey('graph-explorer-surface'),
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (d) => setState(
                                () => _selected =
                                    _hit(layout, d.localPosition)?.id,
                              ),
                              onScaleStart: (d) {
                                _pointers = d.pointerCount;
                                _baseZoom = _zoom;
                                _baseGestureScale = 1;
                                _lastFocal = d.localFocalPoint;
                                _anchor = (d.localFocalPoint - _pan) / _zoom;
                                _dragging =
                                    d.pointerCount == 1 ? _pressedNode : null;
                                if (_dragging != null) {
                                  _pinned.add(_dragging!);
                                  _wake();
                                  setState(() => _selected = _dragging);
                                }
                              },
                              onScaleUpdate: (d) => setState(() {
                                if (_pointers != d.pointerCount) {
                                  // Rebase when a second finger arrives/leaves: no jump and no accidental node drag.
                                  _pointers = d.pointerCount;
                                  _releaseNode();
                                  _baseZoom = _zoom;
                                  _baseGestureScale = d.scale;
                                  _anchor = (d.localFocalPoint - _pan) / _zoom;
                                  _lastFocal = d.localFocalPoint;
                                  return;
                                }
                                if (d.pointerCount > 1) {
                                  _zoom =
                                      (_baseZoom * d.scale / _baseGestureScale)
                                          .clamp(.35, 8);
                                  _pan = d.localFocalPoint - _anchor * _zoom;
                                } else if (_dragging != null) {
                                  _offsets[_dragging!] =
                                      (_offsets[_dragging!] ?? Offset.zero) +
                                          (d.localFocalPoint - _lastFocal) /
                                              _zoom;
                                  _wake();
                                } else {
                                  _pan += d.localFocalPoint - _lastFocal;
                                }
                                _lastFocal = d.localFocalPoint;
                              }),
                              onScaleEnd: (_) {
                                setState(_releaseNode);
                                _pointers = 0;
                              },
                              child: Transform(
                                key: const ValueKey('graph-explorer-transform'),
                                transform: Matrix4.identity()
                                  ..translate(_pan.dx, _pan.dy)
                                  ..scale(_zoom),
                                child: CustomPaint(
                                  size: size,
                                  painter: ReadingGraphPainter(
                                    layout,
                                    selectedId: _selected,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Material(
                          color: Colors.white,
                          elevation: 2,
                          borderRadius: BorderRadius.circular(28),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: '탐색 지도 축소',
                                onPressed: () => setState(
                                  () => _zoomAt(
                                    _zoom / 1.4,
                                    size.center(Offset.zero),
                                  ),
                                ),
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                '${(_zoom * 100).round()}%',
                                key: const ValueKey('graph-zoom-label'),
                              ),
                              IconButton(
                                tooltip: '탐색 지도 확대',
                                onPressed: () => setState(
                                  () => _zoomAt(
                                    _zoom * 1.4,
                                    size.center(Offset.zero),
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                              ),
                              IconButton(
                                tooltip: '탐색 지도 화면 맞춤',
                                onPressed: () => setState(() {
                                  // Preserve the hand-arranged nodes; reset only the camera.
                                  _zoom = 1;
                                  _pan = Offset.zero;
                                }),
                                icon: const Icon(Icons.center_focus_weak),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selected != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          top: 12,
                          child: Material(
                            color: Colors.white.withValues(alpha: .96),
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              title: Text(
                                selected.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                selected.kind == ReadingNodeKind.book
                                    ? '책 · 놓으면 자연스럽게 돌아와요'
                                    : selected.bookTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                tooltip: '선택한 기록 열기',
                                onPressed: () => widget.onOpen(selected),
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
}
