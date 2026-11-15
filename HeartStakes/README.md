# HeartStakes

HeartStakes is a Minecraft Java Edition datapack using pack format 81.

## Features

- Each death removes 0.5 hearts (1 `minecraft:max_health` point).
- A player's maximum health cannot fall below 0.5 hearts (1 health point).
- Eating an enchanted golden apple adds 1 full heart (2 health points).
- Health is stored and applied through the `minecraft:max_health` base attribute.
- No command blocks, cheats, or commands are required after installation.
- Works independently for every player in multiplayer worlds and servers.

## Installation in a new world or server

1. Create or open a Java Edition survival world. Cheats and commands do not need to be enabled.
2. Stop the singleplayer world or server.
3. Open the world's `datapacks` folder. On a server, this is usually `<server>/world/datapacks`.
4. Copy the `HeartStakes` folder into that folder.
5. Start or reopen the world. The datapack loads automatically.

The final path should be:

```text
<world>/datapacks/HeartStakes/pack.mcmeta
```

## Folder layout

```text
HeartStakes/
├── pack.mcmeta
├── README.md
└── data/
    ├── minecraft/
    │   └── tags/function/
    │       ├── load.json
    │       └── tick.json
    └── heartstakes/
        ├── advancement/
        │   └── eat_enchanted_apple.json
        └── function/
            ├── load.mcfunction
            ├── tick.mcfunction
            ├── on_death.mcfunction
            └── on_eat_apple.mcfunction
```

The datapack uses the singular 1.21+ folder names `function`, `advancement`, and `tags/function`.

## CI/CD testing plan

The planned GitHub Actions validation and integration-test pipeline is documented in [CI_CD_PLAN.md](CI_CD_PLAN.md). It covers JSON and command validation, headless Minecraft tests for Java Edition 1.21.7 and 1.21.8, ZIP packaging, and tag-based release publishing.

## Supported versions

The current `pack_format: 81` officially supports Minecraft Java Edition **1.21.7 and 1.21.8**. It is not officially updated for 1.21.9 or later releases, which use newer data-pack formats and may require a compatibility update.
