# Radia
3D Magnetostatics Computer Code

## Python on Apple Silicon

On an arm64 Mac, build FFTW 2.1.5 and Radia from source and install the Python
extension into a selected Python environment with:

```sh
export PYTHON_BIN=/path/to/python
./build_macos_arm64.sh
```

`PYTHON_BIN` is required and must point to an executable Python interpreter.
Verify the installation from outside the example directory, whose bundled Linux
`radia.so` otherwise shadows the installed macOS extension:

```sh
"$PYTHON_BIN" -c \
  'import radia; print(radia.UtiVer())'
```

The examples include interactive OpenGL and plotting calls. To run their
computations headlessly against the installed extension:

```sh
MPLBACKEND=Agg "$PYTHON_BIN" \
  validate_python_example.py env/radia_python/RADIA_Example01.py
```
