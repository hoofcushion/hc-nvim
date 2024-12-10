# Intro

`hc-nvim` is a configuration for Neovim.

`hc` stands for the abbreviation of the owner Hoof Cushion.

## Goals of `hc-nvim`

- Simple
- Centralize
- Extendable
- Decouple
- Linear

# Usage

## Installation

### Dependencies

- Neovim
- Git

### Unix

Run the following command in the terminal:

```sh
cd ~
cd .config
mv nvim nvim.bak
git clone https://github.com/hoofcushion/hc-nvim nvim
```

### Windows

Press `Win+r`, type "powershell", press enter, then run the following commands:

```powershell
cd ~
cd AppData/Local
mv nvim nvim.bak
git clone https://github.com/hoofcushion/hc-nvim nvim
```

### Others

This command prints your config directory:

```sh
nvim --headless -c "echo stdpath('config') | q"
```

Navigate to the directory it prints and ensure the directory is empty and backed up.

```sh
git clone https://github.com/hoofcushion/hc-nvim .
```

### Lazy.nvim

If you are using `lazy.nvim`, `hc-nvim` can be installed as a plugin with the following configuration:

```lua
require("lazy").setup({
    spec = {
        { "hoofcushion/hc-nvim", import = "hc-nvim.export" },
    },
    default = {
        lazy = true,
    },
})
```

### Troubleshoot

- Set up a proxy before using git.
- Use the `checkhealth` command to diagnose issues.
