#!/usr/bin/env bash

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

echo "Checking config file"
WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ! -e "${WORKDIR}/../.vscode/config" ]; then
  echo "Missing .vscode/config file, creating one"
  cat > "${WORKDIR}/../.vscode/config" <<EOF
# Config File
PUPPETMASTER=""
# R10K_SCRIPT='/opt/puppetlabs/bin/update_environments.rb'
# RUN_LINT='yes'
# RUN_LINT_EXCEPTIONS='--no-80chars'
# PROTECTED_BRANCHES="production test development acceptance master"
EOF
  exit 1
fi

# Load Config and set defaults
. $WORKDIR/../.vscode/config
# R10K_SCRIPT=${R10K_SCRIPT:-'/opt/puppetlabs/bin/update_environments.rb'}
RUN_LINT=${RUN_LINT:-'yes'}
LINT_EXCEPTIONS=${LINT_EXCEPTIONS:-'--no-80chars'}
PROTECTED_BRANCHES=${PROTECTED_BRANCHES:-"production test development acceptance master"}
protected_branches=($PROTECTED_BRANCHES)

echo "Checking protected branches"
branch_name=$(git symbolic-ref -q HEAD)
branch_name=${branch_name##refs/heads/}
branch_name=${branch_name:-HEAD}
# user=`whoami | sed 's/+/\\\\/'`

echo "Showing Config"
echo "  Active branch: $branch_name"

# Check Puppet
if [[ $RUN_LINT=='yes' ]]; then
  echo "Lint check puppet code in site dir with ${LINT_EXCEPTIONS}"
  puppet-lint --fail-on-warnings ${LINT_EXCEPTIONS}  site
  if [[ $? -gt 0 ]]; then
    echo "### Lint issues, please fix first"
    exit 1
  fi
else
  echo "Skipping Lint Check, not recommended"
fi

echo "Check protected branches ${protected_branches}"
containsElement $branch_name "${protected_branches[@]}"
if [[ $? -eq 0 ]]; then
  echo "###"
  echo "This is a protected branch, use a feature branch for quick test"
  echo "###"
else
  echo "Commit and push code to github"
  git commit -a -m "Quick Commit Deploy - Make sure to use squash on Pull Request" && git push
fi

# echo "Deploy code to Puppetmaster"
# ssh -t -l "${user}" ${PUPPETMASTER}.tooling.kpn.org "sudo ${R10K_SCRIPT} --environment ${branch_name} -v "
