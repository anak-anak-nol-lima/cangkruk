  #!/bin/sh
  set -e
  cd "$CI_PRIMARY_REPOSITORY_PATH"

  if [ -z "$CRYPTO_SECRET_KEY" ]; then
    echo "error: CRYPTO_SECRET_KEY is not set"
    exit 1
  fi

  if [ -z "$SECRET_PASSWORD" ]; then
    echo "error: SECRET_PASSWORD is not set"
    exit 1
  fi

  if [ -z "$SECRET_USERNAME" ]; then
    echo "error: SECRET_USERNAME is not set"
    exit 1
  fi

  echo "SECRET_USERNAME = $SECRET_USERNAME" > Debug.xcconfig
  echo "SECRET_PASSWORD = $SECRET_PASSWORD" > Debug.xcconfig
  echo "CRYPTO_SECRET_KEY = $CRYPTO_SECRET_KEY" > Debug.xcconfig
  echo "Debug.xcconfig generated"

  echo "SECRET_USERNAME = $SECRET_USERNAME" > Release.xcconfig
  echo "SECRET_PASSWORD = $SECRET_PASSWORD" > Release.xcconfig
  echo "CRYPTO_SECRET_KEY = $CRYPTO_SECRET_KEY" > Release.xcconfig
  echo "Release.xcconfig generated"
