# ~/.zshrc
# Zsh configuration with Zinit plugin manager
# Part of: Cross-Distro Terminal Setup

# ============================================================================
# Zinit Installation & Initialization
# ============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Auto-install Zinit if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
    print -P "%F{33}Installing Zinit...%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
        print -P "%F{34}Zinit installed successfully.%f" || \
        print -P "%F{160}Zinit installation failed.%f"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# Zinit Plugins (Turbo Mode for fast startup)
# ============================================================================

# Essential plugins with turbo loading
zinit wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

# Additional useful plugins
zinit wait lucid for \
    OMZP::git \
    OMZP::sudo \
    OMZP::command-not-found

# ============================================================================
# Zsh Options
# ============================================================================

# History
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Ignore consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicate entries
setopt HIST_IGNORE_SPACE         # Ignore commands starting with space
setopt HIST_FIND_NO_DUPS         # No duplicates in search
setopt HIST_SAVE_NO_DUPS         # No duplicates when saving
setopt SHARE_HISTORY             # Share history between sessions
setopt INC_APPEND_HISTORY        # Add commands as they are typed

# Directory navigation
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push directory to stack
setopt PUSHD_IGNORE_DUPS         # No duplicates in directory stack
setopt PUSHD_SILENT              # Don't print directory stack

# Completion
setopt COMPLETE_IN_WORD          # Complete from both ends
setopt ALWAYS_TO_END             # Move cursor to end after completion
setopt MENU_COMPLETE             # Autoselect first completion entry

# Misc
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shell
setopt NO_BEEP                   # No beep on error

# ============================================================================
# Completion System
# ============================================================================
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

# ============================================================================
# Key Bindings (Emacs style)
# ============================================================================
bindkey -e

bindkey '^[[A' history-search-backward      # Up arrow
bindkey '^[[B' history-search-forward       # Down arrow
bindkey '^[[H' beginning-of-line            # Home
bindkey '^[[F' end-of-line                  # End
bindkey '^[[3~' delete-char                 # Delete
bindkey '^H' backward-kill-word             # Ctrl+Backspace

# ============================================================================
# Aliases
# ============================================================================

# Directory listing (eza)
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
    alias l='eza -l --icons --group-directories-first'
else
    alias ls='ls --color=auto'
    alias ll='ls -la'
    alias la='ls -a'
fi

# cat replacement (bat)
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat --plain'
fi

# General
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias rm='rm -I'
alias mv='mv -i'
alias cp='cp -i'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Editor shortcuts
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nano='nano -l'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Quick tools
alias y='yazi'
alias bt='btop'
alias t='tmux'
alias ta='tmux attach'

# System
alias reload='exec zsh'
alias path='echo -e ${PATH//:/\\n}'

# ============================================================================
# fzf Integration
# ============================================================================
if command -v fzf &> /dev/null; then
    # Source fzf keybindings if available
    [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
    
    # Arch Linux
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
    
    # Fedora
    [[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && source /usr/share/fzf/shell/key-bindings.zsh
fi

# ============================================================================
# Yazi Shell Wrapper (for directory changing)
# ============================================================================
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# ============================================================================
# Custom Block Prompt (BreadOnPenguins style with Mellifluous colors)
# ============================================================================
# Mellifluous palette:
# Background: #1a1a1a | Tan: #c0af8c | Green: #b3b393 | Lavender: #a8a1be
# Gray: #5b5b5b | Red: #d29393 | Foreground: #dadada

# Block-style prompt: [time] [user] [path] ❯
NEWLINE=$'\n'
PROMPT="${NEWLINE}%K{#5b5b5b}%F{#dadada} %D{%_I:%M%P} %K{#c0af8c}%F{#1a1a1a} %n %K{#b3b393}%F{#1a1a1a} %~ %f%k ❯ "

# Alternative: With hostname (uncomment if wanted)
# PROMPT="${NEWLINE}%K{#5b5b5b}%F{#dadada} %D{%_I:%M%P} %K{#c0af8c}%F{#1a1a1a} %n@%m %K{#b3b393}%F{#1a1a1a} %~ %f%k ❯ "

# ============================================================================
# Greeting Echo (BreadOnPenguins style with Mellifluous colors)
# ============================================================================
# Shows: time | uptime | kernel version
echo -e "${NEWLINE}\x1b[38;2;192;175;140m\x1b[48;2;26;26;26m it's$(print -P '%D{%_I:%M%P}') \x1b[38;2;179;179;147m\x1b[48;2;26;26;26m $(uptime -p | cut -c 4-) \x1b[38;2;218;218;218m\x1b[48;2;26;26;26m $(uname -r) \033[0m"

# ============================================================================
# Ghostty Shell Integration
# ============================================================================
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

# ============================================================================
# Optional: Starship (disabled - using custom PS1 instead)
# ============================================================================
# Uncomment below to use Starship instead of custom PS1:
# if command -v starship &> /dev/null; then
#     eval "$(starship init zsh)"
# fi
