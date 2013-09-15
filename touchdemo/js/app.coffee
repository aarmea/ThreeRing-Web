

setupBoard = () ->
	#$("#drawContainer").append("<canvas id='drawCanvas'></canvas>");
	#window.addEventListener('resize', resizeCanvas, false);
	#resizeCanvas();
	setupDrawing();
	return

resizeCanvas = () ->
	$("#drawCanvas").width($(window).width())
	$("#drawCanvas").height($(window).height())
	return

setupDrawing = () ->


$(() ->	
	# if not Modernizr.touch
	# 	$("div.no-touch-warning").show();
	# 	return

	threeRing = new ThreeRing "drawContainer"
	threeRing.initiate()
	threeRing.initDraw()
	return
);

class ThreeRing
	constructor: (@canvasContainer) ->

	initiate: () ->
		@stage = new Kinetic.Stage({
			container: @canvasContainer,
			width: $(window).width(),
			height: $(window).height()
		});
		@background = new Kinetic.Rect({
		    x: 0,
		    y: 0,
		    width: @stage.getWidth(),
		    height: @stage.getHeight(),
		    fill: 'white',
		    stroke: 'black',
		    strokeWidth: 1,
		})
		$(window).on 'resize', ()=>
			if @stage.getWidth() < $(window).width()
				@stage.setWidth $(window).width()
				@background.setWidth @stage.getWidth()
			
			if @stage.getHeight() < $(window).height()
				@stage.setHeight $(window).height()
				@background.setHeight @stage.getHeight()

			@stage.drawScene()
			return
		return

	initDraw: () ->
		@drawMoving = false
		@drawLayer = new Kinetic.Layer()
		@stage.add(@drawLayer)
		@drawLayer.add @background
		@drawLayer.draw()

		quadInterface = 
			x: 0,
			y: 0,
			width: @stage.getWidth(),
			height: @stage.getHeight()
		@savedPoints = new QuadTree quadInterface
		@savedLines = []
		points = []
		newLine = null

		@background.on 'mousedown touchstart', (event) =>
			console.log "start draw"
			console.log event
			if @drawMoving
				@drawMoving = false
				@drawLayer.drawScene()
			else
				points = []
				pressure = 1
				if event instanceof MouseEvent
					points.push @stage.getMousePosition()
				else if event instanceof TouchEvent
					points.push @stage.getTouchPosition()
					pressure = event.touches[0].force if event.touches[0].force?

				line = new Kinetic.Line 
					points: points,
					stroke: 'rgba(255,0,0,' + 255*pressure + ')',
					strokeWidth: 5 * pressure,
					lineCap: 'round',
					lineJoin: 'round'
				@savedLines.push line
				@drawLayer.add @savedLines[@savedLines.length - 1]
				@drawMoving = true
			return

		@background.on 'mousemove touchmove', () =>
			return if not @drawMoving

			if event instanceof MouseEvent
					points.push @stage.getMousePosition()
			else if event instanceof TouchEvent
				points.push @stage.getTouchPosition()
			@savedLines[@savedLines.length - 1].setPoints points
			@drawLayer.drawScene()
			return

		@background.on 'mouseup touchend', () =>
			console.log "end draw"
			@drawMoving = false
			lineIndex = @savedLines.length - 1
			for point in points
				@savedPoints.insert { x: point.x, y: point.y}

			console.log(@savedPoints)
			return