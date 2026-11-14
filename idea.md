Create a complete Minecraft Java Edition 1.21.7 through most current version datapack named `HeartStakes` inside the current workspace directory, including a `README.md`. Generate all required folders and files directly in the project using the exact specifications below.

### Technical Specifications

- **Target Version:** Minecraft Java Edition 1.21.7 (Singleplayer, No Cheats/Commands required)
- **Pack Format:** `81`
- **Folder Naming Convention:** Use singular folder names (`function`, `advancement`, `tags/function`) as required by Minecraft 1.21+.
- **Namespace:** `heartstakes`
- **Attribute ID:** Use `minecraft:max_health` (1 health point = 0.5 hearts; 2 health points = 1.0 full heart).

### Required Directory Structure

```text
HeartStakes/
├── pack.mcmeta
├── README.md
└── data/
    ├── minecraft/
    │   └── tags/
    │       └── function/
    │           ├── load.json
    │           └── tick.json
    └── heartstakes/
        ├── advancement/
        │   └── eat_enchanted_apple.json
        └── function/
            ├── load.mcfunction
            ├── tick.mcfunction
            ├── on_death.mcfunction
            └── on_eat_apple.mcfunction
```

### Functional Requirements

1. **`pack.mcmeta`**:
   - Set `"pack_format": 81` and provide a concise description.
2. **Function Tags (`load.json` & `tick.json`)**:
   - Register `heartstakes:load` under `minecraft:load` and `heartstakes:tick` under `minecraft:tick`.
3. **Initialization (`load.mcfunction`)**:
   - Create two scoreboard objectives:
     - `hs_deaths` with criteria `deathCount`
     - `hs_max` with criteria `dummy`
4. **Main Loop (`tick.mcfunction`)**:
   - For any player with `hs_deaths` matching `1..`, execute `heartstakes:on_death` as that player (`at @s`).
5. **Death Handler (`on_death.mcfunction`)**:
   - Store the player's current base `minecraft:max_health` into `hs_max`:
     `execute store result score @s hs_max run attribute @s minecraft:max_health base get`
   - Only if `@s hs_max` matches `2..` (at least 1.0 full heart), subtract `1` (0.5 hearts) from `@s hs_max` and apply it back via:
     `execute store result attribute @s minecraft:max_health base set 1 run scoreboard players get @s hs_max`
   - Enforce a strict minimum floor of `1` health point (`0.5` hearts) so a player at half a heart never drops to `0` health or enters a death loop.
   - Notify the player with a subtle actionbar/chat feedback message and reset `@s hs_deaths` to `0`.
6. **Enchanted Golden Apple Advancement (`eat_enchanted_apple.json`)**:
   - Trigger on `minecraft:consume_item` where `item.items` is `"minecraft:enchanted_golden_apple"`.
   - Set `"rewards": { "function": "heartstakes:on_eat_apple" }`.
7. **Apple Reward Handler (`on_eat_apple.mcfunction`)**:
   - Revoke `heartstakes:eat_enchanted_apple` from `@s` immediately so the advancement triggers every time an Enchanted Golden Apple is eaten.
   - Store the player's current base `minecraft:max_health` into `hs_max`, add `2` (1.0 full heart), and apply the updated value back to `minecraft:max_health` base.
   - Play a subtle positive sound (`minecraft:entity.player.levelup`) and show a confirmation message.
8. **`README.md`**:
   - Document features (lose 0.5 hearts on death down to a 0.5-heart minimum, gain 1.0 full heart per Enchanted Golden Apple), 1.21.7 compatibility, folder layout, and singleplayer new-world installation steps without commands/cheats enabled.

### Output Instructions

Create all directories and write the exact contents of every file cleanly without syntax errors. Do not use deprecated plural folder names (`functions`, `advancements`) or old attribute names (`generic.max_health`).
