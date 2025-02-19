locals {
  security_tooling = {
    secret_managers = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "vault", "hashicorp-vault",
          "aws-kms", "azure-key-vault",
          "google-cloud-kms", "gsm",
          "sops", "mozilla-sops"
        ], lower(topic))
      ]
    ]))
    vault_integration = anytrue([
      for repo in var.repositories :
      contains(coalesce(repo.github_repo_topics, []), "vault") ||
      contains(coalesce(repo.github_repo_topics, []), "hashicorp-vault")
    ])
    cloud_key_management = {
      aws = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "aws-kms") ||
        contains(coalesce(repo.github_repo_topics, []), "aws-secrets-manager")
      ])
      azure = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "azure-key-vault") ||
        contains(coalesce(repo.github_repo_topics, []), "azure-managed-identity")
      ])
      gcp = anytrue([
        for repo in var.repositories :
        contains(coalesce(repo.github_repo_topics, []), "google-cloud-kms") ||
        contains(coalesce(repo.github_repo_topics, []), "google-secret-manager")
      ])
    }
    security_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "vault-agent", "vault-k8s",
          "cert-manager", "lets-encrypt",
          "sealed-secrets", "external-secrets",
          "opa", "gatekeeper",
          "snyk", "trivy"
        ], lower(topic))
      ]
    ]))
  }
}