# GitHub Copilot Configuration for ${repository_name}

## Project Context
This repository is part of the ${project_name} project.

## Technology Stack

%{ if length(languages) > 0 ~}
### Programming Languages
%{ for lang in languages ~}
- ${lang}
%{ endfor ~}
%{ endif ~}

%{ if length(frameworks) > 0 ~}
### Frameworks
%{ for framework in frameworks ~}
- ${framework}
%{ endfor ~}
%{ endif ~}

%{ if length(testing_tools) > 0 ~}
### Testing Tools
%{ for tool in testing_tools ~}
- ${tool}
%{ endfor ~}
%{ endif ~}

%{ if length(iac_tools) > 0 ~}
### Infrastructure Tools
%{ for tool in iac_tools ~}
- ${tool}
%{ endfor ~}
%{ endif ~}

%{ if length(cloud_providers) > 0 ~}
### Cloud Providers
%{ for provider in cloud_providers ~}
- ${provider}
%{ endfor ~}
%{ endif ~}

%{ if length(security_tools) > 0 ~}
### Security Tools
%{ for tool in security_tools ~}
- ${tool}
%{ endfor ~}
%{ endif ~}

## Custom Instructions
%{ if instructions != null ~}
${instructions}
%{ else ~}
Follow project coding standards and best practices.
%{ endif ~}

## Important Notes
- All code suggestions must work without GitHub Pro features
- Follow project coding standards and conventions
- Consider security best practices
- Ensure proper error handling
- Add appropriate documentation