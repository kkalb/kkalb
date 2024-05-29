# docker run -e SECRET_KEY_BASE=$SECRET_KEY_BASE \
#     -e PHX_HOST='localhost' \
#     -t kkalb_release

# docker build . -t kkalb_release

ECR=192247731055.dkr.ecr.eu-central-1.amazonaws.com/kkalb

# login to docker
aws ecr get-login-password --region 'eu-central-1' | docker login --username AWS --password-stdin $ECR

docker tag $(docker images -q kkalb_release) $ECR:latest

docker push $ECR:latest