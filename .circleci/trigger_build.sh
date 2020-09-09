#!/bin/sh

printf "Triggering an $PROJECT_TO_BUILD build on the $CIRCLE_BRANCH branch\n\n"

if [ "$CIRCLE_BRANCH" = "fix-trigger-ci" ] 
then
  BUILD_INFO=$(curl -X POST https://circleci.com/api/v2/project/$PROJECT_TO_BUILD/pipeline \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --header "Circle-Token: $CIRCLE_TOKEN" \
    -d "{ 'branch': "master" }")

  printf "\n\nBuild triggered\n\n"
  printf "Follow the progress of the build on \nhttps://app.circleci.com/pipelines/github/$ORGANIZATION/$PROJECT_TO_BUILD?branch=$CIRCLE_BRANCH"
fi