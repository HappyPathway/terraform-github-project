mock_provider "github" {
  base_repository_files = {
    # Mock for code workspace file
    workspace_config = {
      repository = "test-e2e"
      file = "test-e2e.code-workspace"
      content = jsonencode({
        folders = []
        settings = {}
      })
      branch = "main"
    }
    # Mock for devcontainer file
    devcontainer = {
      repository = "test-e2e"
      file = ".devcontainer/devcontainer.json"
      content = jsonencode({})
      branch = "main"
    }
    # Mock for docker-compose file
    docker_compose = {
      repository = "test-e2e"
      file = ".devcontainer/docker-compose.yml"
      content = "version: '3.8'"
      branch = "main"
    }
  }
  
  # Mock basic repository response
  repository = {
    name = "test-e2e"
    full_name = "test-org/test-e2e"
    node_id = "R_1234567"
    private = false
    html_url = "https://github.com/test-org/test-e2e"
    visibility = "public"
    default_branch = "main"
  }
}