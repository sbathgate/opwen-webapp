#!/usr/bin/env bash

set -eo pipefail

if [ -z "$TRAVIS_TAG" ]; then
  echo "Build is not a release, skipping CD" >&2; exit 0
fi

if [ -z "$PYPI_USERNAME" ] || [ -z "$PYPI_PASSWORD" ]; then
  echo "No PyPI credentials configured, unable to publish builds" >&2; exit 1
fi

cleanup() {
  rm -f ~/.pypirc
}
trap cleanup EXIT

cat > ~/.pypirc << EOF
[distutils]
index-servers =
    pypi

[pypi]
username: $PYPI_USERNAME
password: $PYPI_PASSWORD
EOF

echo "$TRAVIS_TAG" > version.txt

py_env="$HOME/virtualenv/python$TRAVIS_PYTHON_VERSION"
python="$py_env/bin/python"

sudo apt-get install -y npm
sudo ln -s /usr/bin/nodejs /usr/bin/node

make prepare-server -e py_env="$py_env"

${python} setup.py sdist upload
