# Art Guide

This guide covers everything needed to create and import art assets into the
companion app — background, characters, and ambient elements.

---

## Tools

| Tool | Purpose | Notes |
|---|---|---|
| AI image generator | Generate base poses and concepts | Any tool works — Midjourney, DALL-E, etc. |
| Adobe Illustrator | Refine, clean up, and recolor AI output | Export as PNG with transparent background |
| **Aseprite** | Define animation frames and export sprite sheets | Strongly recommended — Godot 4 has a native Aseprite importer |

Aseprite is available for ~$20 on [Steam](https://store.steampowered.com/app/431730/Aseprite/)
or [itch.io](https://dacap.itch.io/aseprite). Without it, you must manually add
frames one by one in Godot's SpriteFrames editor, which is slow. With it, Godot
imports a `.aseprite` file directly and auto-generates all animations.

---

## Canvas and Scale

| Asset | Creation canvas | Notes |
|---|---|---|
| Background | **480 × 270 px** | Exact viewport size — no scaling needed |
| Each character | **128 × 128 px** | Per frame; Godot scales to fit the scene |
| Ambient elements | Match the area they cover | See [Ambient Elements](#ambient-elements) |

The companion app viewport is **480 × 270** (16:9). Godot scales this to fill
the screen at integer multiples (×4 at 1080p, ×8 at 4K) using nearest-neighbor
filtering, so pixels stay sharp at any resolution.

The 128 × 128 character canvas gives enough room for readable animations without
being too expensive to produce. You will position and scale each worker in the
Godot editor after importing — exact pixel size is flexible.

---

## Background

One static PNG: `480 × 270 px`, transparent background not needed.

**File location:** `companion-app/assets/background/office.png`

**Contents (from the room description):**
- Top-down perspective, top and side walls only
- 4 desks in a C-layout (2 near top, 1 lower-left, 1 lower-right)
- 1 smaller center desk for the rush worker
- Each desk: laptop, coffee mug, pen, notebook pile, trash bin
- Wide window on the top wall (street and clouds outside)
- Water dispenser in one corner
- 2 open doors — left wall and right wall
- Server rack in one corner

**Import into Godot:**
1. Place the file at the path above
2. In Godot's FileSystem panel, select the file
3. In the Import tab, set **Filter** to `Nearest` (keeps pixels sharp)
4. Click **Reimport**
5. Select the `Background` node in the scene tree
6. Drag the imported texture into the **Texture** property in the Inspector

---

## Characters

There are **5 characters**: Worker1, Worker2, Worker3, Worker4 (desk workers)
and RushWorker (center desk). Each has a distinct appearance — create them
separately.

### Animations required

Each character needs all 14 animations listed below. Animation names must match
**exactly** (lowercase) — Godot's renderer looks them up by name.

| Animation name | Loop | Description | Suggested frames |
|---|---|---|---|
| `idle` | Yes | Sitting at desk — subtle shift, coffee sip | 4–6 |
| `typing` | Yes | Writing in physical notebook with pen | 4–6 |
| `thinking` | Yes | Typing on laptop, both hands on keyboard | 4–6 |
| `success` | No | Cheer — arms raised | 6–8 |
| `error` | No | Grab head in panic | 6–8 |
| `falling_asleep` | No | Gradually nods off — plays once | 6–8 |
| `sleeping` | Yes | Asleep — slow head bob or breathing | 3–4 |
| `debugging` | Yes | Using screwdriver on laptop | 6–8 |
| `running` | Yes | Leaning forward, pressing enter, watching screen | 4–6 |
| `terminal` | No | Leaning back, crossing arms, satisfied nod | 4–6 |
| `file_switch` | No | Reaching to notebook pile, swapping top notebook | 4–6 |
| `file_create` | No | Pulling new notebook from desk drawer | 4–6 |
| `file_delete` | No | Throwing notebook into trash bin | 4–6 |
| `file_rename` | No | Picking up pen, writing on notebook cover, putting pen down | 6–8 |

`falling_asleep` always plays first, then `sleeping` loops. They are two halves
of the AWAY state — design them to transition smoothly.

### Aseprite workflow (recommended)

1. Create a new Aseprite file — canvas **128 × 128 px**
2. Draw each animation as a sequence of frames on the timeline
3. Use **Tags** (Timeline → Frame Tags) to name each animation range:
   - Select the frames for `idle`, tag them as `idle`
   - Repeat for every animation in the table above
4. Check loop settings per tag: right-click the tag → **Properties** → set
   **Repeat** to `Loop` or `Ping-pong` for looping animations, `No loop` for
   one-shot animations
5. Save as `worker1.aseprite` (one file per character)
6. **File location:** `companion-app/assets/characters/worker1/worker1.aseprite`

### PNG workflow (without Aseprite)

1. Create each frame in Illustrator at 128 × 128 px, transparent background
2. Export each frame as a numbered PNG:
   `idle_01.png`, `idle_02.png`, `typing_01.png`, `typing_02.png`, etc.
3. Place all frames for a character in:
   `companion-app/assets/characters/worker1/`
4. Import manually in Godot (see [Importing into Godot](#importing-into-godot))

---

## Importing into Godot

### With Aseprite files

1. Place each `.aseprite` file in its folder under `companion-app/assets/characters/`
2. In Godot's FileSystem panel, the file appears automatically
3. Select the file → Import tab → verify **Animation** settings look correct → **Reimport**
4. The imported resource is a `SpriteFrames` with all tagged animations ready
5. In the scene tree, select `Worker1`
6. In the Inspector, click the current **Sprite Frames** resource → **Make Unique**
   (this gives Worker1 its own independent copy)
7. Click the SpriteFrames resource to open the editor
8. Replace the placeholder animations by pointing each animation to the imported
   `.aseprite` resource, or drag the imported resource directly onto the
   **Sprite Frames** property
9. Repeat for Worker2, Worker3, Worker4, RushWorker — each gets their own
   character's `.aseprite` file

### With PNG frames (manual)

1. In the scene tree, select `Worker1`
2. Inspector → **Sprite Frames** → **Make Unique**
3. Click the SpriteFrames to open the editor
4. For each animation:
   - Select the animation name in the left panel (e.g. `idle`)
   - Click the **Add frames from file system** button (film strip icon)
   - Select the PNG frames for that animation in order
   - Set **FPS** (recommended: 8 for most animations, 4 for `sleeping`)
5. Verify loop settings match the table above (lock icon next to each animation)
6. Repeat for all 14 animations, then for all 5 workers

### Adjust worker positions

After importing art, the placeholder positions in the scene will likely be wrong.
For each worker:
1. Select the worker node in the scene tree
2. In the 2D viewport, drag them to the correct desk position
3. Or set **Position** manually in the Inspector

---

## Ambient Elements

These are independent animated elements with no connection to the event system.
They loop forever.

### Clouds / street (window)

- A looping `AnimatedSprite2D` or `Sprite2D` with a scrolling shader
- Positioned over the window area of the background
- Suggested: a 2–3 frame cloud drift or a scrolling street texture

**Add to scene:** right-click `OfficeScene` in the scene tree → **Add Child Node**
→ `AnimatedSprite2D` → name it `WindowAmbient`

### Computer screen glow

- Subtle brightness pulse on the laptop/monitor area of each desk
- Can be a small `AnimatedSprite2D` overlaid on each desk's screen area
- 2–3 frames of slight brightness variation is enough

### Cat

- Separate `AnimatedSprite2D` with a walk cycle
- Follows a `Path2D` that enters from one side of the screen and exits the other
- Loop: the cat walks across, disappears, reappears after a delay

**Cat setup in Godot:**
1. Add a `Path2D` node to the scene, draw the path across the floor area
2. Add a `PathFollow2D` as a child of `Path2D`
3. Add the cat `AnimatedSprite2D` as a child of `PathFollow2D`
4. Animate `PathFollow2D.progress_ratio` from 0.0 to 1.0 with a `Tween` or
   `AnimationPlayer`, then restart after a pause

---

## File Organization

```
companion-app/
  assets/
    background/
      office.png
    characters/
      worker1/
        worker1.aseprite     (or PNG frames)
      worker2/
        worker2.aseprite
      worker3/
        worker3.aseprite
      worker4/
        worker4.aseprite
      rush_worker/
        rush_worker.aseprite
    ambient/
      cat_walk.aseprite
      window_clouds.aseprite
      screen_glow.png
```

---

## Checklist

Before testing with art in place:

- [ ] Background PNG imported at 480 × 270 with Nearest filter
- [ ] Each of the 5 workers has their own independent SpriteFrames (Make Unique applied)
- [ ] All 14 animation names match exactly (lowercase, underscores)
- [ ] `falling_asleep` loop = No, `sleeping` loop = Yes
- [ ] `success`, `error`, `terminal`, `file_switch`, `file_create`, `file_delete`, `file_rename` loop = No
- [ ] All remaining animations loop = Yes
- [ ] Worker positions adjusted to align with background desk positions
- [ ] RushWorker positioned at center desk, `visible = false` in Inspector
- [ ] Nearest-neighbor texture filter set on all `AnimatedSprite2D` nodes
- [ ] Run the scene with the mock server and verify all 13 states trigger visible animations
