# docker run -e SECRET_KEY_BASE=$SECRET_KEY_BASE \
#     -e PHX_HOST='localhost' \
#     -t kkalb

# docker build . -t kkalb

REGION=eu-central-1
REPO_NAME=kkalb
ECR=192247731055.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME
TAG=latest

# build image
echo 'Building image...'
docker build . -t $REPO_NAME

# login to docker
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR

# tagging
echo 'Tagging image...'
docker tag $REPO_NAME:$TAG $ECR:$TAG

# pushing to ECR
echo 'Pushing image to AWS...'
docker push $ECR:$TAG

echo 'Success!'