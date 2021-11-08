---
description: Clase base para el nodo gestor de eventos.
---

# EventManager

Hereda: Node

## Descripción <a href="description" id="description"></a>

EventManager es el nodo encargado de ejecutar timelines, así como de gestionar su avance o retroceso y las condiciones para avanzar o retroceder en la secuencia de eventos.

{% hint style="info" %}
Actualmente solo es posible ir hacia adelante en la secuencia de eventos. Añadir la capacidad de ir hacia adelante y hacia atrás en la secuencia es algo que solamente está contemplado.
{% endhint %}

## Propiedades <a href="properties" id="properties"></a>

| Tipo                          | Nombre            | Valor por defecto                                   |
| ----------------------------- | ----------------- | --------------------------------------------------- |
| NodePath                      | event\_node\_path | `NodePath(`<mark style="color:red;">`"."`</mark>`)` |
| bool                          | start\_on\_ready  | <mark style="color:red;">`false`</mark>             |
| [Timeline](class-timeline.md) | timeline          | <mark style="color:red;">`null`</mark>              |

## Métodos <a href="methods" id="methods"></a>

| Tipo | Nombre                |
| ---- | --------------------- |
| void | start\_timeline()     |
| void | go\_to\_next\_event() |

## Señales <a href="signals" id="signals"></a>

* custom\_signal(String data)
* event\_started(Event event)
* event\_finished(Event event)
* timeline\_started(Timeline timeline)
* timeline\_finished(Timeline timeline)

## Descripción de propiedades <a href="property_descriptions" id="property_descriptions"></a>

### NodePath event\_node\_path <a href="property_event_node_path" id="property_event_node_path"></a>

El nodo al que se le van a aplicar los eventos. Escoger el nodo es obligatorio, pues es la única referencia que tendrán los eventos para saber donde serán ejecutados.

### bool start\_on\_ready <a href="property_start_on_ready" id="property_start_on_ready"></a>

Si es `true` , el nodo llamará [`start_timeline`](class-event-manager.md#void-start\_timeline-timeline-timeline\_resource-timeline) en cuanto esté listo en el árbol de la escena.

### [Timeline](class-event-manager.md#timeline-timeline) timeline <a href="property_timeline" id="property_timeline"></a>

La secuencia que usará el nodo cuando [`start_timeline`](class-event-manager.md#void-start\_timeline-timeline-timeline\_resource-timeline) sea llamado.

## Descripción de métodos <a href="method_descriptions" id="method_descriptions"></a>

### void start\_timeline(Timeline timeline\_resource=timeline) <a href="method_start_timeline" id="method_start_timeline"></a>

Inicia la secuencia. Este método debe ser llamado para empezar el proceso normal del EventManager.

Si se pasa un `timeline_resource`, la propiedad [`timeline`](class-event-manager.md#timeline-timeline) será asignado a este valor.

### void go\_to\_next\_event() <a href="method_go_to_next_event" id="method_go_to_next_event"></a>

Avanza al siguiente evento.
