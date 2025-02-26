# Required mock data for repository operations
mock_data "repository_files" {
  defaults = {
    ".devcontainer/devcontainer.json" = {
      repository = "test-dev-env"
      content = jsonencode({
        name = "test-dev-env"
        build = {
          dockerfile = "Dockerfile"
          context = "."
        }
      })
      branch = "main"
    }
    ".devcontainer/docker-compose.yml" = {
      repository = "test-dev-env"
      content = "version: '3.8'"
      branch = "main"
    }
    "test-dev-env.code-workspace" = {
      repository = "test-dev-env"
      content = jsonencode({
        folders = [],
        settings = {
          "editor.formatOnSave": true
        },
        extensions = {
          recommendations = ["ms-python.python"]
        }
      })
      branch = "main"
    }
  }
}