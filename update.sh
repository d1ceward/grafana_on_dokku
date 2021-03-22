# Pull upstream changes
git pull

# Get current release name
CURRENT_RELEASE=$(git tag | tail -1)

# Get lastest release name
RELEASE=$(curl -s https://api.github.com/repos/grafana/grafana/tags | jq | grep -o '"v[0-9]*\.[0-9]*\.[0-9]*"'| head -1 | sed 's/v//g; s/\"//g')

# Exit script if already up to date
if [ "v${RELEASE}" = $CURRENT_RELEASE ]; then
  exit 0
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
