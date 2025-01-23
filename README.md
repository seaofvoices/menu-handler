[![checks](https://github.com/seaofvoices/menu-handler/actions/workflows/test.yml/badge.svg)](https://github.com/seaofvoices/menu-handler/actions/workflows/test.yml)
![version](https://img.shields.io/github/package-json/v/seaofvoices/menu-handler)
[![GitHub top language](https://img.shields.io/github/languages/top/seaofvoices/menu-handler)](https://github.com/luau-lang/luau)
![license](https://img.shields.io/npm/l/@crosswalk-game/menu-handler)
![npm](https://img.shields.io/npm/dt/@crosswalk-game/menu-handler)

# MenuHandler

A [crosswalk](https://github.com/seaofvoices/crosswalk) client module to handle UI menus using tagged instances (built with the [tag-effect library](https://github.com/seaofvoices/tag-effect)).

## Installation

Add `@crosswalk-game/menu-handler` in your dependencies:

```bash
yarn add @crosswalk-game/menu-handler
```

Or if you are using `npm`:

```bash
npm install @crosswalk-game/menu-handler
```

## Content

- [open](#openmenuid-string)
- [push](#pushmenuid-string)
- [back](#back)
- [close](#closemenuid-string)
- [toggle](#togglemenuid-string)
- [whileOpened](#whileopenedmenuid-string-effect----teardown----)

- [Tag effects](#tag-effects)
  - [MenuInstance of MenuExtension](#menuinstance-or-menuextension)
  - [Menu Navigation](#menu-navigation)

### `open(menuId: string)`

- **Description**: Opens the menu with the specified ID. Closes any menu that are not explicitly marked as compatible with the ID.

- **Parameters**:
  - `menuId`: The unique identifier of the menu to open.

### `push(menuId: string)`

- **Description**: Similar to the `open` function: it opens the menu with the specified ID and closes any menu that are not explicitly marked as compatible with the ID.

Additionally, it saves the current menu state into the history stack before opening the new one. Calling [`back`](#back) will return to that state.

- **Parameters**:
  - `menuId`: The unique identifier of the menu to open.

### `back()`

- **Description**: Go back to the previous menu state from the history stack. State is added in the history stack when calling [`push`](#pushmenuid-string).

### `close(menuId: string)`

- **Description**: Closes the menu with the specified ID.

- **Parameters**:
  - `menuId`: The unique identifier of the menu to close.

### `toggle(menuId: string)`

- **Description**: Toggles the state (open/close) of the menu with the specified ID.

- **Parameters**:
  - `menuId`: The unique identifier of the menu to toggle.

### `whileOpened(menuId: string, effect: () -> Teardown): () -> ()`

- **Description**: Executes the specified effect while the menu with the specified ID is open. The effect will automatically be cleaned up when the menu is closed.

- **Parameters**:

  - `menuId`: The unique identifier of the menu to target.
  - `effect`: The effect to execute while the menu is open. This function return any kind of [teardown object](https://github.com/seaofvoices/luau-teardown) (for example: `nil`, a cleanup function or event connections) that will automatically get cleaned up when the menu is closed.

- **Returns**: A function to remove the effect.

## Tag Effects

This module defines a series of [tag-effects](https://github.com/seaofvoices/tag-effect) to define menus (that can be opened or closed) or buttons to open, close or toggle those menus.

### `MenuInstance` or `MenuExtension`

_Allowed instance class: [`GuiObject`](https://robloxapi.github.io/ref/class/GuiObject.html), [`LayerCollector`](https://robloxapi.github.io/ref/class/LayerCollector.html), [`ProximityPrompt`](https://robloxapi.github.io/ref/class/ProximityPrompt.html), [`BoolValue`](https://robloxapi.github.io/ref/class/BoolValue.html)_

Those two tag-effects are used to define a new menu with the given `id`. The difference between a `MenuInstance` and a `MenuExtension` is how they influence other menus:

- when a `MenuInstance` is opened, __all other `MenuInstance` will be closed__ (except other `MenuInstance` objects explicitly marked as compatible with the opened menu `id`)
- when a `MenuExtension` is opened, it does not change other `MenuInstance` or `MenuExtension` objects

Both tag-effects have the same base configuration:

__Configuration:__
- `id` (string): identifier for the menu

_Optional:_
- `defaultState` (boolean): define if the menu is visible (or not) by default

Optionally, the `MenuInstance` tag effect can also be configured to mark other menus as compatible with itself, by adding string attributes set to other compatible menu `id`. For example, one could add an attribute `compatibleWithStore = "Store"`, where `Store` would be another `MenuInstance` `id`.

### Menu Navigation

There are various tags to navigate through menus: `OpenMenu`, `PushMenu`, `BackMenu`, `CloseMenu` and `ToggleMenu`.

These tag-effects can be used bind a signal to open, close or toggle a menu. They can be applied to any kind of instances:

- [`GuiButton`](https://robloxapi.github.io/ref/class/GuiButton.html): which will trigger on the `Activated` event
- [`ClickDetector`](https://robloxapi.github.io/ref/class/ClickDetector.html): which will trigger on the `MouseClick` event
- [`ProximityPrompt`](https://robloxapi.github.io/ref/class/ProximityPrompt.html): which will trigger on the `Triggered` event
- Any other instance, if the `eventName` attribute is set to an appropriate event name

__Configuration:__
- `id` (string): identifier of the menu that needs to be opened/pushed/closed/toggled. (**excepted** for `BackMenu`, this field is required)

_Optional:_
- `eventName` (string): specify which signal to use to bind the behavior

## License

This project is available under the MIT license. See [LICENSE.txt](LICENSE.txt) for details.
