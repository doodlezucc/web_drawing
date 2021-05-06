import 'dart:html';
import 'dart:svg' as svg;

import 'package:web_drawing/web_drawing.dart';

abstract class Layer {
  final DrawingCanvas canvas;
  final svg.SvgSvgElement layerEl;
  bool visible = true;
  bool get isFocused => canvas.layer == this;

  Layer(this.canvas) : layerEl = svg.SvgSvgElement() {
    layerEl.width.baseVal.valueAsString = '100%';
    layerEl.height.baseVal.valueAsString = '100%';
    layerEl.style.position = 'absolute';
    canvas.container.append(layerEl);
  }

  void onMouseDown(Point first, Stream<Point> moveStream);
}
