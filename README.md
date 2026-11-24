# Squat Analyzer POC

A browser-only squat coach. Open the page on a laptop or phone, squat in front of the camera, and get live joint angles, a rep count, form cues, a set summary and a 3D replay of the set.

Pose estimation runs **on the device** with Google MediaPipe. Video frames are never uploaded or stored on a server.

HexaCoder Technologies · proof of concept

---

## Features

| # | Feature | Notes |
|---|---|---|
| 1 | Live camera or uploaded video | Front or back camera; uploaded videos are analysed as they play |
| 2 | Setup check | Red banner asks the user to step back and names the joints out of frame |
| 3 | Live overlay | Skeleton plus left/right knee and hip angles, torso lean, front/side view |
| 4 | Rep counter | Counts full squats only (hysteresis 160° / 120°); small bobs are ignored |
| 5 | Form feedback | "Go deeper", "Push knees out", "Keep chest up"; optional voice cues |
| 6 | Set summary | Stats, per-rep table (depth, hip, lean, knee/ankle ratio, cues), knee-angle chart |
| 7 | 3D replay | Rotatable, scrubbable 3D skeleton synced with the chart |
| + | Range-of-motion check | Arm raise and knee bend, left vs right with asymmetry % |

All thresholds can be tuned live from the **Thresholds** panel and are saved in the browser.

## Quick start

There is no build step and nothing to install. Browsers only allow camera access on `https://` or `localhost`, so serve the folder locally instead of opening the file directly.

```powershell
.\serve.ps1
```

Then open <http://localhost:8765> in Chrome or Edge.

Equivalent without the script:

```powershell
python -m http.server 8765 --bind 127.0.0.1
```

### Using it

1. Click **Start camera** (or **Upload video**).
2. Step back until the red banner disappears. Shoulders, hips, knees and ankles must be in frame.
3. Click **Start set**, do your squats, click **End set**.
4. Review the summary. Click the chart or a table row to jump the 3D replay to that moment.

Camera placement: side-on or at 45° gives the best depth and lean readings. Face the camera to get the "Push knees out" cue.

### Self-test

Open <http://localhost:8765/?selftest> to run a synthetic squat sequence through the same pipeline. The expected result is 4 reps, the small bob ignored, "Go deeper" on rep 2 and "Keep chest up" on rep 3. The result is also logged to the browser console as `SELFTEST`.

## Default thresholds

| Threshold | Default | Effect |
|---|---|---|
| Standing knee angle | ≥ 160° | Rep starts below and completes above this |
| Squat counts when knee | ≤ 120° | Filters out bobs and partial reps |
| Go deeper if bottom knee | > 95° | Depth cue |
| Keep chest up if torso lean | > 45° | Lean cue |
| Push knees out if knee/ankle width | < 0.85 | Knee-cave cue, front view only |
| Landmark confidence | ≥ 0.5 | Strictness of the full-body check |
| Angle smoothing | 0.5 | Higher is smoother but adds lag |

The same defaults live in the `DEFAULTS` object at the top of the script in `index.html`.

## Tech stack

| Library | Version | Role | Licence |
|---|---|---|---|
| [MediaPipe Tasks Vision – Pose Landmarker](https://ai.google.dev/edge/mediapipe/solutions/vision/pose_landmarker) | 0.10.14 (full float16 model) | 33-landmark pose detection, 2D + 3D world coordinates | Apache 2.0 |
| [Chart.js](https://www.chartjs.org/) | 4.4.1 | Knee-angle chart | MIT |
| [Three.js](https://threejs.org/) + OrbitControls | 0.160.0 | 3D skeleton replay | MIT |

Libraries load from the jsDelivr CDN; the pose model loads from Google's MediaPipe model storage. An internet connection is needed on first load.

## Project structure

```
Squat-Analyzer-POC/
├── index.html                  # The whole app: HTML, CSS and JavaScript
├── serve.ps1                   # Starts a local web server on port 8765
├── docs/
│   └── TECHNICAL_OVERVIEW.md   # Strategies, architecture, implementation details
├── .claude/launch.json         # Dev-server config for Claude Code preview
└── README.md
```

Inside `index.html` the script is organised in sections: tunable thresholds → geometry (angles, metrics) → per-frame pipeline (full-body gate, smoothing, recording) → rep state machine and cues → ROM logic → drawing and HUD → sources and set control → summary (stats, table, chart) → 3D replay → self-test.

## Phone testing

Phones need the page on an HTTPS URL. Any static host works because the app is a single file, for example GitHub Pages (enable Pages on the repository's default branch), Netlify or Vercel.

## Limitations

- Not yet validated with real users; thresholds may need tuning after live tests.
- Camera angle matters; the knee-cave cue works only in front view.
- A tilted camera shifts the lean reading, because the vertical axis follows the camera.
- The 3D replay shows the skeleton only, not the original video.

See [docs/TECHNICAL_OVERVIEW.md](docs/TECHNICAL_OVERVIEW.md) for the full design write-up.
