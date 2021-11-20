# Installing EventSystem

{% hint style="info" %}
If you want more information about installing plugins in Godot, please check the [official documentation](https://docs.godotengine.org/es/stable/tutorials/plugins/editor/installing\_plugins.html).
{% endhint %}

## Download

There are several options for downloading the plugin. The method you use will only influence the version to be downloaded.

### Option A: Stable version from the repository

![Option A](../.gitbook/assets/tutorial\_option\_a.png)

Download the latest stable version released from the repository.

![](../.gitbook/assets/tutorial\_option\_a\_1.png)

Click on `EventSystem_v?.zip` where `?` will be the version number. It will start downloading a compressed file, which contains the plugin files.

### Option B: Latest untested version from the repository

![Option B](../.gitbook/assets/tutorial\_option\_b.png)

{% hint style="warning" %}
This type of version is often referred to by a name similar to _neutral version_, and refers to versions that are on the current state of version control.

This does not mean that it is working or usable. If the current state of the repository included some change that caused the plugin to start crashing, neutral version will also crash.
{% endhint %}

This download allows you to download an untested version from the repository, which is with the latest features added to the plugin (again, still untested). It is not recommended for use.

### Opción C: Versión estable desde AssetLib

{% hint style="info" %}
The plugin is not yet added to the Godot AssetLib. This section of the documentation will be updated when that happens.
{% endhint %}

## Installation

The installation of the plugin may vary depending on the option you chose to download the plugin.

### Option A and B

![](../.gitbook/assets/tutorial\_installing\_from\_zip.png)

Extract the `addons` folder to the root of the folder where your project is located.

## Enable the plugin

In the project settings, in the `Plugin` tab check the `Enable` box.

![](../.gitbook/assets/tutorial\_enabling.png)
