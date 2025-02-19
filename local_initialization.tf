locals {
  base_init_script = templatefile("${path.module}/templates/init.sh.tpl", {
    project_name = var.project_name,
    repositories  = [for repo in module.project_repos : repo.ssh_clone_url]
  })
  init_script_content = var.initialization_script != null ? "${local.base_init_script}\n\n${var.initialization_script.content}" : local.base_init_script
}