# Creando un evento

Los eventos son los fragmentos de código que el EventManager ejecutará, contenidos en una secuencia (Timeline).

Por defecto el plugin incluye algunos eventos que corresponden a tareas realizadas comúnmente en código: hacer un comentario, una comprobación booleana, establecer una variable a cierto valor, entre otros.

Puedes crear y añadir tus propios eventos a este sistema sin mayor problema, lo que te da la capacidad de ejecutar tus propios fragmentos de código bajo tus propias reglas.

{% hint style="info" %}
Hasta el momento se me ha ocurrido la idea de crear un núcleo de ritmo, una interacción de batalla estilo Pokémon y un [sistema de dialogo](https://app.gitbook.com/o/ANe5SjHDLnAFjCnVwR4d/s/-MaUroYBpPsgfLKIUmns/) usando este plugin. ¡Tu puedes replicar esto y mas!
{% endhint %}

## Estructura de un evento

![](../.gitbook/assets/EventBehaviour.png)

Aquí puedes ver la estructura de como es (mas o menos) la lógica empleada tras la ejecución de un evento:

1. EventManager inicia la secuencia.&#x20;
2. EventManager ejecuta un evento.
3. El evento emite la señal `event_started`.
4. El evento llama a su función `execute()`.
5. EventManager espera la señal `event_finished` para saber que debe continuar con el siguiente evento.

El proceso se repite hasta que no hay más eventos en la secuencia.

## Crea un script

El script será el corazón de tu evento. Lo que pongas en él será exactamente lo que se ejecutará en el juego.

Los eventos personalizados son un script que extienden [`Event`](../docs/class-event.md) y sobreescriben la función [`_execute()`](../docs/class-event.md#void-\_execute), indicando que acabaron llamando a la función [`finish()`](../docs/class-event.md#void-finish).

### Ejemplo

Creemos un evento que imprima "¡Hola a todos!" (el clásico _hola mundo_):

{% code title="res://evento_ejemplo.gd" %}
```gdscript
# El script debe heredar de Event o cualquier subclase que
# herede de la misma.
extends Event
# you can give it a class_name if you want

# Sobreescribe el metodo _execute()
# Será llamado cuando EventManager llegue a este evento.
func _execute() -> void:
    # Aqui irá el cuerpo de nuestro evento.
    # Lo que sea que quieras que pase, definelo en esta función
    print("¡Hola a todos!")
    
    # Notify that your event is done and can continue to
    # the next event.
    finish()
```
{% endcode %}

Para usar tu recién creado evento (por medio de código) solo debes hacer esto:

```gdscript
# Crea una secuencia
var timeline := Timeline.new()
# o usa una que ya habias creado
timeline = load("res://path/to/timeline.tres") as DialogTimelineResource

# Carga el script de tu evento
var event_script := load("res://evento_ejemplo.gd")

# Y crea una nueva instancia de tu evento
var event := event_script.new() as Event

# Ahora añade tu evento al timeline
timeline.add_event(event)

# Finalmente, inicia la secuencia de timeline

# Asumiendo que "event_manager" es un nodo EventManager
# en la escena
event_manager.start_timeline(timeline)
```
