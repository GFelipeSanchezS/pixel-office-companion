# Releasing

This guide covers how to build, package, and publish a release of Pixel Office Companion.
A release consists of two artifacts: the editor extension (`.vsix`) and the companion
app executable (one per platform).

---

## Prerequisites

- **Node.js** v18 or later
- **Godot 4.x** — the editor (not just the runtime binary)
- **vsce** — the VS Code extension packaging tool:
  ```bash
  npm install -g @vscode/vsce
  ```

---

## 1. Package the Editor Extension

The extension is packaged as a `.vsix` file that users install directly in VS Code.

```bash
cd editor-extension
npm install
npm run compile
vsce package
```

This produces `editor-event-sensor-<version>.vsix` in the `editor-extension/` directory.

**Before packaging for a public release:**
- Update `version` in `editor-extension/package.json`
- Update `publisher` in `editor-extension/package.json` — change `"local"` to your
  actual VS Code Marketplace publisher ID
- If publishing to the VS Code Marketplace instead of distributing the `.vsix` manually,
  run `vsce publish` instead of `vsce package` (requires a Personal Access Token)

---

## 2. Export the Companion App

The companion app is exported to a standalone executable using Godot's export system.
No Godot installation is required to run the exported app.

### First-time setup — download export templates

1. Open Godot and import the `companion-app/` project
2. Go to **Editor → Manage Export Templates**
3. Download the templates that match your Godot version
4. Wait for the download to complete

### Export for each platform

1. In Godot, go to **Project → Export**
2. Click **Add...** and select a preset:
   - **Windows Desktop** — produces a `.exe`
   - **Linux/X11** — produces a Linux binary
   - **macOS** — produces a `.app` bundle
3. For each preset:
   - Set the **Export Path** (e.g. `../releases/windows/PixelOfficeCompanion.exe`)
   - Click **Export Project** (not "Export PCK/ZIP")
   - Leave **Debug** unchecked for release builds
4. Repeat for each target platform

**Recommended export settings per platform:**

| Platform | Binary name | Notes |
|---|---|---|
| Windows | `PixelOfficeCompanion.exe` | Bundle the `.pck` file with the `.exe` |
| Linux | `PixelOfficeCompanion` | Make the binary executable (`chmod +x`) |
| macOS | `PixelOfficeCompanion.app` | Zip the `.app` bundle for distribution |

### Texture filter note

The project uses nearest-neighbor filtering on all sprites for crisp pixel art.
This is set per-node in the scene and does not require any export setting changes.

---

## 3. Test the Packaged Artifacts

Before publishing:

- [ ] Install the `.vsix` in a clean VS Code profile: Extensions → `···` → **Install from VSIX**
- [ ] Verify the extension activates on startup (no errors in the Output panel)
- [ ] Run the companion app executable on each target platform
- [ ] Open VS Code and confirm the companion app shows `connected` in its output
- [ ] Type in a file and confirm the correct animation triggers
- [ ] Disable one sensor in VS Code settings and confirm that event type stops firing

---

## 4. Publish a GitHub Release

1. Commit and push all changes
2. Tag the release:
   ```bash
   git tag v<version>
   git push origin v<version>
   ```
3. On GitHub, go to **Releases → Draft a new release**
4. Select the tag you just pushed
5. Upload the artifacts:
   - `editor-event-sensor-<version>.vsix`
   - `PixelOfficeCompanion-windows.zip` (contains `.exe` and `.pck`)
   - `PixelOfficeCompanion-linux.zip` (contains the Linux binary)
   - `PixelOfficeCompanion-macos.zip` (contains the `.app` bundle)
6. Write release notes describing what changed
7. Publish the release

---

## Version numbering

This project uses [Semantic Versioning](https://semver.org):

- `MAJOR` — breaking protocol change (new schema version required)
- `MINOR` — new event types, new sensors, new states, new art
- `PATCH` — bug fixes, timing tweaks, documentation

Update the version in `editor-extension/package.json` before every release.
The companion app version is not tracked separately — they ship together.
