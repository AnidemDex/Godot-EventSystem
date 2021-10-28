class_name EventNode

## Collection of fake nodes
## @desc: Fake nodes used as helper nodes to implement EventNodes

class FakeNode extends Node:
	func execute_event(event, EventPlayer_Path) -> void:
		event.set("EventPlayer_Path", EventPlayer_Path)
		event.call("execute")


class FakeControl extends Control:
	func execute_event(event, EventPlayer_Path) -> void:
		event.set("EventPlayer_Path", EventPlayer_Path)
		event.call("execute")


class FakeNode2D extends Node2D:
	func execute_event(event, EventPlayer_Path) -> void:
		event.set("EventPlayer_Path", EventPlayer_Path)
		event.call("execute")


class FakeSpatial extends Spatial:
	func execute_event(event, EventPlayer_Path) -> void:
		event.set("EventPlayer_Path", EventPlayer_Path)
		event.call("execute")
