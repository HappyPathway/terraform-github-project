for x in $(./scripts/list_recent_repos.sh 1 HappyPathway | grep -v repositories | awk '{ print $2 }')
do
gh repo delete HappyPathway/${x} --confirm
done
