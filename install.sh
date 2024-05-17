#!/bin/bash

# Determine the OS type
OS_TYPE=$(uname)

# Determine the shell profile to use based on the user's default shell
SHELL_PROFILE=""

case "$SHELL" in
    */zsh)
        SHELL_PROFILE="$HOME/.zshrc"
        ;;
    */bash)
        SHELL_PROFILE="$HOME/.bashrc"
        ;;
    */fish)
        SHELL_PROFILE="$HOME/.config/fish/config.fish"
        ;;
    *)
        echo "Unsupported shell. Please use bash, zsh, or fish."
        exit 1
        ;;
esac

# Ensure the utility scripts directory exists
TOOL_DIR="$HOME/handyscripts"
mkdir -p "$TOOL_DIR"

# Ask for the name of the tool
read -p "What is the name of this tool? (use a short name for ease): " tool_name

# Create the main tool script
TOOL_SCRIPT="$TOOL_DIR/$tool_name"
echo "#!/bin/bash" > "$TOOL_SCRIPT"
echo "" >> "$TOOL_SCRIPT"
echo "case \"\$1\" in" >> "$TOOL_SCRIPT"
echo "  -h|--help)" >> "$TOOL_SCRIPT"
echo "    echo \"Available commands:\"" >> "$TOOL_SCRIPT"
echo "    grep -E '^ *[a-zA-Z_-]+ *\)' \$0 | sed 's/) *# */: /'" >> "$TOOL_SCRIPT"
echo "    ;;" >> "$TOOL_SCRIPT"
echo "esac" >> "$TOOL_SCRIPT"
echo "" >> "$TOOL_SCRIPT"
echo "# Add new commands below this line" >> "$TOOL_SCRIPT"

# Make the tool script executable
chmod +x "$TOOL_SCRIPT"

# Add tool script to PATH by updating the shell profile
if [[ ":$PATH:" != *":$TOOL_DIR:"* ]]; then
    echo "export PATH=\"\$PATH:$TOOL_DIR\"" >> "$SHELL_PROFILE"
fi

# Function to add new script commands
add_script() {
    script_name=$1
    script_path="$TOOL_DIR/$script_name"

    # Add new case entry to the tool script
    echo "" >> "$TOOL_SCRIPT"
    echo "$script_name)" >> "$TOOL_SCRIPT"
    echo "  shift" >> "$TOOL_SCRIPT"
    echo "  bash $script_path \"\$@\"" >> "$TOOL_SCRIPT"
    echo "  ;; # $script_name" >> "$TOOL_SCRIPT"
}

# Check if 'add' command is used
if [[ "$1" == "add" ]]; then
    add_script $2
    echo "Script $2 added successfully!"
fi

echo "Installed successfully! Please restart your terminal or run 'source $SHELL_PROFILE' to update your PATH."
echo "You can now use the tool with the command: $tool_name"
echo "To add a new script, use the command: $tool_name add <script_name>"
