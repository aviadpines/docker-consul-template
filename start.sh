#!bin/sh

if [ -z "$GIT_USER" ] || [ -z "$GIT_REPO" ] || [ -z "$GIT_PATH" ]; then
    echo "GIT_USER, GIT_REPO and GIT_PATH must be defined"
    exit 1
fi

echo "templates location: https://codeload.github.com/${GIT_USER}/${GIT_REPO}/tar.gz/master | tar -xz --strip=2 ${GIT_REPO}-master/${GIT_PATH}"

cd /consul-template/data && curl https://codeload.github.com/${GIT_USER}/${GIT_REPO}/tar.gz/master | tar -xz --strip=2 ${GIT_REPO}-master/${GIT_PATH}

/bin/consul-template "$@"
