use github_is_private instead of github_visibility. 

# initialization script
add a field to the github-project module for an initialization script.
append the user provider initialization script to a templatefile 
that will have git clone commands for all project repos.
pass this to master repo so that it can store the file in its repo at .gproj