FROM jenkins/jenkins:lts

# Found in Orka IP Plan
ARG ORKA_LICENSE 

ARG FIREWALL_IP 
ARG FIREWALL_USER 
ARG FIREWALL_PASS 


ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_USER admin
ENV JENKINS_PASS admin
ENV ORKA_USER automated@jenkins.com
ENV ORKA_PASS automated-jenkins

USER root
RUN apt-get update
RUN apt-get install -y \
        curl \
        git \
        openconnect \
        python3 \
        python3-pip
RUN rm -rf /var/lib/apt/lists/*

RUN pip3 install \
            fabric \
            requests

COPY configure_cluster.py /usr/share/orka/configure_cluster.py
COPY connect.sh /usr/share/orka/connect.sh
COPY configure.sh /usr/share/orka/configure.sh
RUN chmod +x /usr/share/orka/connect.sh
RUN chmod +x /usr/share/orka/configure.sh

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY init-pipeline.groovy /usr/share/jenkins/ref/init.groovy.d/init-pipeline.groovy
COPY init-cloud.groovy /usr/share/jenkins/ref/init.groovy.d/init-cloud.groovy