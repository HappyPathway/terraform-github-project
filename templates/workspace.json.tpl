{
  "folders": ${jsonencode(folders)},
  "extensions": {
    "recommendations": ${jsonencode(recommended_extensions)}
  },
  "settings": {
    "files.exclude": {
      "**/.git": true,
      "**/.DS_Store": true
    },
    "[terraform]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "hashicorp.terraform"
    },
    "workbench.iconTheme": "vscode-icons",
    "editor.inlineSuggest.enabled": true,
    "github.copilot.enable": {
      "*": true
    }
  }
}