Change Docker data directory on Debian

If you’ve installed Docker with the default settings on Debian, it will be storing Docker images, containers and volumes in /var/lib/docker, which will be an issue if you have /var on its own (usually small) partition.

After using Docker for a while you may start to run out of space on the /var partition, at which point you’ll need to either add more space to that partition or relocate it to somewhere with more space.

Here are the steps to change the directory even after you’ve created Docker containers etc.
Note, you don’t need to edit docker.service or init.d files, as it will read the change from the .json file mentioned below.
Steps

    Edit /etc/docker/daemon.json (if it doesn’t exist, create it)
    Add the following

    {
      "data-root": "/new/path/to/docker-data"
    }

    Stop docker

    sudo systemctl stop docker

    Check docker has been stopped

    ps aux | grep -i docker | grep -v grep

    Copy the files to the new location
    Optionally you could run this inside screen if you have a large amount of data or unreliable ssh connection.

    sudo rsync -axPS /var/lib/docker/ /new/path/to/docker-data

    Options explanation, check out the man page for more info

    -a, --archive             archive mode; equals -rlptgoD (no -H,-A,-X)

    -x, --one-file-system     don't cross filesystem boundaries

    -P                        show progress during transfer

    -S, --sparse              handle sparse files efficiently

    Start Docker back up

    sudo systemctl start docker

    Check Docker has started up using the new location

    docker info | grep 'Docker Root Dir'

    Check everything has started up that should be running

    docker ps

Leave both copies on the server for a few days to make sure no issues arise, then feel free to delete it.

sudo rm -r /var/lib/docker
