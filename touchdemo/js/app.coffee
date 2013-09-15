$(() ->
	# if not Modernizr.touch
	# 	$("div.no-touch-warning").show();
	# 	return
	
	$("[data-toggle='tooltip']").tooltip()

	threeRing = new ThreeRing "drawContainer"
	threeRing.initDraw()
	return
);

confirmAction = (title, content, callback, confirmText = "Confirm", dismissText = "Close") ->
	$("#confirmModal .modal-title").text title
	$("#confirmModal .modal-body").html($('<p/>').html(content))
	$("#confirmModal .modal-confirm").text confirmText
	$("#confirmModal .modal-dismiss").text dismissText
	$("#confirmModal .modal-confirm").on 'click', (event) ->
		$("#confirmModal .modal-confirm").unbind 'click'
		$("#confirmModal .modal-dismiss").unbind 'hide.bs.modal'
		$("#confirmModal").modal 'hide'
		callback(true, event)
		return

	$("#confirmModal").on 'hide.bs.modal', () ->
		$("#confirmModal .modal-confirm").unbind 'click'
		$("#confirmModal .modal-dismiss").unbind 'hide.bs.modal'
		callback(false, event)
		return

	$("#confirmModal").modal 'show'
	return

class ThreeRing
	constructor: (@canvasContainer) ->
		$("#drawContainer").append "<canvas id='drawCanvas' />"

		@canvas = new fabric.Canvas 'drawCanvas'
		@canvas.setWidth $(window).width() if @canvas.width < $(window).width()
		@canvas.setHeight $(window).height() if @canvas.height < $(window).height()

		$(window).on 'resize', () =>
			@canvas.setWidth $(window).width() if @canvas.width < $(window).width()
			@canvas.setHeight $(window).height() if @canvas.height < $(window).height()
			return

		@saves = new Array()
		@currentSave = -1
		@saves = JSON.parse(localStorage['threering_notes']) if localStorage['threering_notes']?

		@attachButtons()

	initDraw: () ->
		@canvas.freeDrawingBrush.color = 'black'
		@canvas.freeDrawingBrush.width = 5
		#$("#btnTurnOffDraw").click()
		return

	attachButtons: () ->
		$("#btnTurnOffDraw, #btnTurnOnMove").on 'click', () =>
			@toggleDrawingMode()
			$(event.currentTarget).blur()
			return
		$("#btnRemoveSelectedItem").on 'click', () =>
			return if $(event.currentTarget).attr('disabled')?
			@delectSelectedItems()
			$(event.currentTarget).blur()
			return
		$(window).on 'keydown', (event) =>
			return !@delectSelectedItems() if event.which == 46 || event.which == 8
		$("#btnSave").on 'click', () =>
			@saveToLocalStorage()
			$(event.currentTarget).blur()
			return
		$("#btnOpenSave").on 'click', () =>
			$("#loadFileModal #modalLoadFileList option").each (event) ->
				$(this).remove()
			for save, i in @saves
				$("#loadFileModal #modalLoadFileList").append $('<option />').val(i).text(save.name)
			$("#loadFileModal").modal 'show'
			$(event.currentTarget).blur()
			return
		$("#loadFileModal .modal-load").on 'click', () =>
			if $("#modalLoadFileList").val()?
				@loadFromLocalStorage($("#modalLoadFileList").val())
			else
				@loadloadFromLocalStorage()
			$("#loadFileModal").modal 'hide'
		$("#btnDeleteSave").on 'click', () =>
			confirmAction("Delete save", "Are you sure you want to delete your current save?", 
				(result) =>
					if result
						@deleteSave @currentSave
					return
				, "Yes", "No")
			$(event.currentTarget).blur()
			return
		$("#btnClearCanvas").on 'click', () =>
			confirmAction("Clear Canvas", "Are you sure you want to clear the canvas?", 
				(result) =>
					@canvas.clear() if result
					return
				, "Yes", "No")
			$(event.currentTarget).blur()
			return
		@canvas.on 'object:selected', () =>
			$("#btnRemoveSelectedItem").removeAttr 'disabled'
			return
		@canvas.on 'selection:created', () ->
			$("#btnRemoveSelectedItem").removeAttr 'disabled'
			return
		@canvas.on 'selection:cleared', () ->
			$("#btnRemoveSelectedItem").attr 'disabled', 'disabled'
			return
		return

	loadFromLocalStorage: (index=-1) ->
		if localStorage['threering_notes']?
			index = localStorage['threering_notes'].length-1 if index == -1
			if localStorage['threering_notes'][index]?
				@currentSave = index
				$("#fileName").text @saves[@currentSave].name
				@canvas.loadFromDatalessJSON @saves[index].saveData, () =>
					@canvas.renderAll true
				return true
		return false

	saveToLocalStorage: () ->
		if not Modernizr.localstorage
			alert "You don't have local storage =["
			return false
		@saves = [] if not @saves?
		if @currentSave == -1
			@saves.push(new SaveFile((new Date()).toUTCString(),@canvas.toDatalessJSON()))
			@currentSave = @saves.length-1
			$("#fileName").text @saves[@currentSave].name
		else
			if @saves[@currentSave]?
				@saves[@currentSave].saveData = @canvas.toDatalessJSON()
			else
				@saves.push(new SaveFile((new Date()).toUTCString(),@canvas.toDatalessJSON()))
				@currentSave = @saves.length-1
				$("#fileName").text @saves[@currentSave].name

		localStorage['threering_notes'] = JSON.stringify(@saves)
		return true

	delectSelectedItems: () ->
		activeObj = @canvas.getActiveObject()
		activeGroup = @canvas.getActiveGroup()
		$("#btnRemoveSelectedItem").attr 'disabled', 'disabled'

		if activeGroup
			for obj in activeGroup.getObjects()
				@canvas.remove obj
			@canvas.discardActiveGroup()
			return true
		else if activeObj
			@canvas.remove(activeObj)
			return true
		return false

	deleteSave: (index=-1) ->
		if index == -1
			@saves = []
		else
			@saves.splice index, 1 if @saves[index]?
		localStorage['threering_notes'] = JSON.stringify(@saves)
		@currentSave = -1
		@newFile()


	newFile: () ->
		$("#fileName").text "New File"
		@canvas.clear()
		@currentSave = -1


	toggleDrawingMode: () ->
		@canvas.isDrawingMode = !@canvas.isDrawingMode
		if @canvas.isDrawingMode
			$("#btnTurnOffDraw").addClass 'active'
			$("#btnTurnOnMove").removeClass 'active'
		else
			$("#btnTurnOffDraw").removeClass 'active'
			$("#btnTurnOnMove").addClass 'active'
		return

class SaveFile
	constructor: (@name, @saveData) ->
	name: null
	saveData: null
