# Pull upstream changes
echo -e "\033[0;32m====>\033[0m Pull origin..."
git pull

echo -e "\033[0;32m====>\033[0m Initial check..."

# Get current release name
CURRENT_RELEASE=$(git tag --sort=committerdate | tail -1)

# Get lastest release name
RELEASE=$(curl -s https://api.github.com/repos/grafana/grafana/tags | jq | grep -o '"v[0-9]*\.[0-9]*\.[0-9]*"'| head -1 | sed 's/v//g; s/\"//g')

# Exit script if already up to date
if [ "v${RELEASE}" = $CURRENT_RELEASE ]; then
  echo -e "\033[0;32m=>\033[0m Already up to date..."
  exit 0
fi

# Download original Dockerfile and check for change
curl -s -q https://raw.githubusercontent.com/grafana/grafana/v${RELEASE}/packaging/docker/custom/Dockerfile -o original_dockerfile
if ! sha256sum -c --quiet original_dockerfile.sha256sum; then
  echo -e "\033[0;31m===>\033[0m Checksum of the original dockerfile changed"
  echo -e "\033[0;31m=>\033[0m Require manual intervention !"
  exit 1
fi

# Replace "from" line in dockerfile with the new release
sed -i "s#ARG GRAFANA_VERSION.*#ARG GRAFANA_VERSION=\"${RELEASE}\"#" Dockerfile

# Replace README link to grafana release
GRAFANA_BADGE="[![Grafana](https://img.shields.io/badge/Grafana-${RELEASE}-blue.svg)](https://github.com/grafana/grafana/releases/tag/v${RELEASE})"
sed -i "s#\[\!\[Grafana\].*#${GRAFANA_BADGE}#" README.md

# Push changes
git add Dockerfile README.md
git commit -m "Update to grafana version v${RELEASE}"
git push origin master

# Create tag
git tag "v${RELEASE}"
git push --tags
