# Stickman: The New Gen

A 2D side-scrolling action game built with **Godot 4.5**, featuring a custom C++ GDExtension plugin, a rich enemy roster, multiple handcrafted levels, and a full save system.

---

## Gameplay Overview

You play as a knight battling through four distinct worlds — a post-apocalyptic desert, an urban wasteland, a jungle, and a final fortress — against waves of enemies ranging from shambling zombies to mythological creatures. Each world has its own hand-drawn art and original music track.

---

## Features

- **State-machine driven AI** — Enemies patrol, detect the player, chase, and attack using a modular C++ state machine implemented as a GDExtension plugin.
- **Playable characters** — Knight, each with their own sprite animations for idle, walk, run, jump, attack.
- **4 handcrafted levels** with parallax backgrounds and unique music:
  - First Map — post-apocalyptic desert under a moonlit sky
  - Second Map — abandoned urban street with birds and ruined buildings
  - Third Map — dense jungle with fireflies and lianas
  - Final Map — a fortress battleground with dragons, columns, and candelabras
- **Enemy roster** — Zombies, Gorgons, Minotaurs, Satyrs, Yokais, and an Evil Wizard, each with 2–3 colour/difficulty variants and full animation sets (idle, walk, run, attack, hurt, dead, and special moves).
- **Save system** — 3 independent save slots with level-progress tracking, persistent across sessions.
- **HUD** — Player health bar, boss health bar, and damage-number popups.
- **Pause menu** with resume and quit options.
- **Scene transition system** with animated level transitions.
- **Hit VFX** — Separate impact effects for head, body, and leg hits.

---

## Controls

| Action | Key |
|---|---|
| Move Left / Right | `A` / `D` |
| Jump | `Space` |
| Strong Attack | `Y` |
| Weak Attack | `H` |
| Pause | `Escape` |

---

## Project Structure

```
Stickman-The_New_Gen/
├── src/                    # C++ GDExtension source (state machine, damageable, hit state)
├── test_project/           # Main Godot project
│   ├── 00_global/          # Autoloads: SceneManager, PlayerHud, SaveManager, PauseMenu
│   ├── PNG files/          # All sprite sheets and backgrounds
│   │   ├── Aku/            # Player character sprites
│   │   ├── Knight_1/       # Knight character sprites
│   │   ├── Villain_char/   # Enemy sprites (Zombie, Gorgon, Minotaur, Satyr, Yokai, Wizard)
│   │   ├── First_map/ … Final_map/   # Level backgrounds
│   │   ├── ImpactEffects/  # Hit VFX
│   │   └── InputIcons/     # On-screen button prompts
│   ├── audio/music/        # Per-level OGG music tracks + menu/dead-state music
│   ├── Zombie/             # Zombie scene files
│   ├── Second_villain/     # Secondary enemy scenes
│   └── test_plugin/        # Compiled GDExtension binary
├── tools/                  # Build helper scripts
└── SConstruct              # SCons build file for the C++ plugin
```

---

## Building the C++ Plugin

The game uses a GDExtension plugin built with **SCons** and **godot-cpp**.

**Prerequisites**

- Python 3.6+
- SCons (`pip install scons`)
- A C++17-capable compiler (MSVC, GCC, or Clang)
- The `godot-cpp` submodule (run `git submodule update --init` after cloning)

**Build**

```bash
# Debug build
python tools/compile_debug_build.py

# Or directly with SCons
scons platform=windows target=template_debug   # Windows
scons platform=linux   target=template_debug   # Linux
scons platform=macos   target=template_debug   # macOS
```

The compiled library is output to `test_project/test_plugin/`.

---

## Running the Game

1. Clone the repository and initialise submodules:
   ```bash
   git clone https://github.com/neer-soni/Stickman-The_New_Gen.git
   cd Stickman-The_New_Gen
   git submodule update --init
   ```
2. Build the C++ plugin (see above).
3. Open **Godot 4.5** and import `test_project/project.godot`.
4. Press **F5** or click **Run** to start.

---

## Tech Stack

| Technology | Role |
|---|---|
| Godot 4.5 | Game engine |
| GDScript | Gameplay logic, UI, AI states |
| C++ / GDExtension | Core state machine, damage system |
| SCons | Plugin build system |
| godot-cpp | C++ bindings for Godot |
| OpenGL Compatibility | Renderer (supports low-end hardware) |

---

## License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

Copyright © 2026 neer-soni
