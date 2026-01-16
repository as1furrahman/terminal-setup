# ~/.zprofile
# Environment variables and PATH configuration
# Loaded once at login (not for every new shell)
# Part of: Cross-Distro Terminal Setup

# ============================================================================
# XDG Base Directory Specification
# ============================================================================
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# ============================================================================
# Default Applications
# ============================================================================
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export BROWSER="xdg-open"

# ============================================================================
# PATH Configuration
# ============================================================================
# User binaries
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Cargo (Rust)
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# Go
[[ -d "$HOME/go/bin" ]] && export PATH="$HOME/go/bin:$PATH"

# ============================================================================
# Shell Configuration
# ============================================================================
# Zsh history location (XDG compliant)
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=10000
export SAVEHIST=10000

# Less configuration
export LESS="-R --mouse --wheel-lines=3"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# ============================================================================
# Tool-Specific Configuration
# ============================================================================
# bat (cat replacement)
export BAT_THEME="base16"
export BAT_PAGER="less -RF"

# fzf configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"

# eza (ls replacement) - icons require Nerd Font
export EZA_ICONS_AUTO=1

# Starship prompt
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"

# ============================================================================
# Create required directories
# ============================================================================
[[ ! -d "$XDG_STATE_HOME/zsh" ]] && mkdir -p "$XDG_STATE_HOME/zsh"
[[ ! -d "$XDG_STATE_HOME/less" ]] && mkdir -p "$XDG_STATE_HOME/less"
