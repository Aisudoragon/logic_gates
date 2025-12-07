class_name CustomGate extends Node

var _wire_tiles: Dictionary[Vector2i, Wires.WireTile]
var _wire_crossing_tiles: Dictionary[Vector2i, Wires.WireCrossing]
var _gate_tiles: Dictionary[Vector2i, int]
var _gates: Dictionary[int, Wires.GateTile]
