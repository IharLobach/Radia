"""Run a bundled Radia example against the installed extension, without GUIs."""

from __future__ import annotations

import runpy
import sys
from pathlib import Path

import radia


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit(f"usage: {Path(sys.argv[0]).name} EXAMPLE.py")

    example = Path(sys.argv[1]).resolve()
    sys.path.append(str(example.parent))

    # The examples open an OpenGL viewer and blocking matplotlib windows. Those
    # are presentation steps; suppress them while retaining all computations.
    radia.ObjDrwOpenGL = lambda *_args, **_kwargs: None

    try:
        import uti_plot
    except ImportError:
        pass
    else:
        for name in dir(uti_plot):
            if name.startswith("uti_plot"):
                setattr(uti_plot, name, lambda *_args, **_kwargs: None)

    runpy.run_path(str(example), run_name="__main__")


if __name__ == "__main__":
    main()
