# ./openfoam-docker -image=microfluidica/openfoam:2412-slim
docker build --build-arg VERSION=2412 -t openfoam-local:2412 -t openfoam-local-default:2412 .

# docker build --build-arg VERSION=2112 -t openfoam-local:2112 -t openfoam-local-default:2112 .
