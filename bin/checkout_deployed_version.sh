#!/bin/bash
# Checkout locally the version of Xact that is deployed to a given environment.

print_help () {
  echo
  echo 'Checkout locally the version of Xact that is deployed to a given environment.'
  echo 'Deployed version is determined based on the /.version endpoint.'
  echo
  echo 'Usage: bin/checkout_deployed_version.sh <environment>'
  echo
  echo 'Arguments'
  echo " environment - *Required* Environment to checkout locally. Must be one of 'qc', 'integration', 'stage', or 'production'."
  echo
}

if [ -z "$1" ]; then
  print_help
  exit 1
fi

case $1 in
  qc)
    APP_URL='https://qc-tms.govdelivery.com'
    ;;
  integration)
    APP_URL='https://int-tms.govdelivery.com'
    ;;
  stage)
    APP_URL='https://stage-tms.govdelivery.com'
    ;;
  production)
    APP_URL='https://tms.govdelivery.com'
    ;;
  *)
    help
    exit 1
esac

if [ "$1" == 'qc' ]; then
    VERSION='master'
  else
    VERSION=$(curl -# "$APP_URL/.version")
    if ! [[ "$VERSION" =~ ^([0-9]+\.?)+$ ]]; then
      >&2 echo "$VERSION"
      exit 2 
    fi
  fi

git checkout "$VERSION"
