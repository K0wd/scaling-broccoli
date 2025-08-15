#!/bin/bash

echo "🎮 Setting up 2048 Godot Game development environment..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew already installed"
fi

# Make sure Homebrew is in PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# Check if Godot is installed
if ! command -v godot &> /dev/null; then
    echo "🎮 Installing Godot Engine..."
    brew install --cask godot
    echo "✅ Godot Engine installed"
else
    echo "✅ Godot Engine already installed"
fi

# Set up Git if not already configured
if ! git config --global user.name &> /dev/null; then
    echo "🔧 Setting up Git configuration..."
    echo "Please enter your Git username:"
    read git_username
    echo "Please enter your Git email:"
    read git_email
    
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    echo "✅ Git configured"
else
    echo "✅ Git already configured"
fi

# Initialize Git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit"
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already initialized"
fi

echo "🎉 Setup complete! You can now open the project in Godot Engine."
echo "
To run the game:
1. Open Godot Engine
2. Click 'Import'
3. Navigate to this directory and select 'project.godot'
4. Click 'Run Project' or press F5
" 