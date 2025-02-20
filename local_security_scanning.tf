locals {
  security_scanning_tools = {
    sast_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "sonarqube", "checkmarx", "fortify",
          "coverity", "semgrep", "codacy",
          "snyk-code", "github-code-scanning"
        ], lower(topic))
      ]
    ]))
    dast_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "zap", "burp", "acunetix",
          "netsparker", "qualys"
        ], lower(topic))
      ]
    ]))
    dependency_scanning = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "dependabot", "snyk-deps", "whitesource",
          "black-duck", "fossa", "renovate"
        ], lower(topic))
      ]
    ]))
    compliance_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "checkov", "terrascan", "tfsec",
          "cloudsploit", "prowler", "scout-suite",
          "security-hub", "qualys-compliance"
        ], lower(topic))
      ]
    ]))
    reporting_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "defectdojo", "security-hub", "jira-sec",
          "security-scorecard", "securityhub"
        ], lower(topic))
      ]
    ]))
  }
}