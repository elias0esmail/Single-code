#!/bin/sh
# ohmyzsh_install_alpine.sh
# Alpine Linux + Acode: install Oh My Zsh with autosuggestions and syntax highlighting

set -e  # exit on any error

echo "[INFO] Step 1: Update and upgrade packages"
apk update && apk upgrade

echo "[INFO] Step 2: Install required base packages"
apk add git zsh curl nano ncurses

# ----------------------------------------------------------------------
# Step 3: Install Oh My Zsh into /public/.oh-my-zsh (if not already present)
# ----------------------------------------------------------------------
OMZ_DIR="/public/.oh-my-zsh"
if [ -d "$OMZ_DIR" ]; then
    echo "[INFO] $OMZ_DIR already exists. Skipping Oh My Zsh installation."
else
    echo "[INFO] Installing Oh My Zsh into $OMZ_DIR"
    # RUNZSH=no : do not start zsh after install
    # CHSH=no    : do not change default shell automatically
    # ZSH=...    : set custom install directory
    export ZSH="$OMZ_DIR"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ----------------------------------------------------------------------
# Step 4: Install zsh-autosuggestions plugin
# ----------------------------------------------------------------------
AUTOSUGGEST_DIR="$OMZ_DIR/custom/plugins/zsh-autosuggestions"
if [ -d "$AUTOSUGGEST_DIR" ]; then
    echo "[INFO] zsh-autosuggestions already present. Skipping."
else
    echo "[INFO] Cloning zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGEST_DIR"
fi

# ----------------------------------------------------------------------
# Step 5: Install zsh-syntax-highlighting plugin
# ----------------------------------------------------------------------
SYNTAX_DIR="$OMZ_DIR/custom/plugins/zsh-syntax-highlighting"
if [ -d "$SYNTAX_DIR" ]; then
    echo "[INFO] zsh-syntax-highlighting already present. Skipping."
else
    echo "[INFO] Cloning zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_DIR"
fi

# ----------------------------------------------------------------------
# Step 6: Modify ~/.zshrc – replace plugins line
# ----------------------------------------------------------------------
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    echo "[INFO] Updating plugins list in $ZSHRC"
    # Replace 'plugins=(git)' with 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)'
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' "$ZSHRC"
    # Fallback: if the line does not exist, append the correct one
    if ! grep -q "^plugins=(" "$ZSHRC"; then
        echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
    fi
else
    echo "[WARN] $ZSHRC not found. Creating a minimal one."
    echo 'export ZSH="/public/.oh-my-zsh"' > "$ZSHRC"
    echo 'ZSH_THEME="robbyrussell"' >> "$ZSHRC"
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
    echo 'source $ZSH/oh-my-zsh.sh' >> "$ZSHRC"
fi

# ----------------------------------------------------------------------
# Step 7: Ensure ZSH export points to /public/.oh-my-zsh
# ----------------------------------------------------------------------
echo "[INFO] Setting correct ZSH path in $ZSHRC"
sed -i 's|^export ZSH=.*|export ZSH="/public/.oh-my-zsh"|g' "$ZSHRC"

# ----------------------------------------------------------------------
# Step 8: Make oh-my-zsh.sh executable
# ----------------------------------------------------------------------
if [ -f "$OMZ_DIR/oh-my-zsh.sh" ]; then
    echo "[INFO] Making $OMZ_DIR/oh-my-zsh.sh executable"
    chmod +x "$OMZ_DIR/oh-my-zsh.sh"
else
    echo "[ERROR] $OMZ_DIR/oh-my-zsh.sh not found. Installation might be incomplete."
    exit 1
fi

# ----------------------------------------------------------------------
# Step 9: Add zsh launch snippet to ~/.bashrc
# ----------------------------------------------------------------------
BASHRC="$HOME/.bashrc"
SNIPPET='if [ -t 1 ]; then
    exec zsh
fi'

if [ -f "$BASHRC" ]; then
    if grep -q "exec zsh" "$BASHRC"; then
        echo "[INFO] .bashrc already contains exec zsh. Skipping."
    else
        echo "[INFO] Appending zsh launcher to $BASHRC"
        echo "$SNIPPET" >> "$BASHRC"
    fi
else
    echo "[INFO] .bashrc not found. Creating it with the launcher."
    echo "$SNIPPET" > "$BASHRC"
fi

# ----------------------------------------------------------------------
# Step 10: Close the terminal (exit the current shell)
# ----------------------------------------------------------------------
echo "[SUCCESS] Oh My Zsh setup is complete. Closing terminal now."
exit 0
exit 0