tool
extends HSlider


export(Texture) var grabber setget set_grabber
export(Texture) var grabber_highlight setget set_grabber_highlight

func set_grabber(texture_value : Texture):
	grabber = texture_value
	set("custom_icons/grabber", grabber)


func set_grabber_highlight(texture_value : Texture):
	grabber_highlight = texture_value
	set("custom_icons/grabber_highlight", grabber_highlight)
