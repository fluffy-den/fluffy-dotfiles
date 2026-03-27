#!/usr/bin/env bash
# Video wallpaper launcher using xwinwrap + mpv with VA-API hardware decoding.
# Spawns one mpv instance per connected monitor.
# MPV IPC sockets are created at /tmp/mpv-wallpaper-<display>.sock
# so the fullscreen-pause daemon can pause/resume them.

VIDEO="${1:-$HOME/videos/large-cherry-blossom-tree.1920x1080.hevc.mp4}"

# ── Kill any existing wallpaper instances ────────────────────────────────────
pkill -f "xwinwrap.*mpv" 2>/dev/null
sleep 0.3

# ── Discover connected monitors and their geometry ───────────────────────────
# xrandr output example:  DP-1 connected primary 1920x1080+1920+0 ...
mapfile -t MONITORS < <(
  xrandr --query | awk '
    / connected/ && /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {
      # extract WxH+X+Y
      match($0, /([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)/, m)
      print m[1] "x" m[2] "+" m[3] "+" m[4]
    }
  '
)

IDX=0
for GEOM in "${MONITORS[@]}"; do
  W="${GEOM%%x*}"
  REST="${GEOM#*x}"
  H="${REST%%+*}"
  XOFF="${REST#*+}"
  XOFF="${XOFF%+*}"
  YOFF="${REST##*+}"

  SOCK="/tmp/mpv-wallpaper-${IDX}.sock"

  xwinwrap \
    -g "${W}x${H}+${XOFF}+${YOFF}" \
    -ov -ni -nf -un -b -s -st -sp \
    -- mpv \
    --wid=%WID% \
    --loop=inf \
    --no-audio \
    --no-osc \
    --no-input-default-bindings \
    --no-border \
    --panscan=1.0 \
    --keepaspect=no \
    --hwdec=vaapi \
    --hwdec-codecs=all \
    --vo=gpu-next \
    --gpu-api=vulkan \
    --vd-lavc-dr=yes \
    --video-sync=display-vdrop \
    --framedrop=vo \
    --cache=no \
    --demuxer-readahead-secs=0 \
    --demuxer-max-bytes=1MiB \
    --msg-level=all=error \
    --input-ipc-server="${SOCK}" \
    "${VIDEO}" &

  IDX=$((IDX + 1))
done
