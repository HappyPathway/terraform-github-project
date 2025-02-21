# Add validation check for GitHub Free tier limitations
resource "null_resource" "github_free_validation" {
  lifecycle {
    precondition {
      condition     = length(compact(local.validation_results.error_messages)) == 0
      error_message = join("\n", compact(local.validation_results.error_messages))
    }
  }
}