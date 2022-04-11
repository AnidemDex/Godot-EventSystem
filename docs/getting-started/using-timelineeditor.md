# Using the Event Editor

![Event Editor](../.gitbook/assets/timeline.png)

The event editor is a visual tool for editing any Timeline event sequence as well as the events contained in it.

The event editor consists of 3 essential parts for modifying Timeline event sequences:

1. The event buttons
2. The event list
3. The events

**The event editor appears when you select an `EventManager` node, and can be edited if that node has a proper `Timeline` resource.**

## Event buttons

![](../.gitbook/assets/event\_buttons\_toolbar.png)

Press a button to add the event to the sequence. The event will be added under the selected event or at the end of the queue.

![](../.gitbook/assets/tutorial\_timeline\_buttons.gif)

Holding the mouse over the button allows you to see its description.

![](../.gitbook/assets/tutorial\_timeline\_buttons\_hover.gif)

You can drag a button to generate an event that you can drop in the event list to add it at any position.

![](../.gitbook/assets/tutorial\_timeline\_buttons\_drag\&drop.gif)

## Event list

![](../.gitbook/assets/timeline\_with\_events.png)

The event list shows all events contained in the Timeline.

You can drag and drop any event from its name to rearrange or delete it.

![](../.gitbook/assets/tutorial\_timeline\_event\_drag\&drop.gif)



## Events

Event nodes are a visual representation of any event. Their structure is as follows:

![](../.gitbook/assets/event\_node.png)

Pressing an event will make its properties editable in the Godot inspector.

Selecting an event and pressing the DEL (delete) button will remove the event from the Timeline.
