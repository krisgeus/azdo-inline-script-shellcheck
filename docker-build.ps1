#!/usr/bin/env pwsh

param (
    [string]$dockerimage = "",
    [string]$dockertag = "latest",
    [string]$dockerfile = "Dockerfile.pwsh",
    [switch]$push = $false
)

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name cibuilder --driver docker-container --use
docker buildx ls
docker buildx inspect --bootstrap
if (-not $push) {
    docker buildx build --platform="linux/amd64,linux/arm64" -f ${dockerfile} -t ${dockerimage}:${dockertag} . --progress=plain
}
else {
    docker buildx build --platform="linux/amd64,linux/arm64" -f ${dockerfile} -t ${dockerimage}:${dockertag} -push . --progress=plain
}
