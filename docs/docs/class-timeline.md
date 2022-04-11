---
description: Base class for all Timelines
---

# Timeline Resource

**Inherits:** Resource

## Description <a href="description" id="description"></a>

A timeline is an event container.

This resource only keeps an ordered reference of all events registered on it.

## Properties <a href="properties" id="properties"></a>

| Type                    | Name                                                 | Default Value                      |
| ----------------------- | ------------------------------------------------------ | -------------------------------------- |
| [Event](class-event.md) | [last\_event](class-timeline.md#property\_last\_event) | <mark style="color:red;">`null`</mark> |
| [Event](class-event.md) | [next\_event](class-timeline.md#property\_next\_event) | <mark style="color:red;">`null`</mark> |

## Methods <a href="methods" id="methods"></a>

| Type                    | Name                                                                                                    |
| ----------------------- | --------------------------------------------------------------------------------------------------------- |
| void                    | [initialize](class-timeline.md#method\_initialize)( )                                                     |
| void                    | [add\_event ](class-timeline.md#method\_add\_event)( [Event ](class-event.md)event, int at\_position=-1 ) |
| void                    | [erase\_event](class-timeline.md#method\_erase\_event)( [Event ](class-event.md)event )                   |
| void                    | [remove\_event ](class-timeline.md#method\_remove\_event)( int position )                                 |
| Array                   | [get\_events](class-timeline.md#method\_get\_events)( )                                                   |
| [Event](class-event.md) | [get\_next\_event](class-timeline.md#method\_get\_next\_event)( )                                         |
| bool                    | [can\_loop](class-timeline.md#method\_can\_loop)( )                                                       |
| [Event](class-event.md) | [get\_previous\_event](class-timeline.md#method\_get\_previous\_event)( )                                 |

## Property Descriptions <a href="property_descriptions" id="property_descriptions"></a>

### [Event ](class-event.md)last\_event <a href="property_last_event" id="property_last_event"></a>

Deprecated.

### [Event ](class-event.md)next\_event <a href="property_next_event" id="property_next_event"></a>

Deprecated. Use the current event `next_event` property instead.

## Method descriptions <a href="method_descriptions" id="method_descriptions"></a>

### void initialize() <a href="method_initialize" id="method_initialize"></a>

Deprecated.

### void add\_event(Event event, int at\_position=-1) <a href="method_add_event" id="method_add_event"></a>

Adds the event at the event queue. If `at_position` is `-1` it'll be added at the end of the queue.

### void erase\_event(Event event) <a href="method_erase_event" id="method_erase_event"></a>

Removes an event from event queue. Similar to `Array.erase()`

### void remove\_event(int position) <a href="method_remove_event" id="method_remove_event"></a>

Removes an event from event queue at `position`. Similar to `Array.remove()`

### Array get\_events() <a href="method_get_events" id="method_get_events"></a>

Returns a copy of the internal queue list. Modifying this list will not modify the original list, but modifying the resources contained will modify the original events.

### [Event ](class-event.md)get\_next\_event() <a href="method_get_next_event" id="method_get_next_event"></a>

Deprecated.

### bool can\_loop() <a href="method_can_loop" id="method_can_loop"></a>

### [Event ](class-event.md)get\_previous\_event() <a href="method_get_previous_event" id="method_get_previous_event"></a>
Deprecated.
