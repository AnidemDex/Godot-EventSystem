---
description: Clase base para todos los recursos Timeline
---

# Timeline Resource

**Hereda:** Resource

## Descripción

Un timeline es un contenedor de datos sobre los eventos.

Este recurso solo se encarga de mantener una referencia ordenada a los eventos registrados en ella, así como una fila temporal de eventos que aun no han sido usados.&#x20;

Algo similar a una lista con eventos, pero con pasos extra y una pizca de paprika.

## Propiedades

| Tipo                    | Nombre      | Valor por defecto                      |
| ----------------------- | ----------- | -------------------------------------- |
| [Event](class-event.md) | last\_event | <mark style="color:red;">`null`</mark> |
| [Event](class-event.md) | next\_event | <mark style="color:red;">`null`</mark> |

## Métodos

| Type  | Name                                                              |
| ----- | ----------------------------------------------------------------- |
| void  | initialize( )                                                     |
| void  | add\_event ( [Event ](class-event.md)event, int at\_position=-1 ) |
| void  | erase\_event( [Event ](class-event.md)event )                     |
| void  | remove\_event ( int position )                                    |
| Array | get\_events( )                                                    |
| Event | get\_next\_event( )                                               |
| bool  | can\_loop( )                                                      |
| Event | get\_previous\_event( )                                           |

## Descripción de las propiedades

### [Event ](class-event.md)last\_event <a href="property_last_event" id="property_last_event"></a>

El ultimo evento usado según la fila temporal.

### Event next\_event <a href="property_next_event" id="property_next_event"></a>

El siguiente evento a usar según la fila temporal. (Es el candidato mas probable a ser usado cuando se hace la llamada a `get_next_event()`.&#x20;

## Descripción de los métodos

### void initialize() <a href="method_initialize" id="method_initialize"></a>

Inicia la fila temporal de eventos. La fila es usada por los métodos [`get_next_event`](class-timeline.md#event-get\_next\_event) y [`get_previous_event`](class-timeline.md#undefined). Si estás implementando tu propio gestor de eventos, es una buena llamar a esta función primero antes de tratar con el timeline directamente.

### void add\_event(Event event, int at\_position=-1) <a href="method_add_event" id="method_add_event"></a>

Añade el evento `event` en a la lista de eventos en la posición escogida. El valor por defecto -1 indica que será añadido al final de la lista.

### void erase\_event(Event event) <a href="method_erase_event" id="method_erase_event"></a>

Elimina un evento de la lista de eventos. Similar al uso de la función `Array.erase()`

### void remove\_event(int position) <a href="method_remove_event" id="method_remove_event"></a>

Elimina un evento de la lista de eventos en la posición `position`. Similar al uso de la función `Array.remove()`.

### Array get\_events() <a href="method_get_events" id="method_get_events"></a>

Devuelve la lista interna de los eventos registrados en el recurso. La lista retornada es una copia, por lo que modificaciones a la misma no afectarán a la lista original.&#x20;

Modificaciones a los eventos internos de la lista si afectarán a los eventos originales.

### Event get\_next\_event() <a href="method_get_next_event" id="method_get_next_event"></a>

Devuelve el siguiente evento en cola o null en caso de que no haya ninguno. El metodo [initilize](class-timeline.md#void-initialize) debe llamarse una sola vez antes de usar esta función

### bool can\_loop() <a href="method_can_loop" id="method_can_loop"></a>

### Event get\_previous\_event() <a href="method_get_previous_event" id="method_get_previous_event"></a>
