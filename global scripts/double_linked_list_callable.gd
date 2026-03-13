class_name DoubleLinkedListCallable extends RefCounted
## Double linked list implementation for Callable type.

var _first: Item
var _last: Item
var _size: int


func _init() -> void:
	_first = null
	_last = null
	_size = 0


## Appends an element at the end of the list.
func push_back(callable: Callable) -> void:
	var item: Item = Item.new(callable)
	if is_empty():
		_first = item
		_last = item
	else:
		_last.next_item = item
		item.previos_item = _last
		_last = item

	_size += 1


## Removes and returns the first element of the array. Throws an error if the list is empty.
func pop_front() -> Callable:
	assert(not is_empty(), "The list is empty")

	var item: Item = _first
	if _first == _last:
		_first = null
		_last = null
	else:
		_first = item.next_item
		_first.previos_item = null

	_size -= 1
	return item.value


## Returns size of the list.
func size() -> int:
	return _size


## Returns [code]true[/code] if the list is empty.
func is_empty() -> bool:
	return _size == 0


class Item:

	var value: Callable
	var previos_item: Item
	var next_item: Item


	func _init(callable: Callable) -> void:
		value = callable
		previos_item = null
		next_item = null
