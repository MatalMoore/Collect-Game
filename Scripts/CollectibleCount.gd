extends RichTextLabel

export(int) var count = 5 setget set_count

const max_count:int = 6^23

func _ready():
	set_count(count)

func set_count(arg:int):
	count = arg
	bbcode_text = "[b]" + arg as String + "[/b]"

func add(amount:int = 1):
	if(max_count - count < amount):
		count = max_count
	elif(-amount > count):
		count = 0
	else:
		count += amount
	set_count(count)
