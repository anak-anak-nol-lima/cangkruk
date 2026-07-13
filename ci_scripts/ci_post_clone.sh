  #!/bin/sh
  set -e
  cd "$CI_PRIMARY_REPOSITORY_PATH"

  if [ -z "$CRYPTO_SECRET_KEY" ]; then
    echo "error: CRYPTO_SECRET_KEY is not set"
    exit 1
  fi

  echo "CRYPTO_SECRET_KEY = $CRYPTO_SECRET_KEY" > Release.xcconfig
  echo "Release.xcconfig generated"
