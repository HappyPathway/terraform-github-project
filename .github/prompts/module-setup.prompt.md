your goal is to create a new terraform module for managing projects that consist of multiple repos.

the terraform-github-project module is meant to be a collection of terraform-github-repo module calls


# the repo list will be a list of objects
## we will inspect the github-repo module at ../terraform-github-repo
## we will set all optional fields as optional defaulted to the terraform-github-repo module defaults


each github repo that we create will also need to have a prompt file that is installed into .github/prompts/repo-setup.prompt.md

there will be one master repo for the project that is also created. This master repo will need to have a .github/prompts/project-setup.prompt.md file as well

each repo that is created will support the full set of github repo parameters.

we should iterate over a list of github repo objects.

# prompt files
the master repo needs to accept a "prompt" written in clear language, this will be written to the .github/prompts/project-setup.prompt.md file

the project repos need to accept a "prompt" written in clear language, this will be written to the .github/prompts/repo-setup.prompt.md prompt file

# code-workspace file
the master repo needs to have a file that's named after the project and stored in the top-level directory. our module needs to accept an input list of objects.
these objects will be of the form
```json
{
  "name": "name-of-file-in-workspace",
  "path": "path to directory relative to where module will be checked out"
}
```
the project repos will automatically by added to this list, loading them into the workspace automatically.