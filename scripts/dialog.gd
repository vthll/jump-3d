extends CanvasLayer

@export var dialogos: dialogo

@onready var text: RichTextLabel = $RichTextLabel

var limit_falas = 0
var atual_fala = 0

var falando = false

var word_show = 0


func _physics_process(_delta: float) -> void:
	
	if falando and text.visible_ratio < 1.0:
		text.visible_characters += 1
		


func _ready() -> void:
	limit_falas = dialogos.dialog.size()
	print(limit_falas)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") or event.is_action_pressed("jump"):
		if atual_fala < limit_falas and not falando:
			falando = true
			atual_fala += 1
		
