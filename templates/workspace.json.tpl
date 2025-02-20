{
  "folders": [
    %{ for folder in folders }
    {
      "path": "${folder.path}",
      "name": "${folder.name}"
    }%{ if !last },%{ endif }
    %{ endfor }
  ],
  "recommendations": [
    %{ for ext in recommended_extensions }
    "${ext}"%{ if !last },%{ endif }
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