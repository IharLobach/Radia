# Radia
3D Magnetostatics Computer Code

## Python on Apple Silicon

On an arm64 Mac, build FFTW 2.1.5 and Radia from source and install the Python
extension into the configured Conda environment with:

```sh
./build_macos_arm64.sh
```

The default interpreter is:

```text
/opt/homebrew/Caskroom/miniconda/base/envs/env/bin/python
```

Set `PYTHON_BIN` to use a different interpreter. Verify the installation from
outside the example directory, whose bundled Linux `radia.so` otherwise shadows
the installed macOS extension:

```sh
/opt/homebrew/Caskroom/miniconda/base/envs/env/bin/python -c \
  'import radia; print(radia.UtiVer())'
```

The examples include interactive OpenGL and plotting calls. To run their
computations headlessly against the installed extension:

```sh
MPLBACKEND=Agg /opt/homebrew/Caskroom/miniconda/base/envs/env/bin/python \
  validate_python_example.py env/radia_python/RADIA_Example01.py
```
