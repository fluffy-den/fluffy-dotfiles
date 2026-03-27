#!/usr/bin/env python3
"""
wallpaper-pause.py — i3ipc daemon that pauses all mpv wallpaper instances
when a non-exempt window goes fullscreen, and resumes them otherwise.

Communicates with mpv via its JSON IPC sockets at:
  /tmp/mpv-wallpaper-0.sock
  /tmp/mpv-wallpaper-1.sock
  ...
"""

import glob
import json
import socket
import time
import i3ipc

MPV_SOCK_GLOB = "/tmp/mpv-wallpaper-*.sock"

# Windows whose WM_CLASS matches any entry here will NOT trigger a pause,
# even when fullscreened. Case-insensitive substring match.
PAUSE_EXEMPT_CLASSES = {
    "kitty",
}

# Persistent connections to each mpv socket, keyed by socket path.
_mpv_conns: dict[str, socket.socket] = {}


def _get_conn(sock_path: str) -> socket.socket | None:
    """Return a cached, live socket connection to mpv, reconnecting if needed."""
    s = _mpv_conns.get(sock_path)
    if s is not None:
        return s
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.settimeout(0.5)
        s.connect(sock_path)
        _mpv_conns[sock_path] = s
        return s
    except (FileNotFoundError, ConnectionRefusedError, OSError):
        return None


def _drop_conn(sock_path: str) -> None:
    s = _mpv_conns.pop(sock_path, None)
    if s:
        try:
            s.close()
        except OSError:
            pass


def _send_mpv(sock_path: str, command: list) -> None:
    """Send a JSON IPC command over a persistent socket connection."""
    s = _get_conn(sock_path)
    if s is None:
        return
    try:
        msg = (json.dumps({"command": command}) + "\n").encode()
        s.sendall(msg)
        s.recv(4096)  # drain reply to avoid broken pipe
    except OSError:
        # Connection died; drop it so we reconnect next time
        _drop_conn(sock_path)


def set_all_paused(paused: bool) -> None:
    for sock in glob.glob(MPV_SOCK_GLOB):
        _send_mpv(sock, ["set_property", "pause", paused])


def is_exempt(window) -> bool:
    """Return True if this window's class is in the exempt list."""
    wclass = (window.window_class or "").lower()
    winstance = (window.window_instance or "").lower()
    return any(
        exempt in wclass or exempt in winstance
        for exempt in PAUSE_EXEMPT_CLASSES
    )


def should_pause(i3_conn) -> bool:
    """Return True if any non-exempt leaf is fullscreen."""
    for leaf in i3_conn.get_tree().leaves():
        if leaf.fullscreen_mode == 1 and not is_exempt(leaf):
            return True
    return False


def on_window_event(i3_conn, event) -> None:
    if event.change not in ("fullscreen_mode", "close", "focus", "move"):
        return
    set_all_paused(should_pause(i3_conn))


def main() -> None:
    # Wait for mpv IPC sockets to appear after boot
    time.sleep(2)

    i3_conn = i3ipc.Connection()
    i3_conn.on(i3ipc.Event.WINDOW, on_window_event)

    # Set initial state
    set_all_paused(should_pause(i3_conn))

    i3_conn.main()


if __name__ == "__main__":
    main()
