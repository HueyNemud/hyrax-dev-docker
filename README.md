# Dockerized Samvera/Hyrax dev. version

This docker image provides an isolated environment to build and run [Samvera/Hyrax](https://github.com/samvera/hyrax) for demo purpose.

This image doesn't provide any way to persist the data stored in Hyrax and hence is not suitable for production.

## Build and run

### 1. Build

1. [Install Docker](https://docs.docker.com/engine/installation) (if not already installed).
2. ``git clone https://github.com/HueyNemud/hyrax-dev-docker``
3. Move to the cloned repo
4. ``docker build -t hyrax-demo . `` Note: This may take a while. Also, the final image might be huge (~2G).

### 2. Run

1. Create a new container exposed on a port XXXX (so you'll be able to connect to http://localhost:XXXX):

``docker run -v -p 3000:3000 --name hyrax-demo hyrax-demo``

2. Once the container started, create the default admin sets and works (see the [Hyrax devlopment guide](https://github.com/samvera/hyrax/wiki/Hyrax-Development-Guide)):

``docker exec -i hyrax-demo rake hyrax:default_admin_set:create hyrax:workflow:load``

``docker exec -i hyrax-demo rails generate hyrax:work DefaultWork``

3. Hyrax is available  http://localhst:3000

**Note** : The admin email admin@example.com is provided with this image. You will still have to create a user with this email on the Hyrax interface to gain admin permissions.

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

The Hyrax source code is cloned during image build time and stored within the container in `/home/hyrax`.

If you modified the Hyrax code and you want to test it in an isolated environment, the simplest way is to create a [bind mount](https://docs.docker.com/engine/admin/volumes/bind-mounts) to share a folder between the container and your machine.

**Warning**: Because the container will add or modify files in the shared foldre, you should **not** set your local repository as the shared folder. Instead, create a new folder and copy your code in it.

For example:

``docker run -v -p 3000:3000 -v /some/host/folder:/home/hyrax/hyrax --name hyrax-demo hyrax-demo``

Then copy (or clone) your code in `/some/host/folder`, install and deploy the application on the docker container (``docker exec -i bash -c "cd /home/hyrax/hyrax && bundle install && cd rake engine_cart:generate && cd hyrax/.internal_test_app"``)

