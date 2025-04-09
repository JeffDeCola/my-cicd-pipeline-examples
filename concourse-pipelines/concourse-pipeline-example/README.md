# CONCOURSE PIPELINE EXAMPLE

[![jeffdecola.com](https://img.shields.io/badge/website-jeffdecola.com-blue)](https://jeffdecola.com)
[![MIT License](https://img.shields.io/:license-mit-blue.svg)](https://jeffdecola.mit-license.org)

  _A concourse pipeline example that show task steps and how
  concourse handles artifacts. It uses a github repo and separates
  the task steps and script files.
  This should be your goto example to understand concourse._

Table of Contents

* [OVERVIEW](https://github.com/JeffDeCola/my-cicd-pipeline-examples/tree/master/concourse-pipelines/concourse-pipeline-example#overview)
* [PIPELINE](https://github.com/JeffDeCola/my-cicd-pipeline-examples/tree/master/concourse-pipelines/concourse-pipeline-example#pipeline)
* [JOB BUILD](https://github.com/JeffDeCola/my-cicd-pipeline-examples/tree/master/concourse-pipelines/concourse-pipeline-example#job-build)
* [JOB TEST](https://github.com/JeffDeCola/my-cicd-pipeline-examples/tree/master/concourse-pipelines/concourse-pipeline-example#job-test)

## OVERVIEW

This pipeline will outlines the main features of the concourse ci/cd system.
It will build a todays-date.txt file and then test if its there.

![IMAGE - concourse-pipeline-example.svg - IMAGE](../../docs/pics/concourse-pipeline-example.svg)

## PIPELINE

To add the pipeline to concourse I used,

```bash
fly --target jeffs-ci-target \
    set-pipeline \
    --pipeline concourse-pipeline-example \
    --config pipeline.yml \
    --load-vars-from ../../../../.concourse-secrets.yml \
    --check-creds
```

My .concourse-secrets files has the following,

```yml
slack_poo_concourse_webhook_url_token: https://hooks.slack.com/services/{my-token}
repo_github_token: {my-token}
dockerhub_token: {my-token}
concourse_git_private_key: {my-key}
```

![IMAGE](../../docs/pics/concourse-pipeline-example-pipeline.jpg)

## JOB BUILD

Job build has 2 task steps. Its kicked off manually.
The job will first `get` the repo from github and
rename it to my-cicd-pipeline-examples-resource.

* [task-build-step1.yml](https://github.com/JeffDeCola/my-cicd-pipeline-examples/blob/main/concourse-pipelines/concourse-pipeline-example/jobs/build/task-build-step1.yml)
  * **DOCKER IMAGE:** alpine/git
  * **INPUTS:** my-cicd-pipeline-examples-resource
  * **OUTPUTS:** my-artifacts, my-cicd-pipeline-examples-update
  * **RUN:** [task-build-step1.sh](https://github.com/JeffDeCola/my-cicd-pipeline-examples/blob/main/concourse-pipelines/concourse-pipeline-example/jobs/build/task-build-step1.sh)
    * Create a new directory my-artifacts
    * Create a todays-date.txt file and place in my-artifacts
    * Copy the my-cicd-pipeline-examples-resource to my-cicd-pipeline-examples-update

* [task-build-step2.yml](https://github.com/JeffDeCola/my-cicd-pipeline-examples/blob/main/concourse-pipelines/concourse-pipeline-example/jobs/build/task-build-step2.yml)
  * **DOCKER IMAGE:** busybox
  * **INPUT:** my-artifacts, my-cicd-pipeline-examples-update
  * **OUTPUT:** my-cicd-pipeline-examples-push
  * **RUN:** [task-build-step2.sh](https://github.com/JeffDeCola/my-cicd-pipeline-examples/blob/main/concourse-pipelines/concourse-pipeline-example/jobs/build/task-build-step2.sh)
    * Add to todays-date.txt file in my-artifacts
    * Copy my-cicd-pipeline-examples-update to my-cicd-pipeline-examples-push
    * Copy the todays-date.txt file to my-cicd-pipeline-examples-push
    * git add and git commit to the local repo

The job will then `put` the repo to github using the concourse resource
my-cicd-pipeline-examples-push and `put` a slack alert using
the concourse resource resource-slack-alert.

```yaml
- name: job-build
  plan:

  # GET REPO FROM GITHUB (MANUALLY)
  - get: my-cicd-pipeline-examples-resource
    trigger: false

  # STEP 1
  - task: task-build-step1
    file: my-cicd-pipeline-examples-resource/concourse-pipelines/concourse-pipeline-example/jobs/build/task-build-step1.yml

  # STEP 2
  - task: task-build-step2
    file: my-cicd-pipeline-examples-update/concourse-pipelines/concourse-pipeline-example/jobs/build/task-build-step2.yml

    # TASK SUCCESS
    on_success:
      do:
        # PUSH NEW REPO TO GITHUB (add and commit done in shell script)
        - put: my-cicd-pipeline-examples-push
          params:
            repository: my-cicd-pipeline-examples-push
        # SEND SLACK ALERT
        - put: resource-slack-alert
          params:
            channel: '#ci-concourse'
            text: "From my-cicd-pipeline-examples: PASSED job-build in concourse ci."

    # TASK FAILURE
    on_failure:
      do:
        # SEND SLACK ALERT
        - put: resource-slack-alert
          params:
            channel: '#ci-concourse'
            text: "From my-cicd-pipeline-examples: FAILED job-build in concourse ci."
```

## JOB TEST

Job test has 1 task step. The job will first `get` the repo from github and
rename it to my-cicd-pipeline-examples-resource.

* [task-test-step1.yml](https://github.com/JeffDeCola/my-cicd-pipeline-examples/blob/main/concourse-pipelines/concourse-pipeline-example/jobs/test/task-test-step1.yml)
  * **DOCKER IMAGE:** busybox
  * **INPUTS:** my-cicd-pipeline-examples-resource
  * **OUTPUTS:** N/A
  * **RUN:** [task-test-step1.sh](https://github.com/JeffDeCola/my-cicd-pipeline-examples/blob/main/concourse-pipelines/concourse-pipeline-example/jobs/test/task-test-step1.sh)
    * Check if todays-date.txt file exists

The job will then `put` a slack alert using the concourse resource
resource-slack-alert.

```yaml
- name: job-test
  plan:

  # WAIT FOR JOB-BUILD TO FINISH
  - get: my-cicd-pipeline-examples-resource
    passed: [job-build]
    trigger: true

  # STEP 1
  - task: task-test-step1
    file: my-cicd-pipeline-examples-resource/concourse-pipelines/concourse-pipeline-example/jobs/test/task-test-step1.yml

    # TASK SUCCESS
    on_success:
      do:
        # SEND SLACK ALERT
        - put: resource-slack-alert
          params:
            channel: '#ci-concourse'
            text: "From my-cicd-pipeline-examples: PASSED job-test in concourse ci."

    # TASK FAILURE
    on_failure:
      do:
        # SEND SLACK ALERT
        - put: resource-slack-alert
          params:
            channel: '#ci-concourse'
            text: "From my-cicd-pipeline-examples: FAILED job-test in concourse ci."
```
