# Instalar EventSystem

{% hint style="info" %}
If you want more information about installing plugins in Godot, please refer to [official documentation page](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing\_plugins.html).
{% endhint %}

## Descarga

Hay varias opciones para descargar el plugin. El método que utilices solo influirá en la versión que se va a descargar.

### Opción A: Versión estable desde el repositorio

![Opción A](../.gitbook/assets/tutorial\_option\_a.png)

Descarga la ultima versión estable lanzada desde el repositorio.

![](../.gitbook/assets/tutorial\_option\_a\_1.png)

Presiona sobre `EventSystem_v?.zip` donde `?` será el numero de la versión. Empezará la descarga de un archivo comprimido, el cual contiene los archivos del plugin.

### Opción B: Ultima versión sin probar del repositorio

![Opción B](../.gitbook/assets/tutorial\_option\_b.png)

{% hint style="warning" %}
A este tipo de versiones se les suele atribuir un nombre similar a _versión neutral_, y hace referencia a versiones que están a la par con el estado actual del control de versiones.

Esto no significa que esté funcionando o sea utilizable. Si el estado actual del repositorio incluyó algún cambio que hizo que el plugin empezase a fallar, versión neutral también fallará.
{% endhint %}

Esta descarga te permite bajar una versión sin probar del repositorio, la cual está con las ultimas características añadidas al plugin (nuevamente, aun sin probar). No se aconseja su uso.

### Opción C: Versión estable desde AssetLib

{% hint style="info" %}
El plugin aun no es añadido al AssetLib de Godot. Se actualizará esta sección de la documentación cuando eso suceda.
{% endhint %}

## Instalación

La instalación del plugin puede variar según la opción que escogiste para descargar el plugin.

### Opción A y B

![](../.gitbook/assets/tutorial\_installing\_from\_zip.png)

Extrae la carpeta `addons` a la raíz de la carpeta donde se encuentra tu proyecto.

## Habilitar el plugin

En los ajustes del proyecto, en la pestaña `Plugin` marca la casilla de `Habilitar` .

![](../.gitbook/assets/tutorial\_enabling.png)
