#!/bin/bash
#If running this script on an account with large images, uncomment the docker image prune line (WARNING: This will delete all unused images on your local, but may be necessary since some account images can be ~10 GB). Also change TARGET ACCOUNT/PROFILE info.
TARGET_ACCOUNT_REGION="us-east-1"
TARGET_PROFILE="<source account profile>"

DESTINATION_ACCOUNT_REGION="us-east-1"
DESTINATION_ACCOUNT="<destination account number>"
DESTINATION_PROFILE="<destination account profile>"
DESTINATION_ACCOUNT_BASE_PATH="${DESTINATION_ACCOUNT}.dkr.ecr.${DESTINATION_ACCOUNT_REGION}.amazonaws.com"

REPO_URIS=($(aws ecr describe-repositories --query 'repositories[].repositoryUri' --output text --region $TARGET_ACCOUNT_REGION --profile $TARGET_PROFILE))
REPO_NAME=($(aws ecr describe-repositories --query 'repositories[].repositoryName' --output text --region $TARGET_ACCOUNT_REGION  --profile $TARGET_PROFILE))

checkTags () {
  declare -a ALLTAGS=($(aws ecr describe-images --query 'imageDetails[*]["imageTags"]' --output text --repository-name $1 --region $TARGET_ACCOUNT_REGION --profile $TARGET_PROFILE))
  declare -a REQTAGS=(${ALLTAGS[@]/None/})
  echo ${REQTAGS[@]}
}


migrateRepos () {
  for repo_uri in ${!REPO_URIS[@]}; do
          aws ecr get-login-password --region $TARGET_ACCOUNT_REGION --profile $TARGET_PROFILE | docker login --username AWS --password-stdin ${REPO_URIS[$repo_uri]}
          aws ecr create-repository --repository-name ${REPO_NAME[$repo_uri]} --profile $DESTINATION_PROFILE
          TAGSFORIMAGE=( $(checkTags "${REPO_NAME[$repo_uri]}") );
          echo "Tags for image ${REPO_NAME[$repo_uri]} are: ${TAGSFORIMAGE[@]}"
          for tag in ${TAGSFORIMAGE[@]}; do
            echo "Pulling image ${REPO_URIS[$repo_uri]}:$tag from target account"
            docker pull ${REPO_URIS[$repo_uri]}:$tag
            echo ${REPO_URIS[$repo_uri]} ${DESTINATION_ACCOUNT_BASE_PATH}/${REPO_NAME[$repo_uri]}
            docker tag ${REPO_URIS[$repo_uri]}:$tag ${DESTINATION_ACCOUNT_BASE_PATH}/${REPO_NAME[$repo_uri]}:$tag
            docker logout

            echo Logging into second account
            aws ecr get-login-password --region $DESTINATION_ACCOUNT_REGION --profile $DESTINATION_PROFILE | docker login --username AWS --password-stdin ${DESTINATION_ACCOUNT_BASE_PATH}
            echo Pushing to Destination account
            docker push ${DESTINATION_ACCOUNT_BASE_PATH}/${REPO_NAME[$repo_uri]}:$tag
            #docker image prune -af
          done
  done
}

migrateRepos
