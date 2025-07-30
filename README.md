# OpenFOAM
- We are running OpenFOAM in the container
- After the successful foam generation process you have to create <FOAMNAME>.foam file to let us use ParaView
- Our tutorials are stored inside `storage/tutorials` folder in this repository 
- After you run Allrun you have to check log files for errors. Because AllRun does not show any errors
# How to run
- `./build.sh` - build custom docker image for local use
- `./openfoam-docker-agent` - run custom docker image 
- `./openfoam-docker` - run default docker image

## Now we are running OpenFOAM here
`docker ps`

```shell
CONTAINER ID   IMAGE          COMMAND           CREATED          STATUS          PORTS     NAMES
32a89421ffe3   7765df51f9fb   "/openfoam/run"   29 minutes ago   Up 29 minutes             pensive_haslett
```
