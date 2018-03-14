#!/bin/bash

# Fail immediately on non-zero exit code.
set -e
# Debug, echo every command
#set -x

JS_RUNTIME_ENV_PREFIX="${JS_RUNTIME_ENV_PREFIX:-JS_RUNTIME_}"

# Each bundle is generated with a unique hash name to bust browser cache.
# Use shell `*` globbing to fuzzy match.
JS_RUNTIME_TARGET_BUNDLE="${JS_RUNTIME_TARGET_BUNDLE:-/app/build/index.*.js}"

if [ -f $JS_RUNTIME_TARGET_BUNDLE ]
then

  # Get exact filename.
  js_bundle_filename=`ls $JS_RUNTIME_TARGET_BUNDLE`
  
  echo "Injecting runtime env into $js_bundle_filename (from .profile.d/inject_js_runtime_env.sh)"

  # Render runtime env vars into bundle.
  ruby -E utf-8:utf-8 \
    -r /app/.heroku-js-runtime-env/injectable_env.rb \
    -e "InjectableEnv.replace('$js_bundle_filename')"
fi
