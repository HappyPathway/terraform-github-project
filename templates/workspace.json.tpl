{
  "folders": [
    %{ for folder in folders }
    {
      "path": "${folder.path}",
      "name": "${folder.name}"
    }%{ if !endfor },%{ endif }
    %{ endfor }
  ],
  "recommendations": [
    %{ for ext in recommended_extensions }
    "${ext}"%{ if !endfor },%{ endif }
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