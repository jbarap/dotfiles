# Nvim configuration

The goal is to have a functional, intuitive, and portable editor, customized to my
workflow.

## Notes

- Hererocks fails to install with python 3.9, use pyenv shell 3.8.10 before running nvim
  for the first time

- If using anything < python 3.8, do `pip install typing_extensions` to avoid problems.

- This config targets nightly.

## Requirements

Some dependencies currently require external packages (at least in linux), so make
sure you have them.

`sudo apt install libffi-dev libjpeg-dev zlib1g-dev`

## Dependencies

Dependency manager is in progress, but should work by calling `setup`:

```bash
./data/install_deps.py setup
```

Then `install` to install the executables described in `data/installables.json`:

```bash
./data/install_deps.py install
```

Eventually also update the executables with:

```bash
./data/install_deps.py update
```

More details in `data/install_spec.md`. (not up to date)
