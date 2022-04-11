---
description: Base class for all Event types
---

# Event

Inherits: Resource

## Description <a href="description" id="description"></a>

All events that a Timeline can contain and can be executed by EventManager relies on this classs.

## Properties <a href="properties" id="properties"></a>

| Type             | Name            | Default Value |
| ---------------- | ----------------- | ----------------- |
| bool             | continue\_at\_end | true              |
| NodePath         | event\_node\_path | `NodePath(`<mark style="color:red;">`"."`</mark>`)`              |
| Event            | next\_event       | null              |

## Methods <a href="methods" id="methods"></a>

| Type | Name      |
| ---- | ----------- |
| void | \_execute() |
| void | execute()   |
| void | finish()    |
| Node | get_event_node() |

## Signals <a href="signals" id="signals"></a>

* event\_started(event\_resource)
* event\_finished(event\_resource)

## Property descriptions <a href="property_descriptions" id="property_descriptions"></a>

### bool continue\_at\_end <a href="property_continue_at_end" id="property_continue_at_end"></a>

If `true`, EventManager node that is executing this event will execute the next event when this event ends.

### Node event\_node <a href="property_event_node" id="property_event_node"></a>

Deprecated. Use `get_event_node()` instead.

### EventManager event\_manager <a href="property_event_manager" id="property_event_manager"></a>

Deprecated. Use `get_event_manager_node()` instead.

## Event properties

{% hint style="info" %}
These are properties used with the timeline editor and event inspector.

Modifying its value doesn't affect their functionality.
{% endhint %}

If you want to create custom events, modify these values inside `_init()` constructor.

### Texture event\_icon

The icon used in the editor.

### Color event\_color

Event color used in the editor.

### String event\_name

Name of the event used in the editor. This is replaced by `resource_name` if any.

### String event\_preview

String used in the timeline editor, displayed next to the event name.

You can add event properties between `{}` to show them in the editor:

```coffeescript
event_preview_string = "{resource_name}"
# The editor will show the resource name instead of "{resource_name}"
```

### String event\_hint

Represents event description. Is show when you hover the event button. Is a good idea to keep it short.

### String event\_category

Represents the event category. Used by the timeline editor toolbar.

## Method descriptions

### void \_execute() <a href="method_descriptions" id="method_descriptions"></a>

Called when the event is executed by EventManager.

This method should be overwrited if you want to create a personalized event.

**Do not call this method directly**

### void execute() <a href="method_execute" id="method_execute"></a>

Executes the event.

**Do not overwrite this method if you want to create a personalized event.**

### void finish() <a href="method_finish" id="method_finish"></a>

Must be called to notify that you end this event.

## Propiedades opcionales

These properties are used as hints for editor inspector.

\<property>\_ignore

branch\_disabled

custom\_event\_node
