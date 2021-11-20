# Usando el nodo EventManager

El nodo EventManager es quien va a hacer la labor de gestionar tu secuencia (Timeline), ejecutando los eventos según las condiciones que le des.

Por defecto, todos los eventos vienen con una opción de autoavance: `continue_at_end`; si ese valor es verdadero, en el instante en que el evento emita su señal `event_finished`, el gestor de eventos ejecutará el siguiente evento automáticamente. En caso contrario, `continue_at_end` es falso, el gestor de eventos esperará a que su metodo `go_to_next_event` sea llamado para ejecutar el siguiente evento en la lista.

