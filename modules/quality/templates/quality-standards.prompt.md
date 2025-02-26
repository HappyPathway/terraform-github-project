# Quality Standards for ${repository_name}

## Code Quality Tools

%{ if length(linting_tools) > 0 ~}
### Linting Tools
%{ for tool in linting_tools ~}
- ${tool}
%{ endfor ~}
%{ endif ~}

%{ if length(formatting_tools) > 0 ~}
### Code Formatting
%{ for tool in formatting_tools ~}
- ${tool}
%{ endfor ~}
%{ endif ~}

%{ if length(documentation_tools) > 0 ~}
### Documentation Tools
%{ for tool in documentation_tools ~}
- ${tool}
%{ endfor ~}
%{ endif ~}

## Type Safety
%{ if has_type_checking ~}
Type checking is enabled for this repository. Ensure:
- All functions have type annotations
- Use strict type checking mode
- Document type definitions
%{ endif ~}

## Quality Requirements
%{ if quality_config.linting_required ~}
- Linting is required for all code changes
%{ endif ~}
%{ if quality_config.documentation_required ~}
- Documentation is required for all public interfaces
%{ endif ~}
%{ if quality_config.type_safety ~}
- Type safety checks must pass
%{ endif ~}

## Best Practices
1. Write clear, maintainable code
2. Follow consistent naming conventions
3. Keep functions and classes focused
4. Add appropriate comments
5. Write comprehensive tests