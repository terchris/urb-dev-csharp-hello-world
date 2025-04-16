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
# CONFIGURATION
#------------------------------------------------------------------------------

# Script metadata
SCRIPT_NAME="Microsoft .NET SDK"
SCRIPT_DESCRIPTION="Installs Microsoft .NET SDK, C# language support, and Azure Functions extensions for full .NET development"

# Before running installation
pre_installation_setup() {
    if [ "${UNINSTALL_MODE}" -eq 1 ]; then
        echo "🔧 Preparing for uninstallation..."
    else
        echo "🔧 Performing pre-installation setup..."
        
        # Check if .NET is already installed
        if command -v dotnet >/dev/null 2>&1; then
            local current_version
            current_version=$(dotnet --version)
            echo "⚠️ .NET SDK is already installed (version $current_version)"
            echo "Continuing will install the requested version alongside the existing one."
        fi

        # Setup Node.js environment for Azure Functions
        if command -v npm >/dev/null 2>&1; then
            echo "✅ Node.js is installed ($(node --version))"
        else
            echo "⚠️ Node.js not found. Azure Functions Core Tools requires Node.js."
            echo "Please ensure Node.js is installed in the base container."
        fi
    fi
}

# Define Node.js packages (for Azure Functions Core Tools)
NODE_PACKAGES=(
    "azure-functions-core-tools@4"
    "azurite"
)

# Define VS Code extensions
declare -A EXTENSIONS
EXTENSIONS["ms-dotnettools.csdevkit"]="C# Dev Kit|Complete C# development experience"
EXTENSIONS["ms-dotnettools.csharp"]="C#|C# language support"
EXTENSIONS["ms-dotnettools.vscode-dotnet-runtime"]="NET Runtime|.NET runtime support"
EXTENSIONS["ms-azuretools.vscode-azurefunctions"]="Azure Functions|Azure Functions development"
EXTENSIONS["ms-azuretools.azure-dev"]="Azure Developer CLI|Project scaffolding and management"
EXTENSIONS["ms-azuretools.vscode-bicep"]="Bicep|Azure Bicep language support for IaC"

# Define verification commands
VERIFY_COMMANDS=(
    "command -v dotnet >/dev/null && dotnet --version || echo '❌ .NET SDK not found'"
    "dotnet --list-sdks || echo '❌ Failed to list .NET SDKs'"
    "command -v func >/dev/null && func --version || echo '❌ Azure Functions Core Tools not found'"
    "command -v azurite >/dev/null && echo '✅ Azurite is installed' || echo '❌ Azurite not found'"
)

# Post-installation notes
post_installation_message() {
    local dotnet_version
    local func_version
    local azurite_version
    
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
    echo "2. Azure Functions Core Tools $func_version"
    echo "3. Azurite Storage Emulator: $azurite_version"
    echo "4. Path has been updated to include .NET SDK"
    echo "5. You may need to restart your terminal or source your .bashrc"
    echo
    echo "Quick Start Commands:"
    echo "- Create new console app: dotnet new console -o MyApp"
    echo "- Create new web API: dotnet new webapi -o MyApi"
    echo "- Create new Azure Function: func init MyFunction --dotnet"
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
        echo "code --uninstall-extension ms-dotnettools.csdevkit"
        echo "code --uninstall-extension ms-dotnettools.csharp"
        echo "code --uninstall-extension ms-dotnettools.vscode-dotnet-runtime"
        echo "code --uninstall-extension ms-azuretools.vscode-azurefunctions"
        echo "code --uninstall-extension ms-azuretools.azure-dev"
        echo "code --uninstall-extension ms-azuretools.vscode-bicep"
    fi
}

# Custom installation function
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

# Install Node.js packages
install_node_packages() {
    echo "📦 Installing Node.js packages for Azure development..."
    
    if ! command -v npm >/dev/null 2>&1; then
        echo "❌ Error: npm not found. Cannot install Node.js packages."
        return 1
    fi
    
    for package in "${NODE_PACKAGES[@]}"; do
        echo "Installing $package..."
        npm install -g "$package"
    done
    
    # Verify installations
    if command -v func >/dev/null 2>&1; then
        echo "✅ Azure Functions Core Tools installed"
        func --version 2>/dev/null || echo "Version check failed, but tool is installed"
    else
        echo "❌ Azure Functions Core Tools installation failed"
    fi
    
    if command -v azurite >/dev/null 2>&1; then
        echo "✅ Azurite Storage Emulator installed"
    else
        echo "❌ Azurite installation failed"
    fi
    
    return 0
}

# Custom uninstallation function
uninstall_dotnet_sdk() {
    echo "🗑️ Removing .NET SDK installation..."
    
    # Check if .NET directory exists
    if [ -d "$HOME/.dotnet" ]; then
        echo "Removing .NET SDK directory..."
        rm -rf "$HOME/.dotnet"
    else
        echo ".NET SDK directory not found."
    fi
    
    # Remove PATH entry from .bashrc
    echo "Updating PATH configuration..."
    if grep -q 'export PATH="$PATH:$HOME/.dotnet"' ~/.bashrc; then
        sed -i '/export PATH="$PATH:$HOME\/.dotnet"/d' ~/.bashrc
    fi
    
    echo "🧹 .NET SDK has been removed."
    return 0
}

# Uninstall Node.js packages
uninstall_node_packages() {
    echo "🗑️ Removing Node.js packages..."
    
    if ! command -v npm >/dev/null 2>&1; then
        echo "❌ Error: npm not found. Cannot uninstall Node.js packages."
        return 1
    fi
    
    for package in "${NODE_PACKAGES[@]}"; do
        local pkg_name=$(echo "$package" | cut -d '@' -f 1)
        echo "Uninstalling $pkg_name..."
        npm uninstall -g "$pkg_name" || true
    done
    
    echo "🧹 Node.js packages have been removed."
    return 0
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

# Print usage examples
print_usage_examples() {
    echo "Usage: $0 [script_options] [dotnet-install-parameters]"
    echo
    echo "Script Options:"
    echo "  --debug     : Enable debug output for troubleshooting"
    echo "  --uninstall : Remove installed components instead of installing them"
    echo "  --force     : Force installation/uninstallation even if there are dependencies"
    echo
    echo "Examples of dotnet-install parameters:"
    echo "  --channel 8.0              : Install the latest 8.0 SDK"
    echo "  --version 8.0.100          : Install a specific SDK version"
    echo "  --channel LTS              : Install the latest Long Term Support version"
    echo "  --runtime dotnet --channel 8.0 : Install just the .NET runtime"
    echo
    echo "For complete documentation, see: https://learn.microsoft.com/dotnet/core/tools/dotnet-install-script"
    echo
    echo "You must provide at least one parameter for the dotnet-install.sh script."
    exit 1
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

# Source extensions script for VS Code extension handling
if [ -f "$(dirname "$0")/core-install-extensions.sh" ]; then
    source "$(dirname "$0")/core-install-extensions.sh"
fi

# Source Node.js installation script if available
if [ -f "$(dirname "$0")/core-install-node.sh" ]; then
    source "$(dirname "$0")/core-install-node.sh"
fi

# Check if we have dotnet-install parameters when in install mode
if [ "${UNINSTALL_MODE}" -eq 0 ] && [ ${#DOTNET_INSTALL_ARGS[@]} -eq 0 ]; then
    print_usage_examples
fi

# Main execution
if [ "${UNINSTALL_MODE}" -eq 1 ]; then
    echo "🔄 Starting uninstallation process for: $SCRIPT_NAME"
    echo "Purpose: $SCRIPT_DESCRIPTION"
    pre_installation_setup
    uninstall_dotnet_sdk
    uninstall_node_packages
    if [ ${#EXTENSIONS[@]} -gt 0 ] && command -v check_extension_state >/dev/null 2>&1; then
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
    install_dotnet_sdk "${DOTNET_INSTALL_ARGS[*]}"
    install_node_packages
    verify_installations
    if [ ${#EXTENSIONS[@]} -gt 0 ] && command -v check_extension_state >/dev/null 2>&1; then
        for ext_id in "${!EXTENSIONS[@]}"; do
            IFS='|' read -r name description _ <<< "${EXTENSIONS[$ext_id]}"
            check_extension_state "$ext_id" "install" "$name"
        done
    fi
    post_installation_message
fi