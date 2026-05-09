extends Node

var textbox:RichTextLabel

func send_text(text:String, with_newline:bool = true):
	if textbox:
		textbox.append_text(text)
		if with_newline:
			textbox.newline()


func set_textbox(tbox:RichTextLabel):
	textbox = tbox
	textbox.tree_exited.connect(_clear_textbox)

func _clear_textbox():
	textbox = null
