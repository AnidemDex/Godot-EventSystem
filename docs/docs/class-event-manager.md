---
description: Base class for all event manager nodes.
---

# EventManager

Inherits: Node

## Description <a href="description" id="description"></a>

EventManager executes the event behaviour, and manages the event order execution.


## Propiedades <a href="properties" id="properties"></a>

| Type                          | Name              | Default Value                                       |
| ----------------------------- | ----------------- | --------------------------------------------------- |
| NodePath                      | event\_node\_fallback\_path | `NodePath(`<mark style="color:red;">`"."`</mark>`)` |
| bool                          | start\_on\_ready  | <mark style="color:red;">`false`</mark>             |
| [Timeline](class-timeline.md) | timeline          | <mark style="color:red;">`null`</mark>              |

## Methods <a href="methods" id="methods"></a>

| Tipo | Nombre                |
| ---- | --------------------- |
| void | start\_timeline()     |
| void | go\_to\_next\_event() |

## Signals <a href="signals" id="signals"></a>

* custom\_signal(String data)
* event\_started(Event event)
* event\_finished(Event event)
* timeline\_started(Timeline timeline)
* timeline\_finished(Timeline timeline)

## Property Descriptions <a href="property_descriptions" id="property_descriptions"></a>

### NodePath event\_node\_path <a href="property_event_node_path" id="property_event_node_path"></a>

This is the node were events are going to be applied. This node is used if the event doesn't define an `event node path` and is relative to the current scene node root.

### bool start\_on\_ready <a href="property_start_on_ready" id="property_start_on_ready"></a>

If is `true`, the node will call [`start_timeline`](class-event-manager.md#void-start\_timeline-timeline-timeline\_resource-timeline) when the scene tree is ready.

### [Timeline](class-event-manager.md#timeline-timeline) timeline <a href="property_timeline" id="property_timeline"></a>

The timeline resource that is going to be used when [`start_timeline`](class-event-manager.md#void-start\_timeline-timeline-timeline\_resource-timeline) is called.

## Method descriptions <a href="method_descriptions" id="method_descriptions"></a>

### void start\_timeline(Timeline timeline\_resource=timeline) <a href="method_start_timeline" id="method_start_timeline"></a>

Starts the event sequence. This method must be called to start EventManager process.

If you pass a `timeline_resource`, [`timeline`](class-event-manager.md#timeline-timeline) will be assigned to this value.

### void go\_to\_next\_event() <a href="method_go_to_next_event" id="method_go_to_next_event"></a>

Advances to the next event.
