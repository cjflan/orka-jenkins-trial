FROM jenkins/jenkins:lts

# Found in Orka IP Plan
ENV ORKA_LICENSE <OrkaLicenseKey>

ENV FIREWALL_IP <FirewallIP>
ENV FIREWALL_USER <FirewallUser>
ENV FIREWALL_PASS <FirewallPass> 


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

COPY get_servercert.sh usr/share/orka/get_servercert.sh
RUN chmod +x /usr/share/orka/get_servercert.sh
RUN /usr/share/orka/get_servercert.sh
RUN SERVER_CERT=$(cat servercert.txt)

COPY connect.sh /usr/share/orka/connect.sh
RUN chmod +x /usr/share/orka/connect.sh
RUN /usr/share/orka/connect.sh

COPY configure_cluster.py /usr/share/orka/configure_cluster.py
RUN python3 /usr/share/orka/configure_cluster.py

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY init-pipeline.groovy /usr/share/jenkins/ref/init.groovy.d/init-pipeline.groovy
COPY init-cloud.groovy /usr/share/jenkins/ref/init.groovy.d/init-cloud.groovy