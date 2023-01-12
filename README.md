# Psinode image

This image is used to automatically run psinode from prebuild psidk binaries in a docker container on Ubuntu 20.04. This instance of Psinode is exposed to the host on port 8080.

# Command to attach to the psinode container

`docker exec -i -t CONTAINER_ID /bin/bash`

# Scripts available

Scripts available to run within the psinode container are found in the `scripts/` directory:
- `psinode-clean-boot`: Restarts psinode, resetting its database to genesis state
- `psinode-logs`: Shows the log output of the psinode process
- `psinode-start`: Starts psinode if it is currently stopped
- `psinode-status`: Shows the running status of the psinode process
- `psinode-stop`: Safely stops the psinode process

# Features

If the psinode process crashes or stops for any reason with an exit code other than 0, the supervisor process running within this container will make up to 3 attempts to restart the process.

# Updating

To update the image when there's an update to the rolling release, the following commands must be run:

```
docker image build --no-cache -t jamesmart/psidekick:latest -t jamesmart/psidekick:VERSION .
```
```
docker image push jamesmart/psidekick:latest && docker image push jamesmart/psidekick:VERSION
```
