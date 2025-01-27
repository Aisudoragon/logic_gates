extends Camera2D

var zoomSpeed: float = 0.05
var zoomMin: float = 0.05
var zoomMax: float = 2.0
var dragSensitivity: float = 1.0
@export var camera_speed: float = 1000.0


func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	position += camera_speed * direction / zoom * delta


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_mb: InputEventMouseButton = event
		if event_mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(zoomSpeed, zoomSpeed)
		elif event_mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoomSpeed, zoomSpeed)
		zoom = clamp(zoom, Vector2(zoomMin, zoomMin), Vector2(zoomMax, zoomMax))
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var event_mm: InputEventMouseMotion = event
		position -= event_mm.relative * dragSensitivity / zoom
