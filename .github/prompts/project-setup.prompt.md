# Project Setup Prompt

This Terraform module helps you manage a project that consists of multiple GitHub repositories. It creates a master repository for the project and additional project-related repositories. Each repository will have a standard documentation structure.

## Master Repository
The master repository is the main repository for your project. It will contain a `.github/prompts/project-setup.prompt.md` file to guide the setup of the project.

## Project Repositories
Each project repository will have a `.github/prompts/repo-setup.prompt.md` file to guide the setup of the individual repositories. These repositories will support all GitHub repository settings through the terraform-github-repo module.

## Usage
To use this module, you need to provide a list of repository configurations. Each configuration should include the repository name and any other optional settings supported by the terraform-github-repo module.