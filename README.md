# HeartStakes

HeartStakes is a Minecraft Java Edition datapack that makes maximum health a shared survival stake. Death removes health, while eating an enchanted golden apple restores it.

## Download

Download the latest tested release from the [GitHub Releases page](https://github.com/sowbyspencer/HeartStakes/releases). The release asset is `HeartStakes.zip`.

## Supported Minecraft versions

The current release supports:

- Minecraft Java Edition 1.21.7
- Minecraft Java Edition 1.21.8

The datapack uses pack format `81` and the 1.21+ singular directories `function`, `advancement`, and `tags/function`.

## Install the datapack

1. Download `HeartStakes.zip` from the latest release.
2. Open the target world's `datapacks` folder. For a server, this is usually `<server>/world/datapacks`.
3. Copy the ZIP file into that folder. You can also extract it there.
4. Start or reload the world.

The installed path must contain:

```text
<world>/datapacks/HeartStakes/pack.mcmeta
```

HeartStakes works in singleplayer and multiplayer worlds. Cheats and command blocks are not required after installation.

## Features

- Each death removes 0.5 hearts, or 1 `minecraft:max_health` point.
- Maximum health cannot fall below 0.5 hearts, or 1 health point.
- An enchanted golden apple adds 1 full heart, or 2 health points.
- Health changes are tracked independently for each player.

## Run integration tests locally

The local test script downloads the pinned Fabric API, PackTest, and Fabric server dependencies, creates a temporary server directory, runs the tests, and stops the server when PackTest finishes.

Requirements:

- Windows PowerShell
- Java 21 on `PATH`
- Internet access for the first dependency download

From the repository root:

```powershell
.\scripts\run-integration-tests.ps1 -MinecraftVersion 1.21.7
.\scripts\run-integration-tests.ps1 -MinecraftVersion 1.21.8
```

Run one fixture at a time with `-TestName`:

```powershell
.\scripts\run-integration-tests.ps1 -MinecraftVersion 1.21.8 -TestName apple_reward
```

The script returns exit code `0` when the selected tests pass. It returns a nonzero exit code for failed tests or a timeout.

## CI/CD

GitHub Actions performs the following checks:

- Static validation of JSON, pack format, required files, folder names, and deprecated attribute names.
- Integration tests for all four fixtures on Minecraft 1.21.7 and 1.21.8.
- ZIP packaging and content validation.
- Tag-based GitHub Release publishing.

The full workflow plan is documented in [HeartStakes/CI_CD_PLAN.md](HeartStakes/CI_CD_PLAN.md).

## Repository layout

```text
HeartStakes/
|-- HeartStakes/                  # Released datapack
|-- tests/heartstakes-testpack/   # CI-only test datapack
|-- scripts/                      # Local test helpers
`-- .github/workflows/            # Validation, integration, packaging, and release workflows
```

The test datapack, local server directories, logs, and workflow files are not included in `HeartStakes.zip`.

## Contributing

1. Create a feature branch from `main`.
2. Make the change and run the relevant local tests.
3. Push the branch and open a pull request into `main`.
4. Wait for static validation, integration tests, and packaging checks to pass.

Changes are merged through pull requests protected by required status checks.
