# Dockerized Samvera/Hyrax dev. version

This docker image provides an isolated environment to build and run [Samvera/Hyrax](https://github.com/samvera/hyrax) for demo purpose.

This image doesn't provide any way to persist the data stored in Hyrax and hence is not suitable for production.

## Getting started

### 1. Build

1. [Install Docker](https://docs.docker.com/engine/installation) (if not already installed).
2. ``git clone https://github.com/HueyNemud/hyrax-dev-docker``
3. ``cd hyrax-dev-docker``
4. ``docker build -t hyrax-demo . `` 
**Note**: Buiding may take some time and will create a huge image (~2Gb). Be sure to have enough free space in the docker directory.

### 2. Run

1. Create a new container: 

``docker run -p 3000:3000 --name hyrax-demo hyrax-demo``

2. Wait until Solr and Fedora are up. Open another bash session and create the default admin set and work (see the [Hyrax devlopment guide](https://github.com/samvera/hyrax/wiki/Hyrax-Development-Guide)):

``docker exec -i hyrax-demo rake hyrax:default_admin_set:create hyrax:workflow:load``

``docker exec -i hyrax-demo rails generate hyrax:work DefaultWork``

### 3. Log in

1. Go to http://localhost:3000 (connecting for the first time can take a few seconds because Hyrax is initializing)  

2. Sign up to you Hyrax instance with the email `admin@example.com`. This will create a new account with admin permissions.

3. Log in. You're ready to play with Hyrax!


## Building a specific branch or tag

By default, the image will use the latest revision of the [Hyrax](https://github.com/samvera/hyrax) master.

The build time variables `TAG` and  `BRANCH` allow you to create a Hyrax application based on any release or branch from the official repository.

Examples: 
``docker build --build-arg TAG=v2.0.0 -t hyrax-demo . ``
``docker build --build-arg BRANCH=workflow_style -t hyrax-demo . ``


### About cache busting

When building an image, Docker will cache intermediate layers to make next builds much faster. 
Docker invalidates the cache on RUN commands (e.g. RUN git clone ...) only if the content of the command itself changes. Docker will not detect a new revision of Hyrax as a change. 

Forcing Docker to **always** rebuild Hyrax if there's a new revision available can be easily done with the `REV` build time variable:
``docker build --build-arg REV=$(git ls-remote https://github.com/samvera/hyrax | grep HEAD | cut -f1,1 -) -t hyrax-demo . ``



For more details about cache busting in Docker, see the [Docker documentation](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practice).


## Running your own version of Hyrax
*This has not been tested yet*

The Hyrax source code is cloned during image build time and stored within the container in `/home/hyrax`.

If you modified the Hyrax code and you want to test it in an isolated environment, the simplest way is to create a [bind mount](https://docs.docker.com/engine/admin/volumes/bind-mounts) to share a folder between the container and your machine.

**Warning**: Because the container will add or modify files in the shared foldre, you should **not** set your local repository as the shared folder. Instead, create a new folder and copy your code in it.

For example:

``docker run  -p 3000:3000 -v /some/host/folder:/home/hyrax/hyrax --name hyrax-demo hyrax-demo``

Then copy (or clone) your code in `/some/host/folder`, install and deploy the application on the docker container (``docker exec -i bash -c "cd /home/hyrax/hyrax && bundle install && cd rake engine_cart:generate && cd hyrax/.internal_test_app"``)

