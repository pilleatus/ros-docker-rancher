# ros-docker-rancher
This is an example for using ROS nodes in docker containers with rancher as orchestration tool

## Quick start
### installation
- install [docker](https://docs.docker.com/engine/installation/linux/ubuntulinux/)
- if you like, you can allow Docker as a non-root user
```
sudo usermod -aG docker $USER
```
- run a [rancher-server](https://docs.rancher.com/rancher/v1.6/en/) instance for orchestration.
```
sudo docker run -d --restart=unless-stopped -p 8080:8080 rancher/server
```
- now you should be able to visit the rancher-web-ui, in this example under port 8080, go to tab Infrastructure and add a host on which you will run the containers. If the host is the same as rancher-server is running, you should modify the command by adding the following environment variable. Change the accordingly IP-Address:
```
sudo docker run -d -e CATTLE_AGENT_IP=192.168.5.2  -v /var/run/docker..
```
- to start some containers defined in a docker-compose file, you can download the rancher-compose binary from the bottom of the web-page and add it to your programs..
```
tar xfv rancher-compose-linux*
sudo cp rancher-compose-v0.12.4/rancher-compose /usr/local/bin/
chmod +x  /usr/local/bin/rancher-compose
```
- to allow rancher-compose to interact with the server, you can create a API key on the web interface and add it to your bashrc, for example:
```
echo 'export RANCHER_URL=http://192.168.5.2:8000/v2-beta/projects/1a5' | sudo tee -a /etc/bash.bashrc
echo 'export RANCHER_ACCESS_KEY=<access_key>' | sudo tee -a /etc/bash.bashrc
echo 'export RANCHER_SECRET_KEY=<secret_key>' | sudo tee -a /etc/bash.bashrc
```
### build a image
If you have installed docker you can create a image from the Dockerfile. With the following cammnd a image with the tag ```myrobot:latest``` will be created:
```
docker build -t myrobot .
```
### start some container
Now we can run some containers, defined as services in the docker-compose file:
```
cd rviz
rancher-compose up
```

## Rancher Scheduler
If you have more then one host added to your rancher infrastructure, you can define on which host you want the container to run.
For example, if our robot has a main-pc and small a nuc-pc and both are added to the rancher-infrasturcture. You can define a key/value pair for the scheduler. Go to the rancher-web-ui under INFRASTRUCTURE->HOST->EDIT and add the a new label. As key you may can use hostname and as value for example  myrobot-main-pc and myrobot-nuc-pc.
Now you can add a scheduler rule to your services defined in the docker-compose.yml file:
```
version: '2'
services:
  roscore:
    ...
    labels:
      io.rancher.scheduler.affinity:host_label: hostname=myrobot-main-pc
```
