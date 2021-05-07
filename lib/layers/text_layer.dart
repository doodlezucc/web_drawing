import 'dart:html';
import 'dart:svg' as svg;

import 'package:web_drawing/binary.dart';
import 'package:web_drawing/font_styleable.dart';
import 'package:web_drawing/layers/layer.dart';
import 'package:web_drawing/web_drawing.dart';

class TextLayer extends Layer {
  svg.TextElement textElement;

  String _text;
  String get text => _text;
  set text(String text) {
    textElement.children.clear();

    // Split text into separate tspan's because SVG doesn't
    // support multiline text '-'
    var lines = text.split('\n');
    textElement.text = lines.first;

    textElement.children.addAll(lines.sublist(1).map((line) {
      var empty = line.isEmpty;

      var span = svg.TSpanElement()
        // Empty lines wouldn't be displayed at all
        ..text = empty ? line = '_' : line
        ..x.baseVal.appendItem(_zeroLength)
        ..dy
            .baseVal
            .appendItem(layerEl.createSvgLength()..valueAsString = '1.2em');

      if (empty) {
        span.style.visibility = 'hidden';
      }

      return span;
    }));

    _text = text;
  }

  svg.Length _zeroLength;

  TextLayer(DrawingCanvas canvas) : super(canvas) {
    _zeroLength = layerEl.createSvgLength()..value = 0;
    textElement = svg.TextElement()
      ..x.baseVal.appendItem(_zeroLength)
      ..y.baseVal.appendItem(_zeroLength)
      ..text = 'Text'
      ..setAttribute('paint-order', 'stroke')
      ..setAttribute('text-anchor', 'middle')
      ..setAttribute('dominant-baseline', 'central');
    layerEl.append(textElement);
  }

  @override
  void onMouseDown(Point first, Stream<Point> stream) {
    move(first);
    stream.listen((p) => move(p));
  }

  void move(Point p) {
    textElement
      ..x.baseVal[0].value = p.x
      ..y.baseVal[0].value = p.y;
    textElement.children
        .whereType<svg.TSpanElement>()
        .forEach((span) => span.x.baseVal[0].value = p.x);
  }

  @override
  void writeToBytes(BinaryWriter writer) {
    writer.addUInt8(layerType); // Layer type
    writer.addInt32(textElement.x.baseVal[0].value);
    writer.addInt32(textElement.y.baseVal[0].value);
    writer.addString(text);
  }

  @override
  void loadFromBytes(BinaryReader reader) {
    move(Point(reader.readInt32(), reader.readInt32()));
    text = reader.readString();
  }

  @override
  int get layerType => 1;
}

class StylizedTextLayer extends TextLayer with FontStyleable {
  StylizedTextLayer(DrawingCanvas canvas) : super(canvas);

  @override
  CssStyleDeclaration get style => layerEl.style;

  @override
  int get layerType => 2;

  @override
  void writeToBytes(BinaryWriter writer) {
    super.writeToBytes(writer);
    writeStyleToBytes(writer);
  }

  @override
  void loadFromBytes(BinaryReader reader) {
    super.loadFromBytes(reader);
    readStyleFromBytes(reader);
  }
}
