# 2048 Godot Game

A recreation of the classic 2048 game built with Godot Engine.

## Prerequisites

- [Godot Engine](https://godotengine.org/download) (Standard version)
- Git (for version control)

## Installation on macOS

### Method 1: Using the Setup Script

1. Open Terminal
2. Navigate to the project directory
3. Run the setup script:
```bash
chmod +x setup_macos.sh
./setup_macos.sh
```

### Method 2: Manual Installation

1. Install Homebrew (if not already installed):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install Godot using Homebrew:
```bash
brew install --cask godot
```

3. Clone the repository (if you haven't already):
```bash
git clone <your-repository-url>
cd 2048-godot
```

## Running the Game

1. Open Godot Engine
2. Click "Import"
3. Navigate to the project directory and select `project.godot`
4. Once imported, click "Run Project" (or press F5)

## Project Structure

- `scenes/` - Contains all game scenes
  - `Game2048.tscn` - Main game scene
  - `Leaderboard.tscn` - Leaderboard scene
  - `MainMenu.tscn` - Main menu scene
  - `Tile.tscn` - Tile scene component

- `scripts/` - Contains all GDScript files
  - `Game2048.gd` - Main game logic
  - `GameManager.gd` - Game state management
  - `Leaderboard.gd` - Leaderboard functionality
  - `MainMenu.gd` - Menu navigation
  - `ScoreManager.gd` - Score tracking
  - `SoundManager.gd` - Audio management
  - `Tile.gd` - Tile behavior

- `assets/` - Contains game assets
  - `sounds/` - Sound effects

## Controls

- Arrow keys or WASD: Move tiles
- ESC: Pause/Menu
- R: Restart game

## Development

To contribute to the project:

1. Create a new branch for your feature
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## Troubleshooting

Common issues and solutions:

1. **Game doesn't launch**
   - Verify Godot is installed correctly
   - Check if project.godot file is not corrupted
   - Try reimporting the project

2. **No sound**
   - Check system volume
   - Verify sound files in assets/sounds are properly imported
   - Check if sound is enabled in game settings

## License

[Your License Here] 