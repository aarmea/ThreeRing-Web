// Generated by CoffeeScript 1.5.0
var ThreeRing, resizeCanvas, setupBoard, setupDrawing;

setupBoard = function() {
  setupDrawing();
};

resizeCanvas = function() {
  $("#drawCanvas").width($(window).width());
  $("#drawCanvas").height($(window).height());
};

setupDrawing = function() {};

$(function() {
  var threeRing;
  threeRing = new ThreeRing("drawContainer");
  threeRing.initiate();
  threeRing.initDraw();
});

ThreeRing = (function() {

  function ThreeRing(canvasContainer) {
    this.canvasContainer = canvasContainer;
  }

  ThreeRing.prototype.initiate = function() {
    var _this = this;
    this.stage = new Kinetic.Stage({
      container: this.canvasContainer,
      width: $(window).width(),
      height: $(window).height()
    });
    this.background = new Kinetic.Rect({
      x: 0,
      y: 0,
      width: this.stage.getWidth(),
      height: this.stage.getHeight(),
      fill: 'white',
      stroke: 'black',
      strokeWidth: 1
    });
    $(window).on('resize', function() {
      if (_this.stage.getWidth() < $(window).width()) {
        _this.stage.setWidth($(window).width());
        _this.background.setWidth(_this.stage.getWidth());
      }
      if (_this.stage.getHeight() < $(window).height()) {
        _this.stage.setHeight($(window).height());
        _this.background.setHeight(_this.stage.getHeight());
      }
      _this.stage.drawScene();
    });
  };

  ThreeRing.prototype.initDraw = function() {
    var newLine, points, quadInterface,
      _this = this;
    this.drawMoving = false;
    this.drawLayer = new Kinetic.Layer();
    this.stage.add(this.drawLayer);
    this.drawLayer.add(this.background);
    this.drawLayer.draw();
    quadInterface = {
      x: 0,
      y: 0,
      width: this.stage.getWidth(),
      height: this.stage.getHeight()
    };
    this.savedPoints = new Quadtree(quadInterface);
    this.savedLines = [];
    points = [];
    newLine = null;
    this.background.on('mousedown touchstart', function(event) {
      var line, pressure;
      console.log("start draw");
      console.log(event);
      if (_this.drawMoving) {
        _this.drawMoving = false;
        _this.drawLayer.drawScene();
      } else {
        points = [];
        pressure = 1;
        if (event instanceof MouseEvent) {
          points.push(_this.stage.getMousePosition());
        } else if (event instanceof TouchEvent) {
          points.push(_this.stage.getTouchPosition());
          if (event.touches[0].force != null) {
            pressure = event.touches[0].force;
          }
        }
        line = new Kinetic.Line({
          points: points,
          stroke: 'rgba(255,0,0,' + 255 * pressure + ')',
          strokeWidth: 5 * pressure,
          lineCap: 'round',
          lineJoin: 'round'
        });
        _this.savedLines.push(line);
        _this.drawLayer.add(_this.savedLines[_this.savedLines.length - 1]);
        _this.drawMoving = true;
      }
    });
    this.background.on('mousemove touchmove', function() {
      if (!_this.drawMoving) {
        return;
      }
      if (event instanceof MouseEvent) {
        points.push(_this.stage.getMousePosition());
      } else if (event instanceof TouchEvent) {
        points.push(_this.stage.getTouchPosition());
      }
      _this.savedLines[_this.savedLines.length - 1].setPoints(points);
      _this.savedLines[_this.savedLines.length - 1].drawScene();
    });
    return this.background.on('mouseup touchend', function() {
      var lineIndex, point, _i, _len;
      console.log("end draw");
      _this.drawMoving = false;
      lineIndex = _this.savedLines.length - 1;
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        _this.savedPoints.insert({
          x: point.x,
          y: point.y,
          width: 1,
          height: 1
        });
      }
      console.log(_this.savedPoints);
    });
  };

  return ThreeRing;

})();
