#!/bin/sh

printf "Triggering an $PROJECT_TO_BUILD build on the $CIRCLE_BRANCH branch\n\n"

if [ "$CIRCLE_BRANCH" = "master" ] 
then
  BUILD_INFO=$(curl --request POST \
  --url "https://circleci.com/api/v2/project/github/$ORGANIZATION/$PROJECT_TO_BUILD/pipeline" \
  --header "Circle-Token: $CIRCLE_TOKEN" \
  --header 'content-type: application/json' \
  --data "{\"branch\":\"$CIRCLE_BRANCH\"}")

  printf "$BUILD_INFO"
  printf "\n\nBuild triggered\n\n"
  printf "Follow the progress of the build on \nhttps://circleci.com/gh/$ORGANIZATION/$PROJECT_TO_BUILD/tree/$CIRCLE_BRANCH"
fi
