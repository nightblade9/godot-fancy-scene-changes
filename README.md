# Fancy Scene Changes for Godot

Fancy shader effects to cross-fade between two scenes in Godot. Ships with a couple of samples, easily customizable with a simple black-and-white image.

# Usage

- Add `addons/transitions/Transitions.gd` as a autoload singleton script to your project
- Call `Transitions.change_scene` with appropriate parameters

For examples, see `ManualTransitions1.tscn` and `ManualTransitions2.tscn` in this repo.

# Currently supported fades

## Blend

Transitions between two scenes, using a black-and-white image as a mask. As time goes by, the pixels become transparent and show the underlying scene, starting from black. For example images, see `addons/transitions/images`.

Code:

```gdscript
const DISSOLVE_IMAGE = preload('res://addons/transitions/images/blurry-noise.png')
Transitions.change_scene(ManualTest2.instance(), Transitions.FadeType.Blend, 1.5, DISSOLVE_IMAGE)
```

Blend uses a transition with a noisy texture:

![](previews/blend-noise.gif)

Blend transition with a conical gradiant texture:

![](previews/blend-conical.gif)

Blend using a brush texture:

![](previews/brush-fade.gif)

## CrossFade

Fades one screen directly into another.

Code:

```gdscript
Transitions.change_scene(ManualTest1.instance(), Transitions.FadeType.CrossFade, 1)
```

![](previews/crossfade.gif)

# Credits

- [Horizontal Paint Brush Wipe](https://store.kde.org/p/1675120) image by Kdenlive Lumas, via KDE Store