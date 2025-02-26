mock_data "repository_files" {
  defaults = {
    ".devcontainer/devcontainer.json" = {
      repository = "test-project"
      content = jsonencode({
        name = "Test Dev Container"
        image = "python:3.11"
      })
      sha = "mock-sha-devcontainer"
    }
    ".devcontainer/docker-compose.yml" = {
      repository = "test-project"
      content = "version: '3.8'"
      sha = "mock-sha-compose"
    }
    "test-project.code-workspace" = {
      repository = "test-project"
      content = jsonencode({
        folders = [],
        settings = {
          "editor.formatOnSave": true
        },
        extensions = {
          recommendations = ["ms-python.python"]
        }
      })
      sha = "mock-sha-workspace"
    }
  }
}