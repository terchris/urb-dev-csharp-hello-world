#!/bin/bash
# file: .devcontainer/additions/install-dev-csharp.sh
#
# Usage: ./install-dev-csharp.sh [options] [dotnet-install-parameters]
# 
# Options:
#   --debug     : Enable debug output for troubleshooting
#   --uninstall : Remove installed components instead of installing them
#   --force     : Force installation/uninstallation even if there are dependencies
#
# Examples:
#   ./install-dev-csharp.sh --channel 8.0
#   ./install-dev-csharp.sh --version 8.0.100
#   ./install-dev-csharp.sh --channel LTS
#   ./install-dev-csharp.sh --runtime dotnet --version 8.0.0
#
#------------------------------------------------------------------------------
# CONFIGURATION - Modify this section for each new script
#------------------------------------------------------------------------------

# Script metadata - must be at the very top of the configuration section
SCRIPT_NAME="Microsoft .NET SDK"
SCRIPT_DESCRIPTION="Installs Microsoft .NET SDK, C# language support, and Azure Functions extensions for full .NET development"

# Detect system architecture
detect_architecture() {
    if command -v dpkg > /dev/null 2>&1; then
        ARCH=$(dpkg --print-architecture)
    elif command -v uname > /dev/null 2>&1; then
        local unamem=$(uname -m)
        if [[ "$unamem" == "aarch64" || "$unamem" == "arm64" ]]; then
            ARCH="arm64"
        elif [[ "$unamem" == "x86_64" ]]; then
            ARCH="amd64"
        else
            ARCH="$unamem"
        fi
    else
        ARCH="unknown"
    fi
    echo "$ARCH"
}

# Before running installation, we need to add any required repositories or setup
pre_installation_setup() {
    if [ "${UNINSTALL_MODE}" -eq 1 ]; then
        echo "🔧 Preparing for uninstallation..."
    else
        echo "🔧 Performing pre-installation setup..."
        
        # Detect system architecture
        SYSTEM_ARCH=$(detect_architecture)
        echo "🖥️ Detected system architecture: $SYSTEM_ARCH"
        
        # Check if .NET is already installed
        if command -v dotnet >/dev/null 2>&1; then
            local current_version
            current_version=$(dotnet --version)
            echo "⚠️ .NET SDK is already installed (version $current_version)"
            echo "Continuing will install the requested version alongside the existing one."
        fi
        
        # Check for ARM architecture and warn about Azure Functions limitations
        if [[ "$SYSTEM_ARCH" == "arm64" || "$SYSTEM_ARCH" == "armhf" || "$SYSTEM_ARCH" == "arm" ]]; then
            echo "⚠️ WARNING: Azure Functions Core Tools have limited support on ARM processors."
            echo "   The npm package may not work properly on this architecture."
            echo "   Only Azurite will be installed from Node.js packages."
            # Remove azure-functions-core-tools from NODE_PACKAGES
            # This is done dynamically by filtering the array
            NODE_PACKAGES=()
            for pkg in "${ORIGINAL_NODE_PACKAGES[@]}"; do
                if [[ "$pkg" != *"azure-functions-core-tools"* ]]; then
                    NODE_PACKAGES+=("$pkg")
                fi
            done
        fi
    fi
}

# Define Node.js packages
ORIGINAL_NODE_PACKAGES=(
    "azure-functions-core-tools@4"
    "azurite"
)
# Initialize NODE_PACKAGES (will be modified in pre_installation_setup based on architecture)
NODE_PACKAGES=("${ORIGINAL_NODE_PACKAGES[@]}")

# Define VS Code extensions
declare -A EXTENSIONS
EXTENSIONS["ms-dotnettools.csdevkit"]="C# Dev Kit|Complete C# development experience"
EXTENSIONS["ms-dotnettools.csharp"]="C#|C# language support"
EXTENSIONS["ms-dotnettools.vscode-dotnet-runtime"]="NET Runtime|.NET runtime support"
EXTENSIONS["ms-azuretools.vscode-azurefunctions"]="Azure Functions|Azure Functions development"
EXTENSIONS["ms-azuretools.azure-dev"]="Azure Developer CLI|Project scaffolding and management"
EXTENSIONS["ms-azuretools.vscode-bicep"]="Bicep|Azure Bicep language support for IaC"

# Define verification commands to run after installation
VERIFY_COMMANDS=(
    "command -v dotnet >/dev/null && dotnet --version || echo '❌ .NET SDK not found'"
    "dotnet --list-sdks || echo '❌ Failed to list .NET SDKs'"
)

# Post-installation notes
post_installation_message() {
    local dotnet_version
    local func_version
    local azurite_version
    local system_arch=$(detect_architecture)
    
    if command -v dotnet >/dev/null 2>&1; then
        dotnet_version=$(dotnet --version)
    else
        dotnet_version="not installed"
    fi

    if command -v func >/dev/null 2>&1; then
        func_version=$(func --version 2>/dev/null || echo "installed but version check failed")
    else
        func_version="not installed"
    fi

    if command -v azurite >/dev/null 2>&1; then
        azurite_version="installed"
    else
        azurite_version="not installed"
    fi

    echo
    echo "🎉 Installation process complete for: $SCRIPT_NAME!"
    echo "Purpose: $SCRIPT_DESCRIPTION"
    echo
    echo "Important Notes:"
    echo "1. .NET SDK $dotnet_version is installed"
    echo "2. Azurite Storage Emulator: $azurite_version"
    echo "3. Path has been updated to include .NET SDK"
    
    if [[ "$system_arch" == "arm64" || "$system_arch" == "armhf" || "$system_arch" == "arm" ]]; then
        echo "4. NOTICE: Azure Functions Core Tools were not installed as they have limited support on ARM processors"
        echo "   If you need to use Azure Functions, consider using a x64 (amd64) environment instead."
    else
        echo "4. Azure Functions Core Tools $func_version"
    fi
    
    echo "5. You may need to restart your terminal or source your .bashrc"
    echo
    echo "Quick Start Commands:"
    echo "- Create new console app: dotnet new console -o MyApp"
    echo "- Create new web API: dotnet new webapi -o MyApi"
    
    if [[ "$system_arch" != "arm64" && "$system_arch" != "armhf" && "$system_arch" != "arm" ]]; then
        echo "- Create new Azure Function: func init MyFunction --dotnet"
    fi
    
    echo "- Run project: dotnet run"
    echo "- Build project: dotnet build"
    echo "- Run tests: dotnet test"
    echo "- Start Azurite: azurite --silent"
    echo
    echo "Documentation Links:"
    echo "- Local Guide: .devcontainer/howto/howto-dev-csharp.md"
    echo "- .NET Documentation: https://learn.microsoft.com/dotnet/"
    echo "- Azure Functions: https://learn.microsoft.com/azure/azure-functions/"
    echo "- C# Dev Kit: https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csdevkit"
    echo "- Azure Functions Core Tools: https://github.com/Azure/azure-functions-core-tools"
    echo "- Azurite Storage Emulator: https://github.com/Azure/Azurite"
    echo
    echo "Installation Status:"
    if command -v dotnet >/dev/null 2>&1; then
        echo "1. .NET Information:"
        dotnet --info | grep -E "Version|OS|RID"
        echo
        echo "2. Installed SDKs:"
        dotnet --list-sdks
        echo
        echo "3. Installed Runtimes:"
        dotnet --list-runtimes
        echo
        if command -v func >/dev/null 2>&1; then
            echo "4. Azure Functions Core Tools:"
            func --version 2>/dev/null || echo "Version check failed, but tool is installed"
        elif [[ "$system_arch" == "arm64" || "$system_arch" == "armhf" || "$system_arch" == "arm" ]]; then
            echo "4. Azure Functions Core Tools: Not installed (ARM architecture)"
        else
            echo "4. Azure Functions Core Tools: Not installed"
        fi
    else
        echo "❌ .NET SDK installation could not be verified"
    fi
}

# Post-uninstallation notes
post_uninstallation_message() {
    echo
    echo "🏁 Uninstallation process complete for: $SCRIPT_NAME!"
    echo
    echo "Additional Notes:"
    echo "1. Global .NET tools remain in ~/.dotnet/tools"
    echo "2. NuGet package cache remains in ~/.nuget"
    echo "3. User settings and configurations remain unchanged"
    echo "4. Node.js packages may require manual cleanup with npm uninstall -g"
    echo "5. See the local guide for additional cleanup steps:"
    echo "   .devcontainer/howto/howto-dev-csharp.md"
    
    # Check for remaining components
    echo
    echo "Checking for remaining components..."
    
    if command -v dotnet >/dev/null 2>&1; then
        echo "⚠️  Warning: .NET SDK is still installed"
        echo "To completely remove .NET, run:"
        echo "  rm -rf ~/.dotnet"
    fi
    
    if command -v func >/dev/null 2>&1; then
        echo "⚠️  Warning: Azure Functions Core Tools is still installed"
        echo "To remove it, run: npm uninstall -g azure-functions-core-tools"
    fi
    
    if command -v azurite >/dev/null 2>&1; then
        echo "⚠️  Warning: Azurite is still installed"
        echo "To remove it, run: npm uninstall -g azurite"
    fi
    
    # Check for remaining VS Code extensions
    if code --list-extensions 2>/dev/null | grep -qE "ms-dotnettools|ms-azuretools"; then
        echo
        echo "⚠️  Note: Some VS Code extensions are still installed"
        echo "To remove them, run:"
        for ext_id in "${!EXTENSIONS[@]}"; do
            echo "code --uninstall-extension $ext_id"
        done
    fi
}

# Custom installation function for dotnet SDK
install_dotnet_sdk() {
    local dotnet_install_args="$1"
    
    echo "📥 Downloading .NET installation script..."
    curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
    chmod +x dotnet-install.sh
    
    echo "⚠️ Warning: The .NET SDK download and installation may take several minutes depending on your internet connection."
    echo "🔄 Installing .NET SDK with parameters: $dotnet_install_args"
    echo "Please be patient..."
    
    # Run the installation script with the provided arguments
    ./dotnet-install.sh $dotnet_install_args
    
    echo "🔧 Updating PATH configuration..."
    if ! grep -q 'export PATH="$PATH:$HOME/.dotnet"' ~/.bashrc; then
        echo 'export PATH="$PATH:$HOME/.dotnet"' >> ~/.bashrc
    fi
    
    # Update current session PATH
    export PATH="$PATH:$HOME/.dotnet"
    
    # Cleanup
    rm dotnet-install.sh
    
    return 0
}

#------------------------------------------------------------------------------
# STANDARD SCRIPT LOGIC - Do not modify anything below this line
#------------------------------------------------------------------------------

# Initialize mode flags
DEBUG_MODE=0
UNINSTALL_MODE=0
FORCE_MODE=0

# Parse command line arguments
SCRIPT_ARGS=()
DOTNET_INSTALL_ARGS=()
parse_args=1

while [[ $# -gt 0 && $parse_args -eq 1 ]]; do
    case $1 in
        --debug)
            DEBUG_MODE=1
            SCRIPT_ARGS+=("$1")
            shift
            ;;
        --uninstall)
            UNINSTALL_MODE=1
            SCRIPT_ARGS+=("$1")
            shift
            ;;
        --force)
            FORCE_MODE=1
            SCRIPT_ARGS+=("$1")
            shift
            ;;
        --)
            parse_args=0
            shift
            ;;
        *)
            # Assume all other arguments are for dotnet-install.sh
            DOTNET_INSTALL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Add any remaining arguments after -- to dotnet-install-args
while [[ $# -gt 0 ]]; do
    DOTNET_INSTALL_ARGS+=("$1")
    shift
done

# Export mode flags for core scripts
export DEBUG_MODE
export UNINSTALL_MODE
export FORCE_MODE

# Source all core installation scripts
source "$(dirname "$0")/core-install-apt.sh"
source "$(dirname "$0")/core-install-node.sh"
source "$(dirname "$0")/core-install-extensions.sh"
source "$(dirname "$0")/core-install-pwsh.sh"
source "$(dirname "$0")/core-install-python-packages.sh"

# Add architecture-specific verification commands
if [[ "$(detect_architecture)" != "arm64" && "$(detect_architecture)" != "armhf" && "$(detect_architecture)" != "arm" ]]; then
    VERIFY_COMMANDS+=(
        "command -v func >/dev/null && func --version || echo '❌ Azure Functions Core Tools not found'"
    )
fi
VERIFY_COMMANDS+=(
    "command -v azurite >/dev/null && echo '✅ Azurite is installed' || echo '❌ Azurite not found'"
)

# Function to process installations using core script functions
process_installations() {
    # Process Node.js packages if array is not empty
    if [ ${#NODE_PACKAGES[@]} -gt 0 ]; then
        process_node_packages "NODE_PACKAGES"
    fi

    # Process VS Code extensions if array is not empty
    if [ ${#EXTENSIONS[@]} -gt 0 ]; then
        process_extensions "EXTENSIONS"
    fi
}

# Function to verify installations
verify_installations() {
    if [ ${#VERIFY_COMMANDS[@]} -gt 0 ]; then
        echo
        echo "🔍 Verifying installations..."
        for cmd in "${VERIFY_COMMANDS[@]}"; do
            eval "$cmd"
        done
    fi
}

# Check if we have dotnet-install parameters when in install mode
if [ "${UNINSTALL_MODE}" -eq 0 ] && [ ${#DOTNET_INSTALL_ARGS[@]} -eq 0 ]; then
    echo "Usage: $0 [script_options] [dotnet-install-parameters]"
    echo "Error: You must provide at least one parameter for the dotnet-install.sh script."
    echo "Examples:"
    echo "  $0 --channel 8.0"
    echo "  $0 --version 8.0.100"
    echo "  $0 --channel LTS"
    echo "For more help, run: $0 --help"
    exit 1
fi

# Main execution
if [ "${UNINSTALL_MODE}" -eq 1 ]; then
    echo "🔄 Starting uninstallation process for: $SCRIPT_NAME"
    echo "Purpose: $SCRIPT_DESCRIPTION"
    pre_installation_setup
    
    # Use our custom uninstall function for dotnet
    if [ -d "$HOME/.dotnet" ]; then
        echo "Removing .NET SDK directory..."
        rm -rf "$HOME/.dotnet"
        # Remove PATH entry from .bashrc
        if grep -q 'export PATH="$PATH:$HOME/.dotnet"' ~/.bashrc; then
            sed -i '/export PATH="$PATH:$HOME\/.dotnet"/d' ~/.bashrc
        fi
        echo "🧹 .NET SDK has been removed."
    fi
    
    # Use core functions for uninstalling packages
    process_installations
    
    if [ ${#EXTENSIONS[@]} -gt 0 ]; then
        for ext_id in "${!EXTENSIONS[@]}"; do
            IFS='|' read -r name description _ <<< "${EXTENSIONS[$ext_id]}"
            check_extension_state "$ext_id" "uninstall" "$name"
        done
    fi
    
    post_uninstallation_message
else
    echo "🔄 Starting installation process for: $SCRIPT_NAME"
    echo "Purpose: $SCRIPT_DESCRIPTION"
    pre_installation_setup
    
    # Use our custom install function for dotnet
    install_dotnet_sdk "${DOTNET_INSTALL_ARGS[*]}"
    
    # Use core functions for installing packages
    process_installations
    
    verify_installations
    
    if [ ${#EXTENSIONS[@]} -gt 0 ]; then
        for ext_id in "${!EXTENSIONS[@]}"; do
            IFS='|' read -r name description _ <<< "${EXTENSIONS[$ext_id]}"
            check_extension_state "$ext_id" "install" "$name"
        done
    fi
    
    post_installation_message
fi