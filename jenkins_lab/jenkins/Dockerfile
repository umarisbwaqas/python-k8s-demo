FROM jenkins/jenkins:lts

# Switch to root to install additional packages
USER root

# Install Docker CLI using static binary
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.24.tgz | tar xzf - --strip 1 -C /usr/local/bin docker/docker

# Install other dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Add jenkins user to docker group (create group first)
RUN groupadd -g 999 docker && usermod -aG docker jenkins

# Define Terraform version
ENV TERRAFORM_VERSION=1.5.3

# Download and install Terraform
RUN curl -fSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# Verify installation
RUN terraform --version

# Switch back to the Jenkins user
USER jenkins

ENV JENKINS_USER admin
ENV JENKINS_PASS admin

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false



COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/plugins.txt