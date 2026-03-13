extends Node2D

@onready var wires: Wires = $Wires


func _ready() -> void:
	print("Testing wire signal spread")

	if await test_signal_spread():
		print("Success")
	else:
		print("Fail")

	wires._wire_tiles.clear()

	print("Testing signal going through a crossing")

	if await test_signal_crossing():
		print("Success")
	else:
		print("Fail")

	wires._wire_tiles.clear()
	wires._wire_crossing_tiles.clear()

	print("Testing working of all gates")

	if await test_through_gate():
		print("Success")
	else:
		print("Fail")

	wires._wire_tiles.clear()
	wires._gate_tiles.clear()
	wires._gates.clear()

	get_tree().quit()


func test_signal_spread() -> bool:
	wires._wire_tiles[Vector2i.ZERO] = wires.WireTile.new(
			EditorMode.Direction.RIGHT + EditorMode.Direction.DOWN + EditorMode.Direction.LEFT + EditorMode.Direction.UP)
	wires._wire_tiles[Vector2i.RIGHT] = wires.WireTile.new(EditorMode.Direction.LEFT)
	wires._wire_tiles[Vector2i.DOWN] = wires.WireTile.new(EditorMode.Direction.UP)
	wires._wire_tiles[Vector2i.LEFT] = wires.WireTile.new(EditorMode.Direction.RIGHT)
	wires._wire_tiles[Vector2i.UP] = wires.WireTile.new(EditorMode.Direction.DOWN)

	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.LEFT, true, 1))

	await get_tree().create_timer(0.1).timeout

	if (
			wires._wire_tiles[Vector2i.ZERO].state == true
			and wires._wire_tiles[Vector2i.RIGHT].state == true
			and wires._wire_tiles[Vector2i.DOWN].state == true
			and wires._wire_tiles[Vector2i.LEFT].state == true
			and wires._wire_tiles[Vector2i.UP].state == true
	):
		return true
	else:
		return false


func test_signal_crossing() -> bool:
	wires._wire_tiles[Vector2i.RIGHT] = wires.WireTile.new(EditorMode.Direction.LEFT)
	wires._wire_tiles[Vector2i.LEFT] = wires.WireTile.new(EditorMode.Direction.RIGHT)
	wires._wire_tiles[Vector2i.DOWN] = wires.WireTile.new(EditorMode.Direction.UP)
	wires._wire_tiles[Vector2i.UP] = wires.WireTile.new(EditorMode.Direction.DOWN)
	wires._wire_crossing_tiles[Vector2i.ZERO] = wires.WireCrossing.new()

	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.LEFT, true, 1))
	await get_tree().create_timer(0.1).timeout

	if (
			wires._wire_tiles[Vector2i.RIGHT].state == true
			and wires._wire_tiles[Vector2i.LEFT].state == true
			and wires._wire_tiles[Vector2i.DOWN].state == false
			and wires._wire_tiles[Vector2i.UP].state == false
			and wires._wire_crossing_tiles[Vector2i.ZERO].horizontal_wire.state == true
	):

		wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.LEFT, false, 2))
		wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN, true, 3))
		await get_tree().create_timer(0.1).timeout

		if (
			wires._wire_tiles[Vector2i.DOWN].state == true
			and wires._wire_tiles[Vector2i.UP].state == true
			and wires._wire_tiles[Vector2i.RIGHT].state == false
			and wires._wire_tiles[Vector2i.LEFT].state == false
			and wires._wire_crossing_tiles[Vector2i.ZERO].vertical_wire.state == true
		):
			return true
	return false


func test_through_gate() -> bool:
	wires._wire_tiles[Vector2i.UP + Vector2i.LEFT] = wires.WireTile.new(EditorMode.Direction.RIGHT)
	wires._wire_tiles[Vector2i.DOWN + Vector2i.LEFT] = wires.WireTile.new(EditorMode.Direction.RIGHT)
	wires._wire_tiles[Vector2i.UP] = wires.WireTile.new(EditorMode.Direction.LEFT)
	wires._wire_tiles[Vector2i.DOWN] = wires.WireTile.new(EditorMode.Direction.LEFT)
	wires._wire_tiles[Vector2i.RIGHT * 2] = wires.WireTile.new(EditorMode.Direction.RIGHT)
	wires._wire_tiles[Vector2i.RIGHT * 3] = wires.WireTile.new(EditorMode.Direction.LEFT)

	wires._gates[0] = wires.GateTile.new(EditorMode.Gate.AND)
	wires._gates[0].inputs = [Vector2i.UP, Vector2i.DOWN]
	wires._gates[0].outputs = [Vector2i.RIGHT * 2]

	wires._gate_tiles[Vector2i.UP] = 0
	wires._gate_tiles[Vector2i.DOWN] = 0
	wires._gate_tiles[Vector2i.RIGHT * 2] = 0

	var tests: Array[bool]

	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, false, 1))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == false)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, true, 2))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == false)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, true, 3))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == true)

	wires._gates[0].gate = EditorMode.Gate.NAND

	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, false, 4))
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, false, 5))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == true)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, true, 6))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == true)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, true, 7))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == false)

	wires._gates[0].gate = EditorMode.Gate.OR

	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, false, 8))
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, false, 9))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == false)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, true, 10))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == true)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, true, 11))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == true)

	wires._gates[0].gate = EditorMode.Gate.NOR

	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, false, 12))
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, false, 13))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == true)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, true, 14))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == false)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, true, 15))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == false)

	wires._gates[0].gate = EditorMode.Gate.XOR

	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, false, 16))
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, false, 17))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == false)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, true, 18))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == true)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, true, 19))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == false)

	wires._gates[0].gate = EditorMode.Gate.XNOR

	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, false, 20))
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, false, 21))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == true)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.UP + Vector2i.LEFT, true, 22))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == false)
	wires._callable_queue.push_back(Callable(wires, &"_spread_wire_logic").bind(Vector2i.DOWN + Vector2i.LEFT, true, 23))
	await get_tree().create_timer(0.1).timeout
	tests.append(wires._wire_tiles[Vector2i.RIGHT * 3].state == true)

	for test in tests:
		if not test:
			print(tests)
			return false
	return true
