# Making a custom event

Events are the code fragments that the EventManager will execute, contained in a sequence (Timeline)..

By default the plugin includes some events that correspond to tasks commonly performed in code: making a comment, a boolean check, setting a variable to a certain value, among others.

You can create and add your own events to this system without much trouble, which gives you the ability to execute your own code snippets under your own rules.

{% hint style="info" %}
So far I have come up with the idea of creating a rhythm core, a Pokémon-style battle interaction and a [dialogue system](https://app.gitbook.com/o/ANe5SjHDLnAFjCnVwR4d/s/-MaUroYBpPsgfLKIUmns/). You can replicate this and more!
{% endhint %}

## Event's structure

![](../.gitbook/assets/EventBehaviour.png)

Here you can see the structure of how is (more or less) the logic used after the execution of an event:

1. EventManager starts the sequence.&#x20;
2. EventManager executes an event.
3. The event emits the signal `event_started`.
4. The event calls your `execute()` function.
5. EventManager waits for the `event_finished` signal to know to continue with the next event.

The process is repeated until there are no more events in the sequence.

## Make a script

The script will be the heart of your event. What you put in it will be exactly what will be executed in the game.

Custom events are a script that extend [`Event`](../docs/class-event.md) and overwrite the function [`_execute()`](../docs/class-event.md#void-\_execute), indicating that they ended up calling the function [`finish()`](../docs/class-event.md#void-finish).

### Example

Let's create an event that prints "Hello everyone!" (the classic _hello world_):

{% code title="res://evento_ejemplo.gd" %}
```gdscript
# The script must inherit from Event or
# any subclass that inherits from it.
extends Event
# you can give it a class_name if you want

# Overwrite _execute() method
# It will be called when EventManager arrives at this event.
func _execute() -> void:
    # Here will be the body of our event.
    # Whatever you want to happen, define it in this function
    print("¡Hola a todos!")
    
    # Notify that your event is done and can continue to
    # the next event.
    finish()
```
{% endcode %}

Para usar tu recién creado evento (por medio de código) solo debes hacer esto:

```gdscript
# Creates a sequence
var timeline := Timeline.new()
# or use one you have already created
timeline = load("res://path/to/timeline.tres") as DialogTimelineResource

# Load your event script
var event_script := load("res://evento_ejemplo.gd")

# And create a new instance of your event
var event := event_script.new() as Event

# Now add your event to the timeline
timeline.add_event(event)

# Finally, start the timeline sequence

# Assuming that "event_manager" is an EventManager
# node in the scene
event_manager.start_timeline(timeline)
```
