extends Label

var start_time = 0
var started = false
var counter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if started:
		counter = (OS.get_ticks_msec() - start_time) / 1000
		
		self.text = str(counter)
	

func _on_TileMap_level_started():
	start_time = OS.get_ticks_msec()
	started = true


func _on_TileMap_level_stopped():
	started = false
