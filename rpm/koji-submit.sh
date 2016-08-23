#!/usr/bin/env bash
if [ -z ${ENV+x} ]; then
  echo "ENV is not set! Must be \`poc\`, \`qc\`, or \`prod\`" && exit 1;
fi

if [ -z ${SHA+x} ]; then
  echo "SHA is not set!" && exit 1;
fi

if [[ -n ${SCRATCH+x} ]]; then
  maybe_scratch="--scratch"
fi

repo="development/xact"
build_tag="centos6-internal-xact"

cmd="koji build ${maybe_scratch} ${build_tag} 'git+ssh://git@dev-scm.office.gdi/${repo}.git#${SHA}'"
ssh -qt ${ENV}-koji-service1.ep.gdi sudo -u kojiadmin $cmd