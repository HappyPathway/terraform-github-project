locals {
  topic_extension_mappings = {
    # Language-specific extensions
    "terraform" = [
      "hashicorp.terraform",
      "hashicorp.hcl",
      "4ops.terraform"
    ]
    "python" = [
      "ms-python.python",
      "ms-python.vscode-pylance",
      "ms-python.black-formatter"
    ]
    "javascript" = [
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode"
    ]
    "typescript" = [
      "ms-typescript-javascript.typescript-javascript",
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode"
    ]
    "java" = [
      "vscjava.vscode-java-pack",
      "redhat.java"
    ]
    "go" = [
      "golang.go"
    ]
    "docker" = [
      "ms-azuretools.vscode-docker"
    ]
    "kubernetes" = [
      "ms-kubernetes-tools.vscode-kubernetes-tools"
    ]
    "aws" = [
      "amazonwebservices.aws-toolkit-vscode"
    ]
    "azure" = [
      "ms-azuretools.vscode-azureterraform",
      "ms-vscode.azure-account"
    ]
    "gcp" = [
      "googlecloudtools.cloudcode"
    ]
    "testing" = [
      "ryanluker.vscode-coverage-gutters",
      "formulahendry.code-runner"
    ]
    "quality" = [
      "sonarsource.sonarlint-vscode",
      "streetsidesoftware.code-spell-checker"
    ]
    "git" = [
      "eamodio.gitlens",
      "mhutchie.git-graph"
    ]
    "github" = [
      "github.vscode-github-actions",
      "github.copilot",
      "github.copilot-chat"
    ]
    "documentation" = [
      "yzhang.markdown-all-in-one",
      "bierner.markdown-preview-github-styles"
    ]
  }

  # Get recommended extensions based on repository topics
  recommended_extensions = distinct(concat(
    # Base extensions always included
    [
      "github.copilot",
      "github.copilot-chat",
      "eamodio.gitlens",
      "github.vscode-github-actions"
    ],
    # Extensions based on repository topics
    flatten([
      for repo in var.repositories :
      flatten([
        for topic in coalesce(repo.topics, []) :
        try(local.topic_extension_mappings[lower(topic)], [])
      ])
    ])
  ))

  # Generate workspace folders configuration
  workspace_folders = concat(
    [{
      name = var.project_name,
      path = "."
    }],
    [for repo in var.repositories : {
      name = repo.name,
      path = "../${repo.name}"
    }],
    coalesce(var.workspace_files, [])
  )
}