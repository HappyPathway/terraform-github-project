#!/usr/bin/env python3
"""Project git management script for ${project_name}"""
import argparse
import asyncio
import json
import os
import sys
import shutil
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Union

class DocSourceManager:
    def __init__(self):
        self.config_path = Path(".projg")
        self.config = self.load_config()
        self.semaphore = asyncio.Semaphore(5)

    def load_config(self) -> Dict:
        """Load .projg configuration file"""
        if not self.config_path.exists():
            return {"docs_base_path": "~/.projg/docs", "documentation_sources": []}
        return json.loads(self.config_path.read_text())

    def expand_path(self, path: str) -> str:
        """Expand environment variables and ~ in path"""
        return os.path.expandvars(os.path.expanduser(path))

    async def clone_doc_repo(self, repo: Dict) -> bool:
        """Clone a documentation repository"""
        try:
            base_path = Path(self.expand_path(self.config["docs_base_path"]))
            repo_dir = base_path / repo["name"]
            if repo_dir.exists():
                print(f"Documentation repo {repo['name']} exists, checking out {repo['tag']}...")
                process = await asyncio.create_subprocess_exec(
                    "git", "-C", str(repo_dir), "fetch", "--all",
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                await process.communicate()
                process = await asyncio.create_subprocess_exec(
                    "git", "-C", str(repo_dir), "checkout", repo["tag"],
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                await process.communicate()
            else:
                print(f"Cloning documentation repo {repo['name']}...")
                repo_dir.parent.mkdir(parents=True, exist_ok=True)
                process = await asyncio.create_subprocess_exec(
                    "git", "clone", "--depth", "1", "-b", repo["tag"],
                    repo["repo"], str(repo_dir),
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE
                )
                await process.communicate()
            return True
        except Exception as e:
            print(f"Error processing documentation repo {repo['name']}: {e}")
            return False

    async def process_doc_sources(self) -> None:
        """Process all documentation sources"""
        if not self.config["documentation_sources"]:
            return

        print("\nProcessing documentation sources...")
        base_path = Path(self.expand_path(self.config["docs_base_path"]))
        base_path.mkdir(parents=True, exist_ok=True)

        tasks = []
        for source in self.config["documentation_sources"]:
            tasks.append(self.clone_doc_repo(source))
        
        results = await asyncio.gather(*tasks)
        success = all(results)
        print("✅ Documentation sources processed" if success else "❌ Some documentation sources failed")

class ProjectInitializer:
    def __init__(self, project_name: str, repo_org: str, repositories: str):
        self.project_name = project_name
        self.repo_org = repo_org
        self.repositories = repositories  # Deserialize the JSON string
        self.base_dir = Path("..").resolve()
        self.semaphore = asyncio.Semaphore(5)  # Limit concurrent git operations

    async def verify_git_ssh(self) -> bool:
        """Verify Git SSH access to GitHub"""
        try:
            process = await asyncio.create_subprocess_exec(
                "ssh", "-T", "git@github.com",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, stderr = await process.communicate()
            return "successfully authenticated" in stderr.decode().lower()
        except Exception as e:
            print(f"Error verifying Git SSH access: {e}")
            return False

    async def check_remote(self, repo_path: Path, expected_remote: str) -> bool:
        """Check if repository remote matches expected URL"""
        try:
            process = await asyncio.create_subprocess_exec(
                "git", "remote", "get-url", "origin",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            stdout, _ = await process.communicate()
            current_remote = stdout.decode().strip()
            return current_remote == expected_remote
        except Exception:
            return False

    async def update_repository(self, repo_path: Path) -> bool:
        """Update existing repository"""
        try:
            # Fetch latest changes
            fetch_process = await asyncio.create_subprocess_exec(
                "git", "fetch",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            await fetch_process.communicate()

            # Get current branch
            branch_process = await asyncio.create_subprocess_exec(
                "git", "rev-parse", "--abbrev-ref", "HEAD",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            stdout, _ = await branch_process.communicate()
            current_branch = stdout.decode().strip()

            # Pull latest changes
            pull_process = await asyncio.create_subprocess_exec(
                "git", "pull", "origin", current_branch,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            await pull_process.communicate()
            return True
        except Exception as e:
            print(f"Error updating repository: {e}")
            return False

    async def clone_repository(self, repo_name: str, repo_path: Path) -> bool:
        """Clone a repository"""
        try:
            process = await asyncio.create_subprocess_exec(
                "git", "clone",
                f"git@github.com:{self.repo_org}/{repo_name}.git",
                str(repo_path),
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            await process.communicate()
            return True
        except Exception as e:
            print(f"Error cloning repository: {e}")
            return False

    async def create_backup_branch(self, repo_path: Path) -> bool:
        """Create a backup branch with timestamp"""
        try:
            current_time = datetime.now().strftime("%Y%m%d_%H%M%S")
            
            # Get current branch
            branch_process = await asyncio.create_subprocess_exec(
                "git", "rev-parse", "--abbrev-ref", "HEAD",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            stdout, _ = await branch_process.communicate()
            current_branch = stdout.decode().strip()
            
            backup_branch = f"{current_branch}_backup_{current_time}"
            
            # Create and push backup branch
            create_process = await asyncio.create_subprocess_exec(
                "git", "checkout", "-b", backup_branch,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            await create_process.communicate()
            
            push_process = await asyncio.create_subprocess_exec(
                "git", "push", "origin", backup_branch,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            await push_process.communicate()
            
            # Return to original branch
            checkout_process = await asyncio.create_subprocess_exec(
                "git", "checkout", current_branch,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            await checkout_process.communicate()
            return True
        except Exception as e:
            print(f"Error creating backup branch: {e}")
            return False

    async def nuke_repository(self, repo: Dict) -> None:
        """Reset repository to clean state after creating a backup branch"""
        async with self.semaphore:
            repo_name = repo.get("name")
            if not repo_name:
                print("❌ Repository missing name field")
                return

            repo_path = self.base_dir / repo_name
            if not repo_path.exists():
                print(f"Repository {repo_name} doesn't exist, skipping...")
                return

            print(f"\nNuking repository: {repo_name}")
            print(f"Creating backup branch for {repo_name}...")
            if await self.create_backup_branch(repo_path):
                print(f"✅ Backup branch created for {repo_name}")
                try:
                    # Get current branch
                    branch_process = await asyncio.create_subprocess_exec(
                        "git", "rev-parse", "--abbrev-ref", "HEAD",
                        stdout=asyncio.subprocess.PIPE,
                        stderr=asyncio.subprocess.PIPE,
                        cwd=repo_path
                    )
                    stdout, _ = await branch_process.communicate()
                    current_branch = stdout.decode().strip()

                    # Hard reset to remote branch
                    reset_process = await asyncio.create_subprocess_exec(
                        "git", "reset", "--hard", f"origin/{current_branch}",
                        stdout=asyncio.subprocess.PIPE,
                        stderr=asyncio.subprocess.PIPE,
                        cwd=repo_path
                    )
                    await reset_process.communicate()

                    # Clean untracked files and directories
                    clean_process = await asyncio.create_subprocess_exec(
                        "git", "clean", "-fd",
                        stdout=asyncio.subprocess.PIPE,
                        stderr=asyncio.subprocess.PIPE,
                        cwd=repo_path
                    )
                    await clean_process.communicate()
                    print(f"✅ {repo_name} reset successfully")
                except Exception as e:
                    print(f"Error resetting {repo_name}: {e}")
            else:
                print(f"❌ Failed to create backup branch for {repo_name}, aborting reset")

    async def process_repository(self, repo: Dict) -> None:
        async with self.semaphore:
            repo_name = repo.get("name")
            if not repo_name:
                print("❌ Repository missing name field")
                return

            repo_path = self.base_dir / repo_name
            expected_remote = f"git@github.com:{self.repo_org}/{repo_name}.git"

            print(f"\nProcessing repository: {repo_name}")
            if repo_path.exists():
                print(f"Repository {repo_name} exists, verifying...")
                if await self.check_remote(repo_path, expected_remote):
                    print(f"Updating {repo_name}...")
                    if await self.update_repository(repo_path):
                        print(f"✅ {repo_name} updated successfully")
                    else:
                        print(f"❌ Failed to update {repo_name}")
                else:
                    print(f"❌ Remote mismatch for {repo_name}")
                    print(f"Expected: {expected_remote}")
                    print("Please check the repository manually")
            else:
                print(f"Cloning {repo_name}...")
                if await self.clone_repository(repo_name, repo_path):
                    print(f"✅ {repo_name} cloned successfully")
                else:
                    print(f"❌ Failed to clone {repo_name}")

    async def stage_changes(self, repo_path: Path, paths: List[str] = None) -> bool:
        """Stage changes for commit"""
        try:
            cmd = ["git", "add"]
            if paths:
                cmd.extend(paths)
            else:
                cmd.append(".")
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            await process.communicate()
            return True
        except Exception as e:
            print(f"Error staging changes: {e}")
            return False

    async def commit_changes(self, repo_path: Path, message: str) -> bool:
        """Create a commit with the staged changes"""
        try:
            process = await asyncio.create_subprocess_exec(
                "git", "commit", "-m", message,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            await process.communicate()
            return True
        except Exception as e:
            print(f"Error creating commit: {e}")
            return False

    async def push_changes(self, repo_path: Path, branch: str = None) -> bool:
        """Push commits to remote"""
        try:
            cmd = ["git", "push"]
            if branch:
                cmd.extend(["origin", branch])
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=repo_path
            )
            await process.communicate()
            return True
        except Exception as e:
            print(f"Error pushing changes: {e}")
            return False

    async def run(self, nuke: bool = False) -> None:
        """Initialize or nuke the project workspace"""
        print(f"{'Nuking' if nuke else 'Initializing'} project: {self.project_name}")
        
        # Create parent directory
        os.makedirs(self.base_dir, exist_ok=True)
        
        # Verify Git SSH access
        print("\nVerifying Git SSH access to GitHub...")
        if not await self.verify_git_ssh():
            print("❌ Failed to verify Git SSH access to GitHub")
            print("Please check your SSH configuration")
            sys.exit(1)
        print("✅ Git SSH access verified")
        
        # Process repositories in parallel
        tasks = [self.nuke_repository(repo) if nuke else self.process_repository(repo) 
                for repo in self.repositories]
        await asyncio.gather(*tasks)
        
        # Process documentation sources if not nuking
        if not nuke:
            doc_manager = DocSourceManager()
            await doc_manager.process_doc_sources()
        
        print(f"\n✅ Project {'nuked' if nuke else 'initialization'} complete!")

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="Initialize or nuke project workspace")
    parser.add_argument("--debug", action="store_true", help="Enable debug output")
    parser.add_argument("--nuke", action="store_true", help="Remove all repositories (after creating backup branches)")
    parser.add_argument("--commit", action="store_true", help="Create a new commit")
    parser.add_argument("--message", "-m", help="Commit message")
    parser.add_argument("--push", action="store_true", help="Push changes to remote")
    parser.add_argument("--files", nargs="+", help="Specific files to stage")
    parser.add_argument("--branch", help="Branch name for push operation")
    parser.add_argument("--exclude", nargs="+", help="Exclude specific repositories")
    
    args = parser.parse_args()

    # Project configuration
    project_name = "${project_name}"
    repo_org = "${repo_org}"
    repositories = ${repositories}

    config = {
        "project_name": project_name,
        "repo_org": repo_org,
        "repositories": repositories
    }

    if args.debug:
        print("Configuration:")
        print(json.dumps(config, indent=2))

    initializer = ProjectInitializer(**config)

    # Handle git operations if specified
    if args.commit or args.push:
        if args.commit and not args.message:
            print("❌ --message is required for commit operation")
            sys.exit(1)
        asyncio.run(handle_git_operations(initializer, args))
    else:
        # Run initialization or nuke
        asyncio.run(initializer.run(nuke=args.nuke))

async def handle_git_operations(initializer: ProjectInitializer, args) -> None:
    """Handle git operations based on command line arguments"""
    repos_to_process = []
    for repo in initializer.repositories:
        repo_name = repo.get("name")
        if not repo_name:
            continue

        if args.exclude and repo_name in args.exclude:
            print(f"Skipping excluded repository: {repo_name}")
            continue

        repo_path = initializer.base_dir / repo_name
        if not repo_path.exists():
            print(f"❌ Repository {repo_name} not found, skipping...")
            continue
            
        repos_to_process.append((repo_name, repo_path))

    if not repos_to_process:
        print("No repositories to process!")
        return

    print(f"\nProcessing {len(repos_to_process)} repositories...")
    for repo_name, repo_path in repos_to_process:
        print(f"\nProcessing {repo_name}...")
        
        if args.commit:
            if await initializer.stage_changes(repo_path, args.files):
                print(f"✅ Changes staged in {repo_name}")
                if await initializer.commit_changes(repo_path, args.message):
                    print(f"✅ Changes committed in {repo_name}")
                else:
                    print(f"❌ Failed to commit changes in {repo_name}")
            else:
                print(f"❌ Failed to stage changes in {repo_name}")

        if args.push:
            if await initializer.push_changes(repo_path, args.branch):
                print(f"✅ Changes pushed in {repo_name}")
            else:
                print(f"❌ Failed to push changes in {repo_name}")

if __name__ == "__main__":
    main()