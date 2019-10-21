#!/bin/bash

set -eu

# Bundlerの依存関係をチェックしておく
bundle check || true

# Yarnの依存関係をチェックしておく
yarn check --integrity --silent || true

exec "$@"


