#!/usr/bin/env bash
# ============================================================================
# Cross-Distro Terminal Setup - Installation Script
# ============================================================================
# Supports: Arch Linux, Fedora, Debian/Ubuntu
# 
# Features:
# - Idempotent (safe to run multiple times)
# - Backs up existing configs before overwriting
# - Checks for existing packages before installing
# - Graceful error handling
#
# Usage:
#   ./install.sh           # Interactive mode
#   ./install.sh --dry-run # Show what would be done
#   ./install.sh --help    # Show help
# ============================================================================

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/configs"
BACKUP_DIR="${HOME}/.config-backup/terminal-setup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Flags
DRY_RUN=false
VERBOSE=false

# ============================================================================
# Utility Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_step() {
    echo -e "${CYAN}==>${NC} $1"
}

confirm() {
    local prompt="${1:-Continue?}"
    read -rp "$(echo -e "${YELLOW}${prompt} [y/N]: ${NC}")" response
    [[ "${response,,}" =~ ^(yes|y)$ ]]
}

# ============================================================================
# Distribution Detection
# ============================================================================

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "${ID}" in
            arch|manjaro|endeavouros|garuda|artix)
                DISTRO="arch"
                PKG_MANAGER="pacman"
                ;;
            fedora)
                DISTRO="fedora"
                PKG_MANAGER="dnf"
                ;;
            debian|ubuntu|pop|linuxmint|elementary)
                DISTRO="debian"
                PKG_MANAGER="apt"
                ;;
            *)
                log_error "Unsupported distribution: ${ID}"
                exit 1
                ;;
        esac
        log_info "Detected: ${NAME} (${DISTRO})"
    else
        log_error "Cannot detect distribution. /etc/os-release not found."
        exit 1
    fi
}

# ============================================================================
# Package Management
# ============================================================================

is_installed() {
    local pkg="$1"
    case "${PKG_MANAGER}" in
        pacman)
            pacman -Qi "$pkg" &>/dev/null
            ;;
        dnf)
            dnf list installed "$pkg" &>/dev/null
            ;;
        apt)
            dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"
            ;;
    esac
}

install_packages() {
    local packages=("$@")
    local to_install=()
    
    for pkg in "${packages[@]}"; do
        if is_installed "$pkg"; then
            log_info "Already installed: $pkg"
        else
            to_install+=("$pkg")
        fi
    done
    
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All packages already installed"
        return 0
    fi
    
    log_step "Installing: ${to_install[*]}"
    
    if $DRY_RUN; then
        log_info "[DRY-RUN] Would install: ${to_install[*]}"
        return 0
    fi
    
    case "${PKG_MANAGER}" in
        pacman)
            sudo pacman -S --noconfirm --needed "${to_install[@]}"
            ;;
        dnf)
            sudo dnf install -y "${to_install[@]}"
            ;;
        apt)
            sudo apt update
            sudo apt install -y "${to_install[@]}"
            ;;
    esac
}

# ============================================================================
# AUR Helper (Arch only)
# ============================================================================

check_aur_helper() {
    if [[ "${DISTRO}" != "arch" ]]; then
        return 0
    fi
    
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    else
        log_warning "No AUR helper found (yay/paru)"
        if confirm "Install yay?"; then
            log_step "Installing yay..."
            if ! $DRY_RUN; then
                sudo pacman -S --needed --noconfirm git base-devel
                local temp_dir=$(mktemp -d)
                git clone https://aur.archlinux.org/yay.git "${temp_dir}/yay"
                (cd "${temp_dir}/yay" && makepkg -si --noconfirm)
                rm -rf "${temp_dir}"
            fi
            AUR_HELPER="yay"
        else
            AUR_HELPER=""
        fi
    fi
    
    if [[ -n "${AUR_HELPER:-}" ]]; then
        log_info "AUR helper: ${AUR_HELPER}"
    fi
}

install_aur_packages() {
    if [[ "${DISTRO}" != "arch" ]] || [[ -z "${AUR_HELPER:-}" ]]; then
        return 0
    fi
    
    local packages=("$@")
    local to_install=()
    
    for pkg in "${packages[@]}"; do
        if is_installed "$pkg"; then
            log_info "Already installed (AUR): $pkg"
        else
            to_install+=("$pkg")
        fi
    done
    
    if [[ ${#to_install[@]} -eq 0 ]]; then
        return 0
    fi
    
    log_step "Installing AUR packages: ${to_install[*]}"
    
    if $DRY_RUN; then
        log_info "[DRY-RUN] Would install AUR: ${to_install[*]}"
        return 0
    fi
    
    "${AUR_HELPER}" -S --noconfirm --needed "${to_install[@]}"
}

# ============================================================================
# Package Lists (per distribution)
# ============================================================================

get_packages() {
    # Common packages (all distros)
    COMMON_PACKAGES=(
        zsh
        git
        curl
        wget
        unzip
        nano
        vim
        tmux
        fzf
        bat
        btop
    )
    
    # Distribution-specific package names
    case "${DISTRO}" in
        arch)
            PACKAGES=(
                "${COMMON_PACKAGES[@]}"
                neovim
                yazi
                eza
                starship
                chafa
                cowsay
                lolcat
                figlet
                fortune-mod
                cava
            )
            AUR_PACKAGES=(
                ghostty
                pokemon-colorscripts-git
                arch-update
            )
            ;;
        fedora)
            PACKAGES=(
                "${COMMON_PACKAGES[@]}"
                neovim
                eza
                chafa
                cowsay
                figlet
            )
            # Packages that need special handling on Fedora
            COPR_PACKAGES=(
                starship  # from starship/starship copr
            )
            ;;
        debian)
            PACKAGES=(
                "${COMMON_PACKAGES[@]}"
                neovim
                chafa
                cowsay
                figlet
                fortune-mod
            )
            # Packages that need manual installation on Debian
            MANUAL_PACKAGES=(
                ghostty
                yazi
                eza
                starship
            )
            ;;
    esac
}

# ============================================================================
# Config Deployment
# ============================================================================

backup_config() {
    local target="$1"
    
    if [[ -e "$target" ]]; then
        local backup_path="${BACKUP_DIR}/${target#$HOME/}"
        mkdir -p "$(dirname "$backup_path")"
        
        if $DRY_RUN; then
            log_info "[DRY-RUN] Would backup: $target -> $backup_path"
        else
            mv "$target" "$backup_path"
            log_info "Backed up: $target"
        fi
    fi
}

deploy_config() {
    local source="$1"
    local target="$2"
    
    if [[ ! -f "$source" ]]; then
        log_warning "Source not found: $source"
        return 1
    fi
    
    # Create target directory
    local target_dir=$(dirname "$target")
    
    if $DRY_RUN; then
        log_info "[DRY-RUN] Would deploy: $source -> $target"
        return 0
    fi
    
    # Backup existing config
    backup_config "$target"
    
    # Create directory and copy file
    mkdir -p "$target_dir"
    cp "$source" "$target"
    
    log_success "Deployed: $target"
}

deploy_all_configs() {
    log_step "Deploying configuration files..."
    
    # Create backup directory
    if ! $DRY_RUN && [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        log_info "Backup directory: $BACKUP_DIR"
    fi
    
    # Zsh
    deploy_config "${CONFIG_DIR}/zsh/.zprofile" "${HOME}/.zprofile"
    deploy_config "${CONFIG_DIR}/zsh/.zshrc" "${HOME}/.zshrc"
    
    # Starship
    deploy_config "${CONFIG_DIR}/starship/starship.toml" "${HOME}/.config/starship.toml"
    
    # Ghostty
    deploy_config "${CONFIG_DIR}/ghostty/config" "${HOME}/.config/ghostty/config"
    
    # Nano
    deploy_config "${CONFIG_DIR}/nano/.nanorc" "${HOME}/.nanorc"
    
    # Vim
    deploy_config "${CONFIG_DIR}/vim/.vimrc" "${HOME}/.vimrc"
    
    # Neovim
    deploy_config "${CONFIG_DIR}/nvim/init.lua" "${HOME}/.config/nvim/init.lua"
    
    # Yazi
    deploy_config "${CONFIG_DIR}/yazi/yazi.toml" "${HOME}/.config/yazi/yazi.toml"
    deploy_config "${CONFIG_DIR}/yazi/keymap.toml" "${HOME}/.config/yazi/keymap.toml"
    deploy_config "${CONFIG_DIR}/yazi/theme.toml" "${HOME}/.config/yazi/theme.toml"
    
    # btop
    deploy_config "${CONFIG_DIR}/btop/btop.conf" "${HOME}/.config/btop/btop.conf"
    
    # tmux
    deploy_config "${CONFIG_DIR}/tmux/.tmux.conf" "${HOME}/.tmux.conf"
    
    # cava
    deploy_config "${CONFIG_DIR}/cava/config" "${HOME}/.config/cava/config"
    
    # bat
    deploy_config "${CONFIG_DIR}/bat/config" "${HOME}/.config/bat/config"
}

# ============================================================================
# Zsh as Default Shell
# ============================================================================

set_zsh_default() {
    local current_shell=$(basename "$SHELL")
    
    if [[ "$current_shell" == "zsh" ]]; then
        log_info "Zsh is already the default shell"
        return 0
    fi
    
    if confirm "Set Zsh as default shell?"; then
        if $DRY_RUN; then
            log_info "[DRY-RUN] Would change default shell to zsh"
        else
            chsh -s "$(which zsh)"
            log_success "Default shell changed to Zsh (restart terminal to apply)"
        fi
    fi
}

# ============================================================================
# Font Installation
# ============================================================================

install_font() {
    local font_name="CascadiaCode"
    local font_dir="${HOME}/.local/share/fonts"
    
    # Check if already installed
    if fc-list | grep -qi "Cascadia"; then
        log_info "Cascadia Code Nerd Font already installed"
        return 0
    fi
    
    log_step "Installing Cascadia Code Nerd Font..."
    
    if $DRY_RUN; then
        log_info "[DRY-RUN] Would install Cascadia Code Nerd Font"
        return 0
    fi
    
    mkdir -p "$font_dir"
    
    local temp_dir=$(mktemp -d)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
    
    curl -sL "$font_url" -o "${temp_dir}/CascadiaCode.zip" || {
        log_error "Failed to download font"
        return 1
    }
    
    unzip -q "${temp_dir}/CascadiaCode.zip" -d "${temp_dir}/font"
    cp "${temp_dir}/font"/*.ttf "$font_dir/" 2>/dev/null || \
    cp "${temp_dir}/font"/**/*.ttf "$font_dir/" 2>/dev/null || true
    
    rm -rf "$temp_dir"
    
    # Update font cache
    fc-cache -f
    
    log_success "Cascadia Code Nerd Font installed"
}

# ============================================================================
# Verification
# ============================================================================

verify_installation() {
    log_step "Verifying installation..."
    
    local tools=(
        "zsh:zsh --version"
        "starship:starship --version"
        "nvim:nvim --version | head -1"
        "yazi:yazi --version"
        "eza:eza --version"
        "btop:btop --version"
        "fzf:fzf --version"
        "bat:bat --version"
        "tmux:tmux -V"
    )
    
    local failed=0
    
    for tool_cmd in "${tools[@]}"; do
        local tool="${tool_cmd%%:*}"
        local cmd="${tool_cmd#*:}"
        
        if command -v "$tool" &>/dev/null; then
            local version=$(eval "$cmd" 2>/dev/null | head -1)
            log_success "$tool: $version"
        else
            log_warning "$tool: not found"
            ((failed++)) || true
        fi
    done
    
    if [[ $failed -gt 0 ]]; then
        log_warning "$failed tool(s) not found. Some features may not work."
    else
        log_success "All tools verified!"
    fi
}

# ============================================================================
# Print Summary
# ============================================================================

print_summary() {
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo -e "Backups saved to: ${CYAN}${BACKUP_DIR}${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "  1. Restart your terminal or run: ${CYAN}exec zsh${NC}"
    echo -e "  2. Open Neovim to install plugins: ${CYAN}nvim${NC}"
    echo -e "  3. Configure Ghostty if needed: ${CYAN}~/.config/ghostty/config${NC}"
    echo ""
    echo -e "Useful commands:"
    echo -e "  ${CYAN}y${NC}     - Yazi file manager"
    echo -e "  ${CYAN}bt${NC}    - btop system monitor"
    echo -e "  ${CYAN}t${NC}     - tmux"
    echo -e "  ${CYAN}cava${NC}  - Audio visualizer"
    echo ""
}

# ============================================================================
# Help
# ============================================================================

print_help() {
    echo "Cross-Distro Terminal Setup - Installation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without making changes"
    echo "  --verbose    Show detailed output"
    echo "  --help       Show this help message"
    echo ""
    echo "Supported distributions:"
    echo "  - Arch Linux (and derivatives: Manjaro, EndeavourOS, etc.)"
    echo "  - Fedora"
    echo "  - Debian/Ubuntu (and derivatives)"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                log_info "Running in dry-run mode"
                ;;
            --verbose)
                VERBOSE=true
                set -x
                ;;
            --help|-h)
                print_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
        shift
    done
    
    echo -e "${CYAN}"
    echo "============================================"
    echo "  Cross-Distro Terminal Setup"
    echo "============================================"
    echo -e "${NC}"
    
    # Step 1: Detect distribution
    detect_distro
    
    # Step 2: Check AUR helper (Arch only)
    check_aur_helper
    
    # Step 3: Get packages
    get_packages
    
    # Step 4: Install packages
    log_step "Installing packages..."
    install_packages "${PACKAGES[@]}"
    
    # Step 5: Install AUR packages (Arch only)
    if [[ "${DISTRO}" == "arch" ]] && [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
        install_aur_packages "${AUR_PACKAGES[@]}"
    fi
    
    # Step 6: Install font
    install_font
    
    # Step 7: Deploy configs
    deploy_all_configs
    
    # Step 8: Set Zsh as default
    set_zsh_default
    
    # Step 9: Verify
    verify_installation
    
    # Step 10: Summary
    if ! $DRY_RUN; then
        print_summary
    fi
    
    log_success "Done!"
}

# Run main
main "$@"
