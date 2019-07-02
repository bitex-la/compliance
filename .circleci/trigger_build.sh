#!/bin/sh

printf "Triggering an $PROJECT_TO_BUILD build on the $CIRCLE_BRANCH branch\n\n"

if [ "$CIRCLE_BRANCH" != "master" ] 
then
  BUILD_INFO=$(curl -X POST -H -d \
    "{}" \
    "https://circleci.com/api/v1/project/$ORGANIZATION/$PROJECT_TO_BUILD/tree/master?circle-token=$CIRCLE_TOKEN")

  printf "\n\nBuild triggered\n\n"
  printf "Follow the progress of the build on \nhttps://circleci.com/gh/$ORGANIZATION/$PROJECT_TO_BUILD/tree/$CIRCLE_BRANCH"
fi