# Base repository files configuration
locals {
  # Core repository files for all repos
  standard_files = [
    {
      name = "README.md",
      content = templatefile("${path.module}/templates/README.md", {
        project_name = var.project_name
        description  = try(var.base_repository.description, "")
        repo_org     = var.repo_org
        repositories = [
          for repo in var.repositories : {
            repo             = repo.name
            repo_description = try(repo.description, "")
          }
        ]
      })
    },
    {
      name = ".github/CODEOWNERS",
      content = templatefile("${path.module}/templates/CODEOWNERS", {
        codeowners = var.project_owners
      })
    },
    {
      name    = ".github/pull_request_template.md",
      content = file("${path.module}/templates/pull_request_template.md")
    },
    {
      name = "scripts/init.sh",
      content = templatefile("${path.module}/templates/init.sh.tpl", {
        project_name = var.project_name
        repo_org     = var.repo_org
        repositories = var.repositories
      })
    }
  ]

  # Project prompt file (for base repo only)
  project_prompt_file = [
    {
      content = var.project_prompt
      name    = ".github/prompts/${var.project_name}.prompt.md"
    }
  ]

  # VS Code workspace configuration from development_environment module
  workspace_config_files = [
    for file in module.development_environment.files :
    {
      name    = file.name
      content = file.content
    }
  ]

  # Module-specific files consolidated in base repo
  base_module_files = concat(
    [
      for file in module.security.files : {
        name    = contains(split("/", file.name), "prompts") ? file.name : ".github/prompts/${file.name}"
        content = file.content
      }
    ],
    [
      for file in module.development.files : {
        name    = contains(split("/", file.name), "prompts") ? file.name : ".github/prompts/${file.name}"
        content = file.content
      }
    ],
    [
      for file in module.infrastructure.files : {
        name    = contains(split("/", file.name), "prompts") ? file.name : ".github/prompts/${file.name}"
        content = file.content
      }
    ],
    [
      for file in module.quality.files : {
        name    = contains(split("/", file.name), "prompts") ? file.name : ".github/prompts/${file.name}"
        content = file.content
      }
    ]
  )

  # Copilot files - one per repo with consistent naming
  copilot_files = [
    for file in module.copilot.files : {
      name    = ".github/prompts/${basename(var.project_name)}.copilot.md"
      content = file.content
    }
  ]

  # Handle managed extra files for base repo
  extra_repo_files = local.base_repo_config.managed_extra_files == null ? [] : [
    for file in local.base_repo_config.managed_extra_files : {
      name    = file.path
      content = file.content
    }
  ]

  # Repository-specific prompts with standardized naming
  repo_specific_prompt_files = {
    for name, repo in local.project_repositories : name => [
      {
        name = ".github/prompts/${basename(name)}.prompt.md"
        content = trimspace(coalesce(
          try(repo.prompt, null),
          try(repo.description, "Repository-specific prompt for ${basename(name)}")
        ))
      }
    ]
  }

  # Generate init script content
  init_script_content = templatefile("${path.module}/templates/init.sh.tpl", {
    project_name = var.project_name
    repo_org     = var.repo_org
    repositories = [for repo in var.repositories : repo.name]
  })
}

# Base repository files module (gets all module files and base config)
module "base_repository_files" {
  source = "./modules/repository_files"

  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  files = concat(
    local.standard_files,
    local.project_prompt_file,
    local.extra_repo_files,
    local.base_module_files,
    local.copilot_files,
    local.workspace_config_files
  )

  depends_on = [module.base_repo]
}

# Project repository files module (gets only repo-specific files)
module "project_repository_files" {
  source = "./modules/repository_files"
  for_each = {
    for repo in var.repositories : repo.name => repo
  }

  repository = each.key
  branch     = module.project_repos[each.key].default_branch
  files = concat(
    local.standard_files,
    local.repo_specific_prompt_files[each.key],
    local.copilot_files
  )

  depends_on = [module.project_repos]
}