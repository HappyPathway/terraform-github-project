########################################################################
# File definitions that determine which files go to which repositories
########################################################################

locals {
  ##########################################
  # Files that go to ALL repositories
  ##########################################
  standard_files = [
    {
      name = "README.md",
      content = templatefile("${path.module}/templates/README.md", {
        project_name = var.project_name
        description  = coalesce(try(var.base_repository.description, ""), var.project_name, "")
        repo_org     = var.repo_org
        repositories = [
          for repo in var.repositories : {
            repo             = repo.name
            repo_description = lookup(repo, "description", "${var.project_name}::${repo.name}")
          }
        ]
      })
    },
    {
      name    = ".github/pull_request_template.md",
      content = file("${path.module}/templates/github/pull_request_template.md")
    }
  ]

  ##########################################
  # Files that ONLY go to base repository
  ##########################################

  # Project prompt file - only in base repo
  project_prompt_file = [
    {
      content = var.project_prompt
      name    = ".github/prompts/${var.project_name}.prompt.md"
    }
  ]

  # VS Code workspace configuration - only in base repo
  workspace_config_files = [
    for file in module.development_environment.files :
    {
      name    = file.name
      content = file.content
    }
  ]

  # Module files for infrastructure setup - only in base repo
  base_module_files = concat(
    module.security.files,
    module.development.files,
    module.infrastructure.files,
    module.quality.files,
    [
      # Only include copilot files that aren't repo-specific prompts
      for file in module.copilot.files :
      file if !can(regex("^.github/prompts/[^/]+.prompt.md$", file.name))
    ],
    [
      {
        name    = "scripts/gproj",
        content = file("${path.module}/scripts/gproj") # Use gproj script directly instead of template
      },
      {
        name    = "scripts/requirements.txt",
        content = file("${path.module}/templates/requirements.txt")
      }
    ]
  )

  # .gproj config - only in base repo
  gproj_config = {
    name = ".gproj"
    content = templatefile("${path.module}/templates/gproj.json.tftpl", {
      project_name   = var.project_name
      repo_org       = var.repo_org
      docs_base_path = var.docs_base_path # Base path, repos will be direct children
      documentation_sources = [
        for source in distinct(var.documentation_sources) : {
          repo = source.repo
          name = replace(source.name, "^docs/+", "")
          path = coalesce(source.path, ".") # Keep original path for workspace mapping
          tag  = try(source.tag, "main")
        } if source != null
      ]
      repositories = [
        for repo in distinct(var.repositories) : {
          name        = repo.name
          description = lookup(repo, "description", "${var.project_name}::${repo.name}")
        } if repo != null
      ]
    })
  }

  # Extra managed files for base repo only
  extra_repo_files = local.base_repo_config.managed_extra_files == null ? [] : [
    for file in local.base_repo_config.managed_extra_files : {
      name    = file.path
      content = file.content
    }
  ]

  ##########################################
  # Final file lists for each repo type
  ##########################################

  # BASE REPOSITORY: Gets all module files and base config
  repository_files = [
    for file in concat(
      local.standard_files,         # Standard files that all repos get
      local.project_prompt_file,    # Project-level prompt file 
      local.extra_repo_files,       # Any extra managed files
      local.base_module_files,      # Infrastructure module files
      local.workspace_config_files, # VS Code workspace config
      [local.gproj_config]          # Project config file
    ) : file if file.name != "CODEOWNERS" && file.name != ".github/CODEOWNERS"
  ]

  # PROJECT REPOSITORIES: Only get standard files + their specific prompt
  project_repository_files = {
    for name, repo in local.project_repositories : name => [
      for file in concat(
        local.standard_files, # Standard files that all repos get
        [
          for file in module.copilot.files :
          file if startswith(file.name, ".github/prompts/${name}") # Only repo's specific prompt
        ]
      ) : file if file.name != "CODEOWNERS" && file.name != ".github/CODEOWNERS"
    ]
  }
}

##########################################
# Module calls to create the files
##########################################

# Creates ALL files in the base repository
module "base_repository_files" {
  source = "./modules/repository_files"

  repository = module.base_repo.github_repo.name
  branch     = module.base_repo.default_branch
  files      = local.repository_files # Gets everything defined above except CODEOWNERS
  mkfiles    = var.mkfiles

  depends_on = [module.base_repo]
}

# Creates standard files + repo-specific prompt in each project repository
module "project_repository_files" {
  source = "./modules/repository_files"
  for_each = {
    for repo in var.repositories : repo.name => repo
  }

  repository = each.key
  branch     = module.project_repos[each.key].default_branch
  files      = local.project_repository_files[each.key] # Only standard files + repo's prompt
  mkfiles    = var.mkfiles

  depends_on = [module.project_repos]
}