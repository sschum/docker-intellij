# docker-intellij
Dockerimage for intellij

This docker image contains the latest IntelliJ Ultimate-Edition. All data will be saved outside a docker container
(with the help of volumes). The user inside the docker container will have the same user- and group id as the user
which run the docker container. To start IntelliJ use the __docker-intellij.sh__ script. For more information use 
the help of this script:
```
docker-intellij.sh -h
```
