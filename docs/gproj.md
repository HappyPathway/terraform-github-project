# gproj Script Documentation

The `gproj` script is a project management tool that helps manage Git repositories and documentation sources in a workspace. It provides functionality for initializing repositories, managing documentation sources, and handling Git operations across multiple repositories.

## Configuration

The script uses a `.gproj` configuration file in JSON format that should contain:
- `project_name`: Name of the project
- `repo_org`: GitHub organization name
- `repositories`: List of repositories to manage
- `docs_base_path`: Base path for documentation (defaults to "~/.gproj/docs")
- `documentation_sources`: List of documentation sources to clone/manage

## Command Line Arguments

```
gproj [options]
```

### Available Options

- `--debug`: Enable debug output, showing current configuration
- `--nuke`: Remove all repositories after creating backup branches
- `--commit`: Create a new commit in repositories
- `--message, -m`: Commit message (required when using --commit)
- `--push`: Push changes to remote repositories
- `--files`: List of specific files to stage for commit
- `--branch`: Branch name for push operation
- `--exclude`: List of repositories to exclude from operations

## Core Features

### Documentation Source Management

The DocSourceManager class handles documentation source repositories:

- **Load Configuration**: Reads and parses the .gproj configuration file
- **Clone Documentation Repos**: Clones or updates documentation repositories
- **Path Management**: Handles path transformations and expansions for documentation repos
- **Concurrent Processing**: Uses asyncio for concurrent repository operations
- **Version Control**: Supports checking out specific tags/branches

### Project Repository Management

The ProjectInitializer class handles project repositories:

- **Repository Initialization**: Clones all project repositories
- **Repository Updates**: Fetches updates for existing repositories
- **Backup Creation**: Creates backup branches before destructive operations
- **Repository Cleanup**: Supports removing repositories with backup
- **Concurrent Operations**: Handles multiple repositories simultaneously

### Git Operations

Supports common Git operations across all project repositories:

- **Committing Changes**: 
  - Stage specific files or all changes
  - Add commit messages
  - Handles commit operations across multiple repos
  
- **Pushing Changes**:
  - Push to default or specific branches
  - Concurrent push operations
  - Branch-specific pushing

## Usage Examples

1. Initialize project workspace:
```bash
gproj
```

2. Create a commit across all repositories:
```bash
gproj --commit -m "Your commit message"
```

3. Push changes to a specific branch:
```bash
gproj --push --branch feature/new-feature
```

4. Commit specific files:
```bash
gproj --commit -m "Update docs" --files README.md docs/*
```

5. Remove all repositories with backup:
```bash
gproj --nuke
```

6. Commit and push in one command:
```bash
gproj --commit -m "Update" --push
```

7. Exclude specific repositories:
```bash
gproj --commit -m "Update configs" --exclude repo1 repo2
```

## Error Handling

The script includes comprehensive error handling:
- Repository operation failures
- Missing configuration
- Invalid commands
- Git operation errors

Each operation provides clear success/failure indicators with ✅ or ❌ symbols.

## Performance Features

- Concurrent repository operations using asyncio
- Semaphore-based concurrency control (max 5 concurrent operations)
- Efficient handling of existing repositories
- Optimized git operations

## Safety Features

- Backup branch creation before destructive operations
- Configuration validation
- Required commit messages
- Controlled concurrent operations