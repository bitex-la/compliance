#!/bin/sh

printf "Triggering an $PROJECT_TO_BUILD build on the $CIRCLE_BRANCH branch\n\n"

if [ "$CIRCLE_BRANCH" = "master" ] 
then
  BUILD_INFO=$(curl --request POST \
  --url "https://circleci.com/api/v2/project/github/$ORGANIZATION/$PROJECT_TO_BUILD/pipeline" \
  --header 'Circle-Token: aae23a3f48ce2b01bcf361f2820411aafb67a7c8' \
  --header 'content-type: application/json' \
  --data '{"branch":"master"}')

  printf "$BUILD_INFO"
  printf "\n\nBuild triggered\n\n"
  printf "Follow the progress of the build on \nhttps://circleci.com/gh/$ORGANIZATION/$PROJECT_TO_BUILD/tree/$CIRCLE_BRANCH"
fi
