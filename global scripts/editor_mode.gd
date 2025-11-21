class_name EditorMode

enum Mode {
	SELECT,
	WIRE,
	GATE,
}

enum Gate {
	NOT,
	AND,
	NAND,
	OR,
	NOR,
	XOR,
	XNOR,
	START,
	STOP,
}

enum Direction {
	RIGHT = 0b0001,
	DOWN = 0b0010,
	LEFT = 0b0100,
	UP = 0b1000,
}
