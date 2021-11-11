
#!/bin/bash

# current Git branch
get_current_branch() {
    git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,'
}

branch=$(get_current_branch)
echo "Current branch is $branch"

# get the last version number
increment_last_tag() {
    git describe --tags `git rev-list --tags --max-count=1` | 
    awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'
}


# v1.0.0, v1.5.2, etc.
versionLabel=$(increment_last_tag)
echo "versionLabel: $versionLabel"


# establish branch and tag name variables
masterBranch=main
releaseBranch=release-$versionLabel
 
# create the release branch from the -develop branch
git checkout -b $releaseBranch
 
# file in which to update version number
versionFile="version.txt"
 
# find version number assignment ("= v1.5.5" for example)
# and replace it with newly specified version number
sed -i.backup -E "s/\= v[0-9.]+/\= $versionLabel/" $versionFile $versionFile
 
# remove backup file created by sed command
rm $versionFile.backup
 
# commit version number increment
git commit -am "Incrementing version number to $versionLabel"
 
# merge release branch with the new version number into master
git checkout $masterBranch
git rebase $releaseBranch
 
# create tag for new version from -master
git tag $versionLabel

# remove release branch
git branch -d $releaseBranch
