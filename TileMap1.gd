extends TileMap


var tiles_w = 25
var tiles_h = 13

# 25 tiles * 64px = 1600px
# 14 tiles * 64px = 896px

signal bomb_count_change(bombs)
signal level_started
signal level_stopped

var startgame_overlay = preload("res://startgame_overlay.tscn") # Will load when parsing the script.
var endgame_overlay = preload("res://endgame_overlay.tscn") # Will load when parsing the script.

var started = false

var startgame_overlay_instance = 0
var endgame_overlay_instance = 0

var unknown_bombs = 0

# don't change this one, it's for record keeping
var actual_bombs = 0

var tiles = []
var known = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#OS.set_window_size(Vector2(1024, 768))
	
	for y in range(tiles_h):
		tiles.append([])
		known.append([])
		tiles[y].resize(tiles_w)
		known[y].resize(tiles_w)

		for x in range(tiles_w):
			if randf() > 0.90:
				tiles[y][x] = 1
				unknown_bombs += 1 
				actual_bombs += 1
			else:
				tiles[y][x] = 0
			known[y][x] = 0
			
	
	for y in range(tiles_h):
		for x in range(tiles_w):
			get_node(".").set_cell(0, Vector2(x,y))
			
			
	var temp_node = startgame_overlay.instantiate()
	
	temp_node.visible = true
	#var parentSize = get_viewport_rect()
	#var temp_node_pos = temp_node.get_position()
	#temp_node_pos.x = parentSize.size.x * 0.5
	#temp_node_pos.y = -40
	#temp_node.set_position(temp_node_pos)
	
	startgame_overlay_instance = temp_node
	
	temp_node.set_message_text("Ready!")
	temp_node.set_button_text("Start")
	var vportsize = get_viewport().get_visible_rect().size
	temp_node.position = Vector2(vportsize.x * 0.5, vportsize.y * 0.5)
	add_child(temp_node)
	
	endgame_overlay_instance = endgame_overlay.instantiate()
	endgame_overlay_instance.hide()
	add_child(endgame_overlay_instance)
	
	var start_button = temp_node.find_child("StartButton")
	start_button.connect("hud_button_pressed",Callable(self,"on_hud_button_pressed"))
	
	emit_signal("bomb_count_change", unknown_bombs)
	

func on_hud_button_pressed():
	
	if not started:
		emit_signal("level_started")
		started = true
		startgame_overlay_instance.hide()
		
	print("on_hud_button_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func contains_bomb(tilex,tiley):
	return tiles[tiley][tilex] == 1


func _input(event):
	
	if event is InputEventMouseButton:
		
		var globalpos = get_global_mouse_position()
		var localEvent = make_input_local(event)
		globalpos.y -= 64
		
		if not started:
			return
				
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				
				print("event.pressed")
				#var tile_pos = self.local_to_map(globalpos)
				var tile_pos = self.local_to_map(localEvent.position)
				
				print("left button clicked. tile_pos: " + str(tile_pos))
				print("event: " + str(event))
				print("localEvent: " + str(localEvent))
				
				
				if not started:
					emit_signal("level_started")
					started = true
				
				if tile_pos.x < 0:
					return
				if tile_pos.y < 0:
					return
				if tile_pos.x >= (tiles_w):
					return
				if tile_pos.y >= (tiles_h):
					return
					
				if contains_bomb(tile_pos.x, tile_pos.y):
					
					# display "boom!", end game.
					
					emit_signal("level_stopped")
					started = false
	
					endgame_overlay_instance.show()
					var temp_node_pos = endgame_overlay_instance.get_position()
					temp_node_pos.x = -180
					temp_node_pos.y = -40
					endgame_overlay_instance.set_position(temp_node_pos)
					
					pass
					
				
				var bomb_count = get_adjacent_bomb_count(tile_pos.x, tile_pos.y)
				#print("adjacent_bombs: " + str(bomb_count))
				self.revealTile(tile_pos.x, tile_pos.y)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				#print("Right button was clicked at ", event.position)
				
				#var tile_pos = self.local_to_map(globalpos)
				var tile_pos = self.local_to_map(localEvent.position)
				
				# 0 is the numbers, 1 is the bomb flag
				#get_node(".").set_cell(1, Vector2(tilex,tiley),4,Vector2(adjacent_bombs-1,0),0)
				#get_cell_source_id ( int layer, Vector2i coords, bool use_proxies=false ) const
				# layer 0 = things, layer 1 = numbers
				var tile_val = get_node(".").get_cell_source_id(2, Vector2i(tile_pos.x,tile_pos.y))
				
				if tile_val == 0:
					# if there is a bomb flag value, let's clear it
					get_node(".").set_cell(2, Vector2i(tile_pos.x,tile_pos.y),-1)
					# set_cell ( int layer, Vector2i coords, int source_id=-1, Vector2i atlas_coords=Vector2i(-1, -1), int alternative_tile=0 )
					
					unknown_bombs += 1
					emit_signal("bomb_count_change", unknown_bombs)
				else:
					
					# set flag for found bomb
					get_node(".").set_cell(2, Vector2i(tile_pos.x,tile_pos.y),3)
					
					# TODO: check if bomb was really in this location
					unknown_bombs -= 1
					emit_signal("bomb_count_change", unknown_bombs)
					
			pass
	#var tile_pos = MapBox.local_to_map(event.pos)
	


# return the count of actual bombs in the adjacent tiles
func get_adjacent_bomb_count(tilex,tiley):
	var count = 0

	if tiley > 0:
		if tilex > 0 and tiles[tiley-1][tilex-1] == 1:
			count += 1

		if tiles[tiley-1][tilex] == 1:
			count += 1

		if tilex < (tiles_w-1) and tiles[tiley-1][tilex+1] == 1:
			count += 1

	if tilex > 0 and tiles[tiley][tilex-1] == 1:
		count += 1

	if self.tiles[tiley][tilex] == 1:
		count += 1

	if tilex < (self.tiles_w-1) and self.tiles[tiley][tilex+1] == 1:
		count += 1

	if tiley < (self.tiles_h-1):
		if tilex > 0 and self.tiles[tiley+1][tilex-1] == 1:
			count += 1

		if self.tiles[tiley+1][tilex] == 1:
			count += 1

		if tilex < (self.tiles_w-1) and self.tiles[tiley+1][tilex+1] == 1:
			count += 1

	
	return count

func revealTile(tilex, tiley):
	var tilecontent = tiles[tiley][tilex]
	#print("tilecontent: " + str(tilecontent))
	
	if known[tiley][tilex] > 0:
		return
	
	if tilecontent == 0:
		get_node(".").set_cell(0, Vector2(tilex,tiley), 1, Vector2i(0,0), 0)
		var adjacent_bombs = self.get_adjacent_bomb_count(tilex,tiley)
		#print("adjacent count: " + str(adjacent_bombs))
		
		self.known[tiley][tilex] = 2
		
		if adjacent_bombs == 0:

			if tilex > 0:
				self.revealTile(tilex-1,tiley)
			if tiley < (self.tiles_h-1):
				self.revealTile(tilex,tiley+1)
			if tilex < (self.tiles_w-1):
				self.revealTile(tilex+1,tiley)
			if tiley > 0:
				self.revealTile(tilex,tiley-1)
		else:
			#print("adjacent count: " + str(adjacent_bombs))
			# layer 1 is numbers, layer 0 is the see/not see
			get_node(".").set_cell(1, Vector2(tilex,tiley),4,Vector2(adjacent_bombs-1,0),0)

		
	if tilecontent == 1: # bomb
		
		self.known[tiley][tilex] = 1
		pass
		
	
	
