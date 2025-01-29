#!/bin/bash
# set-pipeline.sh

echo " "
echo "Set pipeline on target jeffs-ci-target which is team jeffs-ci-team"
fly --target jeffs-ci-target \
    set-pipeline \
    --pipeline jeffs-concourse-example \
    --config pipeline.yml \
    --load-vars-from ../../../.concourse-secrets.yml \
    --check-creds
echo " "
