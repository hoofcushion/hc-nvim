# Intro

The hc-nvim is a configuration for Neovim.

The hc is the abbreviation of owner Hoof Cushion.

The goals of hc-nvim:

- Simple.
- Centralize.
- Extendable.
- Decouple.
- Linear.

# Usage

## Installation

Dependencies:

- neovim
- git

### Unix

Run command in the terminal:

```sh
cd ~
cd .config
mv nvim nvim.bak
git clone https://github.com/hoofcushion/hc-nvim nvim
```

### Windows

Press Win+r, puts "powershell", press enter, then run commands:

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

Goto the directory it prints and run
Make sure the directory is empty and had backup.

```sh
git clone https://github.com/hoofcushion/hc-nvim .
```

### Lazy.nvim

If you had lazy.nvim, hc-nvim as a plugin can installed by it:

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

### Trouble

- Setup proxy to before using git.
- Use checkhealth command.
