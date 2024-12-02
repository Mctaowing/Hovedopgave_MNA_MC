extends Area2D
class_name InteractionArea

@export var action_name: String = "interact"


var interact: Callable = func():
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass


@warning_ignore("unused_parameter")
func _on_body_entered(body: Node2D) -> void:
	InteractionManager.register_area(self)


@warning_ignore("unused_parameter")
func _on_body_exited(body: Node2D) -> void:
	InteractionManager.unregister_area(self)
