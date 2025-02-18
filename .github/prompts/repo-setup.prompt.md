# Repository Setup Prompt

This Terraform module helps you manage a project that consists of multiple GitHub repositories. Each repository will have a standard documentation structure.

## Repository Setup
Each project repository will have a `.github/prompts/repo-setup.prompt.md` file to guide the setup of the individual repositories. These repositories will support all GitHub repository settings through the terraform-github-repo module.

## Usage
To use this module, you need to provide a list of repository configurations. Each configuration should include the repository name and any other optional settings supported by the terraform-github-repo module.