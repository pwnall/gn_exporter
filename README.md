# GN Exporter

This is intended to grow into a tool that can extract
[GN](https://chromium.googlesource.com/chromium/src/+/master/tools/gn/README.md)
from the Chromium repository. It is nowhere near ready.

## Usage

The scripts assume that you ran `fetch chromium` inside a `chromium` directory
in your home dir. If that's not the case, set the `SRCDIR` environment variable
to point to your checkout.

```bash
export SRCDIR=~/chromium  # This is the default
```

Running `build.sh` will create a `repo` directory, populate it with a superset
of the files needed to build GN, then build and test GN.
