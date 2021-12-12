extends Label

func _on_TileMap_bomb_count_change(bombs):
	
	self.text = str(bombs)
