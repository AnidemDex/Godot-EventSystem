---
description: Clase base para todos los eventos
---

# Event

Hereda: Resource

## Descripción <a href="description" id="description"></a>

Todos los eventos que puede contener un Timeline y pueden ser ejecutados por EventManager dependen de esta clase.

## Propiedades <a href="properties" id="properties"></a>

| Tipo         | Nombre            | Valor por defecto |
| ------------ | ----------------- | ----------------- |
| bool         | continue\_at\_end | true              |
| Node         | event\_node       | null              |
| EventManager | event\_manager    | null              |

## Métodos <a href="methods" id="methods"></a>

| Tipo | Nombre      |
| ---- | ----------- |
| void | \_execute() |
| void | execute()   |
| void | finish()    |

## Señales <a href="signals" id="signals"></a>

* event\_started(event\_resource)
* event\_finished(event\_resource)

## Descripción de propiedades <a href="property_descriptions" id="property_descriptions"></a>

### bool continue\_at\_end <a href="property_continue_at_end" id="property_continue_at_end"></a>

Si es verdadero, el EventManager que ejecuta este evento ejecutará el siguiente evento en el momento en que este evento termine.

### Node event\_node <a href="property_event_node" id="property_event_node"></a>

El nodo al cual le será aplicado el evento. Todas las variables que modifique el evento serán relativos a este nodo.

### EventManager event\_manager <a href="property_event_manager" id="property_event_manager"></a>

El nodo EventManager que administra este evento. El nodo es asignado automaticamente.

## Propiedades del evento

{% hint style="info" %}
Las siguientes son propiedades que se usan con el editor de eventos.

Cambiar su valor en juego no afecta su funcionamiento.
{% endhint %}

Si quieres crear eventos personalizados, debes cambiar sus valores en su constructor `_init()`

### Texture event\_icon

El icono de el evento mostrado en el editor.

### Color event\_color

El color del evento usado en el editor.

### String event\_name

El nombre del evento mostrado en el editor.

### String event\_preview

Una cadena de texto que se mostrará junto al nombre del evento en el editor.

Puedes poner propiedades del evento entre los caracteres { y } para mostrarlas en el editor.

Si escribes:

```coffeescript
event_preview_string = "{resource_name}"
```

La vista previa mostrada será el nombre del recurso en lugar de `{resource_name}`.

### String event\_hint

Representa la descripción del evento. Es buena idea mantener esta descripción corta.

### String event\_category

Representa la categoría a la que pertenece este evento.

## Descripción de métodos

### void \_execute() <a href="method_descriptions" id="method_descriptions"></a>

Es llamado cuando se ejecuta el evento.

Este método debe ser sobrescrito si se planea crear un evento personalizado.

No debe ser llamado directamente.

### void execute() <a href="method-execute" id="method-execute"></a>

Ejecuta el evento.

Este método no debe ser sobrescrito si se planea crear un evento personalizado.

### void finish() <a href="method-finish" id="method-finish"></a>

Debe ser llamado al completar el evento para indicar que el evento ha finalizado.

## Propiedades opcionales

Propiedades usadas como pistas para el editor de eventos

\<property>\_ignore

branch\_disabled

custom\_event\_node
