"""Bottom-edge focus indicator for i3 (no compositor / no full border).

Draws a thin bar in the gap just below the focused window so the client
does not cover it. Default color is ~50% grey for visibility.
"""
from __future__ import annotations

import sys

import i3ipc
from Xlib import X, display

HEIGHT = 3
# ~50% brightness grey — 33% was too close to dark chrome to see
COLOR = 0x808080


class FocusUnderline:
    def __init__(self) -> None:
        self.dpy = display.Display()
        self.screen = self.dpy.screen()
        self.root = self.screen.root
        self.cmap = self.screen.default_colormap
        # Allocate an exact color so we are not at the mercy of pixel packing.
        color = self.cmap.alloc_color(0x8080, 0x8080, 0x8080)
        self.win = self.root.create_window(
            0,
            0,
            1,
            HEIGHT,
            0,
            self.screen.root_depth,
            X.InputOutput,
            X.CopyFromParent,
            background_pixel=color.pixel,
            override_redirect=True,
            event_mask=X.ExposureMask,
        )
        self.win.change_property(
            self.dpy.get_atom("_NET_WM_WINDOW_TYPE"),
            self.dpy.get_atom("ATOM"),
            32,
            [self.dpy.get_atom("_NET_WM_WINDOW_TYPE_NOTIFICATION")],
        )
        self.win.change_property(
            self.dpy.get_atom("_NET_WM_STATE"),
            self.dpy.get_atom("ATOM"),
            32,
            [
                self.dpy.get_atom("_NET_WM_STATE_SKIP_TASKBAR"),
                self.dpy.get_atom("_NET_WM_STATE_SKIP_PAGER"),
                self.dpy.get_atom("_NET_WM_STATE_ABOVE"),
            ],
        )
        self.win.map()
        self.dpy.flush()
        self.visible = True
        self.hide()

    def hide(self) -> None:
        if self.visible:
            self.win.unmap()
            self.dpy.flush()
            self.visible = False

    def show_at(self, x: int, y: int, w: int) -> None:
        if w <= 0:
            self.hide()
            return
        self.win.configure(x=x, y=y, width=w, height=HEIGHT, stack_mode=X.Above)
        if not self.visible:
            self.win.map()
            self.visible = True
        self.win.raise_window()
        self.dpy.flush()


def focused_leaf(tree: i3ipc.Con) -> i3ipc.Con | None:
    for con in tree.leaves():
        if con.focused and con.window is not None:
            return con
    return None


def should_track(con: i3ipc.Con | None) -> bool:
    if con is None:
        return False
    if con.fullscreen_mode:
        return False
    if con.window is None:
        return False
    name = (con.window_class or "") + " " + (con.name or "")
    if "i3bar" in name.lower():
        return False
    return True


def main() -> int:
    underline = FocusUnderline()
    i3 = i3ipc.Connection()

    def update(_i3=None, _event=None) -> None:
        focused = focused_leaf(i3.get_tree())
        if not should_track(focused):
            underline.hide()
            return
        r = focused.rect
        # Sit in the gap just below the window (not inside it — clients cover that).
        underline.show_at(r.x, r.y + r.height, r.width)

    for event in (
        i3ipc.Event.WINDOW_FOCUS,
        i3ipc.Event.WINDOW_CLOSE,
        i3ipc.Event.WINDOW_MOVE,
        i3ipc.Event.WINDOW_NEW,
        i3ipc.Event.WINDOW_FULLSCREEN_MODE,
        i3ipc.Event.WORKSPACE_FOCUS,
        i3ipc.Event.BINDING,
    ):
        i3.on(event, update)

    update()
    i3.main()
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(0)
