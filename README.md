# orka-jenkins-trial
Automatic Creation and Configuration of Orka and Jenkins 

## Usage
1. Install Docker Desktop
2. Download IP Plan from MacStadium Portal
3. Clone this repo locally
4. Input credentials from IP Plan into Dockerfile
5. Run the below commands
6. Go to localhost:8080 and click the run button for the Orka Pipeline job

## Commands
1. `git clone https://github.com/cjflan/orka-jenkins-trial.git`
2. Build the Docker Image
```
docker build --build-arg FIREWALL_IP=      \
             --build-arg FIREWALL_USER=    \
             --build-arg FIREWALL_PASS=    \
             --build-arg ORKA_LICENSE=     \
             --tag orka/plugins:jenkins-demo .
```
3. `docker run -d --privileged -p 8080:8080 -p 50000:50000 --name orka-jenkins orka/plugins:jenkins-demo`
4. `docker exec -ti orka-jenkins ./usr/share/orka/configure.sh`
