#!bin/sh

if [ -z "$GIT_USER" ] || [ -z "$GIT_REPO" ] || [ -z "$GIT_PATH" ]; then
    echo "GIT_USER, GIT_REPO and GIT_PATH must be defined"
    exit 1
fi

echo "retrieving templates: https://codeload.github.com/${GIT_USER}/${GIT_REPO}/tar.gz/master | tar -xz --strip=2 ${GIT_REPO}-master/${GIT_PATH}"
cd /consul-template/data && curl -s https://codeload.github.com/${GIT_USER}/${GIT_REPO}/tar.gz/master | tar -xz --strip=2 ${GIT_REPO}-master/${GIT_PATH}

# concat all the templates
TEMPLATES=$(find /consul-template/data/ -name "*.tpl" | \
    sed -r 's|/consul-template/data/(.*).tpl|-template /consul-template/data/\1.tpl:/consul-template/output/\1.yml|g' | \
    tr '\n' ' ')
echo "templates string: $TEMPLATES"

# If the data or config dirs are bind mounted then chown them.
# Note: This checks for root ownership as that's the most common case.
# (this is exactly what docker-entrypoint.sh does, and without it the
# dir will be owned by root and we'll get permission denied)
if [ "$(stat -c %u /consul-template/output)" != "$(id -u consul-template)" ]; then
  chown consul-template:consul-template /consul-template/output
fi

echo "running execution command /bin/consul-template $@ $TEMPLATES"
/usr/local/bin/docker-entrypoint.sh $TEMPLATES "$@"
