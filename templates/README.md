# ${project_name}

${description}

## Getting Started

1. Clone this repository:
```bash
git clone git@github.com:${repo_org}/${project_name}.git
cd ${project_name}
```

2. Set up Python environment and install dependencies:
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows use: .venv\Scripts\activate
pip install -r scripts/requirements.txt
```

3. Run the initialization script:
```bash
python scripts/init.py
```

This will:
- Verify Git SSH access to GitHub
- Create the workspace directory structure
- Clone or update all project repositories
- Set up repository configurations

For debugging, you can run:
```bash
python scripts/init.py --debug
```

## Repository Structure

This project consists of multiple repositories:

%{ for repo in repositories ~}
- ${repo.repo}: ${repo.repo_description}
%{ endfor ~}

## Development Environment

This repository includes:
- VS Code workspace configuration
- GitHub Copilot settings
- Project-specific documentation and guidelines
- Python-based initialization tools

## Contributing

Please see the [CONTRIBUTING.md](.github/CONTRIBUTING.md) file for guidelines.