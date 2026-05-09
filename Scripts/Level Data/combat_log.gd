extends Node

var textbox:RichTextLabel

func send_text(text:String):
	if textbox:
		textbox.append_text(text)
		textbox.newline()


func set_textbox(tbox:RichTextLabel):
	textbox = tbox
	textbox.tree_exited.connect(_clear_textbox)

func _clear_textbox():
	textbox = null
