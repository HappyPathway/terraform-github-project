#!/usr/bin/env python3
import json
import sys
from typing import Dict, List, Set
from dataclasses import dataclass
from pathlib import Path

@dataclass
class RepoConfig:
    name: str
    expected_files: Set[str]
    actual_files: Set[str]

def load_terraform_state(state_file: str) -> dict:
    """Load the Terraform state file"""
    with open(state_file, 'r') as f:
        return json.load(f)

def extract_repository_files(state: dict) -> Dict[str, Set[str]]:
    """Extract all repository files from the state"""
    repo_files = {}
    
    # Look for github_repository_file resources in the state
    for resource in state.get('resources', []):
        if resource.get('type') == 'github_repository_file':
            module_name = resource.get('module', '')
            instances = resource.get('instances', [])
            
            for instance in instances:
                # Get the repository name and file path
                repository = instance['attributes'].get('repository')
                file_path = instance['attributes'].get('file')
                
                if repository and file_path:
                    if repository not in repo_files:
                        repo_files[repository] = set()
                    repo_files[repository].add(file_path)
    
    return repo_files

def get_expected_base_repo_files(project_name: str) -> Set[str]:
    """Get the expected files for the base repository"""
    return {
        'README.md',
        '.github/CODEOWNERS',
        '.github/pull_request_template.md',
        f'.github/prompts/{project_name}.prompt.md',
        f'.github/prompts/{project_name}.copilot.md',
        'init.sh',
        f'{project_name}.code-workspace',
        # Development files from modules
        '.github/prompts/development-guidelines.prompt.md',
        '.github/prompts/infrastructure-guidelines.prompt.md',
        '.github/prompts/quality-standards.prompt.md',
        '.github/prompts/security-requirements.prompt.md',
        '.github/security/SECURITY.md',
        '.github/workflows/ci.yml',
    }

def get_expected_project_repo_files(repo_name: str, project_name: str) -> Set[str]:
    """Get the expected files for a project repository"""
    return {
        'README.md',
        '.github/CODEOWNERS',
        '.github/pull_request_template.md',
        f'.github/prompts/{repo_name}.prompt.md',
        f'.github/prompts/{project_name}.copilot.md',
    }

def validate_repositories(state_file: str, project_name: str) -> List[RepoConfig]:
    """Validate repository files against expected configuration"""
    state = load_terraform_state(state_file)
    actual_files = extract_repository_files(state)
    
    results = []
    
    # Validate base repository
    base_expected = get_expected_base_repo_files(project_name)
    results.append(RepoConfig(
        name=project_name,
        expected_files=base_expected,
        actual_files=actual_files.get(project_name, set())
    ))
    
    # Validate project repositories
    for repo_name in actual_files:
        if repo_name != project_name:
            project_expected = get_expected_project_repo_files(repo_name, project_name)
            results.append(RepoConfig(
                name=repo_name,
                expected_files=project_expected,
                actual_files=actual_files.get(repo_name, set())
            ))
    
    return results

def print_validation_results(results: List[RepoConfig]) -> bool:
    """Print validation results and return True if all validations pass"""
    all_passed = True
    
    for repo in results:
        print(f"\nValidating repository: {repo.name}")
        print("=" * 50)
        
        missing_files = repo.expected_files - repo.actual_files
        extra_files = repo.actual_files - repo.expected_files
        
        if not missing_files and not extra_files:
            print("✅ All files are correctly configured")
        else:
            all_passed = False
            if missing_files:
                print("\n❌ Missing expected files:")
                for file in sorted(missing_files):
                    print(f"  - {file}")
            
            if extra_files:
                print("\n⚠️  Extra files found:")
                for file in sorted(extra_files):
                    print(f"  - {file}")
        
        print("\nFile count:")
        print(f"  Expected: {len(repo.expected_files)}")
        print(f"  Actual: {len(repo.actual_files)}")
    
    return all_passed

def main():
    if len(sys.argv) != 3:
        print("Usage: validate_repo_files.py <state_file> <project_name>")
        sys.exit(1)
    
    state_file = sys.argv[1]
    project_name = sys.argv[2]
    
    if not Path(state_file).exists():
        print(f"Error: State file {state_file} not found")
        sys.exit(1)
    
    results = validate_repositories(state_file, project_name)
    success = print_validation_results(results)
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()