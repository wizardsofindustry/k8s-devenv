FROM jenkins/jenkins:lts
  # Install some plugins expected by the infrastructure.
  RUN /usr/local/bin/install-plugins.sh cloudbees-folder:6.7
  RUN /usr/local/bin/install-plugins.sh credentials
  RUN /usr/local/bin/install-plugins.sh git
  RUN /usr/local/bin/install-plugins.sh gitlab-plugin:1.5.11
  RUN /usr/local/bin/install-plugins.sh docker-slaves
  RUN /usr/local/bin/install-plugins.sh role-strategy
  RUN /usr/local/bin/install-plugins.sh kubernetes-credentials-provider:0.11
  RUN /usr/local/bin/install-plugins.sh kubernetes:1.14.3
  RUN /usr/local/bin/install-plugins.sh kubernetes-cd:0.2.3
  COPY quantum.groovy /usr/share/jenkins/ref/init.groovy.d/quantum.groovy
