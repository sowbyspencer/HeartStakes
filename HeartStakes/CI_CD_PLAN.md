# HeartStakes CI/CD Integration Test Plan

This plan describes a GitHub Actions pipeline for validating and publishing the HeartStakes Minecraft Java Edition datapack.

## Run the integration tests locally

The integration workflow runs a Fabric server with the PackTest mod. It needs Java 21, `curl`, and `jq`.

From the repository root, prepare a server directory using the same download and installation commands in `.github/workflows/integration.yml`, then run:

```bash
cd ci-server
timeout --foreground --signal=TERM 90s java -Xmx2G \
  -Dpacktest.auto \
  -Dpacktest.auto.annotations \
  -jar server.jar nogui
```

PackTest exits with a status equal to the number of failed tests. A status of `0` means the suite passed. The `timeout` wrapper stops a server that remains running for 90 seconds, which makes a hang fail clearly instead of waiting for the GitHub job limit.

On Windows, run the same Java command from WSL or Git Bash after preparing `ci-server`. In PowerShell, the equivalent is:

```powershell
java -Xmx2G -Dpacktest.auto -Dpacktest.auto.annotations -jar server.jar nogui
```

The integration-test implementation uses the server-side Fabric [PackTest](https://modrinth.com/mod/packtest) mod. PackTest provides `.mcfunction` tests, assertions, dummy players, automatic test execution, and a nonzero process exit code when a test fails. The test-only datapack lives under `tests/heartstakes-testpack` and is never included in the player release ZIP.

## Goals

- Catch malformed JSON, invalid folder names, and invalid `.mcfunction` commands before release.
- Run the datapack in a real Minecraft server for behavioral integration tests.
- Test every supported Minecraft version in the compatibility matrix.
- Produce a downloadable ZIP containing the datapack.
- Publish a versioned release only after validation succeeds.

## Proposed workflow

```text
Pull request or push
        │
        ├── Static validation
        │     ├── Required-file and folder checks
        │     ├── JSON parsing
        │     ├── Pack metadata checks
        │     └── Minecraft command linting
        │
        ├── Integration test matrix
        │     ├── Minecraft Java 1.21.7
        │     └── Minecraft Java 1.21.8
        │
        ├── Package datapack ZIP
        │
        └── Publish release artifact on version tag
```

## Phase 1: Static validation

Run on every pull request and push to the default branch.

### Checks

1. Confirm that `pack.mcmeta` exists at the datapack root.
2. Confirm that `pack.mcmeta` contains `pack_format: 81`.
3. Confirm that all required files exist.
4. Reject deprecated plural directories such as `functions` and `advancements`.
5. Parse every JSON file with a strict JSON parser.
6. Check that the load and tick tags reference the expected namespace functions.
7. Check that the enchanted golden apple advancement points to `heartstakes:on_eat_apple`.
8. Run a Minecraft command linter, such as SpyglassMC, against every `.mcfunction` file.

### Failure policy

Any static validation failure blocks the integration tests and prevents packaging.

## Phase 2: Integration test datapack

Create a separate test-only datapack used by CI. Keep it outside the released `HeartStakes` folder so test helpers are never shipped to players.

The test datapack should provide test cases that load HeartStakes and verify behavior through Minecraft's Java GameTest system or an equivalent headless server harness.

### Required scenarios

Make tests first, and make sure they all fail before testing the actuall datapack. (Adhere to Test Driven Development.)

#### Initialization

- Load the world with HeartStakes enabled.
- Verify that `hs_deaths` exists with the `deathCount` criterion.
- Verify that `hs_max` exists with the `dummy` criterion.
- Verify that the HeartStakes load and tick functions are registered.

#### Death penalty

- Create a test player or controlled player state with a known `minecraft:max_health` base value.
- Trigger one death.
- Verify that the base max health decreases by 1 attribute point.
- Verify that `hs_deaths` is reset to `0` after processing.
- Verify that the actionbar feedback executes without a command error.

#### Minimum health floor

- Set the test player's base max health to 1 point.
- Trigger another death.
- Verify that the base max health remains exactly 1 point.
- Verify that the function does not repeatedly process the same death.

#### Enchanted golden apple reward

- Set a known base max health value.
- Simulate consuming an enchanted golden apple.
- Verify that the base max health increases by 2 attribute points.
- Verify that the advancement is revoked after the reward function runs.
- Consume a second enchanted golden apple and verify that it triggers again.

#### Multiplayer isolation

- Create two test players with different max health values.
- Trigger a death for only one player.
- Verify that only that player's `minecraft:max_health` changes.
- Give or consume an enchanted golden apple for one player.
- Verify that the other player's health remains unchanged.

## Phase 3: Minecraft version matrix

Run the integration suite once for each supported version:

| Minecraft version | Data pack format | Required result                       |
| ----------------- | ---------------: | ------------------------------------- |
| 1.21.7            |               81 | All static and integration tests pass |
| 1.21.8            |               81 | All static and integration tests pass |

The version list should live in one workflow matrix so adding a supported version requires one small, reviewable change.

Each matrix job should:

1. Download the exact server JAR for the matrix version.
2. Accept the EULA in the temporary CI workspace.
3. Start the server in headless mode with the test datapack and HeartStakes.
4. Run the GameTest or test harness command.
5. Stop the server cleanly.
6. Upload server logs and test results if the job fails.

## Phase 4: Packaging

After static validation and all version-matrix jobs pass:

1. Create a ZIP whose root is the `HeartStakes` folder.
2. Exclude CI files, test-only datapacks, local worlds, logs, and temporary files.
3. Validate the ZIP contains `HeartStakes/pack.mcmeta` at the expected path.
4. Upload the ZIP as a workflow artifact for pull requests and branch builds.

## Phase 5: Release publishing

Publish releases only when a version tag such as `v1.0.0` is pushed.

The release job should:

1. Require all static and integration jobs to pass.
2. Build the same ZIP that was validated by CI.
3. Create a GitHub Release using the tag.
4. Attach the ZIP to the release.
5. Include the supported Minecraft versions in the release notes.

Do not deploy directly to a multiplayer server from the first version of the pipeline. Start with a release artifact, then add an optional deployment job after the artifact process is trusted.

## Suggested GitHub Actions files

Use separate workflows so failures are easy to understand:

```text
.github/
└── workflows/
    ├── validate.yml       # JSON, structure, metadata, and command linting
    ├── integration.yml    # Headless Minecraft version matrix
    ├── package.yml        # Build and upload the datapack ZIP artifact
    └── release.yml        # Package and publish version tags
```

## Secrets and permissions

The validation and integration jobs should need no repository secrets. The release job should use the minimum GitHub token permissions required to create a release and upload its artifact.

Server deployment, if added later, should use a dedicated deployment secret with limited scope and should be a manually approved environment in GitHub Actions.

## Implementation order

1. Add static structure and JSON validation.
2. Add command linting and make it pass on the current datapack.
3. Create the test-only datapack and one integration test for initialization.
4. Add death, floor, apple, and multiplayer isolation tests.
5. Add the 1.21.7 and 1.21.8 matrix.
6. Add ZIP packaging as a build artifact.
7. Add tag-based GitHub Release publishing.
8. Consider optional server deployment after release artifacts are reliable.

## Definition of done

The CI/CD integration is complete when a pull request cannot merge with malformed datapack files or a failing behavior test, both supported Minecraft versions pass the integration matrix, and a version tag produces a clean downloadable `HeartStakes` ZIP.
