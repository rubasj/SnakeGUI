extends CanvasLayer

signal restart

func _on_restart_button_pressed():
	restart.emit()


func _on_quit_button_pressed():
	get_tree().quit()
