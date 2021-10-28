tool
extends Resource
class_name EventResource

## 
## Base class for all events.
##
## @desc: 
##    Every event relies on this class. 
##    If you want to do your own event, you should [code]extend[/code] this class.
##

## Emmited when the event starts.
## The signal is emmited with the event resource [code]event_resource[/code]
signal event_started(event_resource)

## Emmited when the event finish. 
## The signal is emmited with the event resource [code]event_resource[/code]
## and a bool value [code]jump_to_next_event[/code]
signal event_finished(event_resource)


## Executes the event behaviour.
func execute() -> void:
	pass


## Ends the event behaviour.
func finish() -> void:
	pass


func _execute() -> void:
	pass
