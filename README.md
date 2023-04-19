# shresty

serving linux shell via http protocol with openresty(/nginx) 

## Install
Make sure you have installed [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/).  
clone this repository, jump into it:  
``
git clone https://github.com/rodezee/shresty && cd shresty
``
  
and run setup.sh:  
``
./test-shresty.sh
``
  
## Usage
After installation open your browser [http://localhost:1080](http://localhost:1080) to try the hello world example.
``
curl http://localhost:1080/
``
  
## Steps

### step 1
configure openresty to run shell commands

### step 2
encapsule sessions within jails or containers

### step 3
add examples
