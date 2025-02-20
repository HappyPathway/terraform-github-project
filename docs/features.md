# Features

## Development Environment Features

All development environment features are opt-in and disabled by default. Enable only the features you need by setting their corresponding configuration blocks.

### DevContainer Support
Enable by setting the `development_container` block:
```hcl
development_container = {
  base_image = "ubuntu:22.04"
  install_tools = ["git", "curl"]
  vs_code_extensions = ["github.copilot"]
}
```

Features:
- Automatically configure development containers for each repository
- Support for custom base images and tools
- VS Code extension management
- Port forwarding configuration
- Multi-container setups with Docker Compose
- Post-create commands for environment setup

### VS Code Integration
Enable by setting the `vs_code_workspace` block:
```hcl
vs_code_workspace = {
  settings = {
    "editor.formatOnSave": true
  }
  extensions = {
    recommended = ["dbaeumer.vscode-eslint"]
  }
}
```

Features:
- Project-wide workspace settings
- Shared extension recommendations
- Common development tasks
- Debug configurations
- Consistent coding standards

### GitHub Codespaces
Enable by setting the `codespaces` block:
```hcl
codespaces = {
  machine_type = "medium"
  prebuild_enabled = true
}
```

Features:
- Resource allocation management
- Pre-build configurations
- Environment variables and secrets
- Retention policies
- Custom dotfiles support