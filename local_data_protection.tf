locals {
  data_protection = {
    encryption_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "pgp", "gpg", "age-encryption",
          "full-disk-encryption", "dm-crypt",
          "luks", "cryptsetup"
        ], lower(topic))
      ]
    ]))
    backup_tools = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "velero", "restic", "borg",
          "backblaze", "rclone", "rsync",
          "duplicity", "bacula"
        ], lower(topic))
      ]
    ]))
    data_lifecycle = distinct(flatten([
      for repo in var.repositories : [
        for topic in coalesce(repo.github_repo_topics, []) :
        lower(topic) if contains([
          "data-retention", "data-lifecycle",
          "archival", "data-deletion",
          "data-classification"
        ], lower(topic))
      ]
    ]))
  }
}