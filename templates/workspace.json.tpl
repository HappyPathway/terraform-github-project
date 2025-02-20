{
  "folders": [
    %{ for i, folder in folders }
    {
      "path": "${folder.path}",
      "name": "${folder.name}"
    }%{ if i < length(folders) - 1 },%{ endif }
    %{ endfor }
  ],
  "recommendations": [
    %{ for i, ext in recommended_extensions }
    "${ext}"%{ if i < length(recommended_extensions) - 1 },%{ endif }
    %{ endfor }
  ],
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