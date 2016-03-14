# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# ------------------------------------------------------------------------------
# Pull base image.
FROM kdelfour/supervisor-docker
MAINTAINER Kevin Delfour <kevin@delfour.eu>

# ------------------------------------------------------------------------------
# Install base
RUN apt-get update
RUN apt-get install -y build-essential g++ curl libssl-dev apache2-utils git libxml2-dev sshfs unzip openjdk-7-jre ruby2.0

# ------------------------------------------------------------------------------
# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs



# ------------------------------------------------------------------------------
# Install Sencha-CMD

RUN mkdir /sencha-cmd
WORKDIR /sencha-cmd


RUN curl -o /sencha-cmd/cmd.sh.zip http://cdn.sencha.com/cmd/6.0.2/no-jre/SenchaCmd-6.0.2-linux-amd64.sh.zip && \
    unzip -p /sencha-cmd/cmd.sh.zip > /sencha-cmd/cmd-install.sh && \
    chmod +x /sencha-cmd/cmd-install.sh && \
    /sencha/cmd-install.sh 
    # -q -dir "/opt/sencha-cmd"
    # && \
    # rm /cmd-install.sh /cmd.sh.zip

# Install Sencha 6 SDK (Trial)
RUN mkdir /sencha
WORKDIR /sencha

# RUN mkdir cmd
# RUN mkdir sdk
# RUN curl http://cdn.sencha.com/cmd/6.0.2/no-jre/SenchaCmd-6.0.2-linux-amd64.sh.zip -o sencha-cmd6.zip
RUN curl http://sunnyjacob.co.uk/private_cdn/ext-6.0.1-trial.zip -o sencha6-trial.zip    
# RUN unzip sencha-cmd6.zip -d cmd
RUN unzip sencha6-trial.zip
# RUN cmd/SenchaCmd-6.0.2.14-linux-amd64.sh

# ENV SENCHA_HOME /sencha/
# RUN echo “export GRAILS_HOME=$GRAILS_HOME” >> /home/user/.bashrc
# ENV PATH $GRAILS_HOME/bin:$PATH

# RUN export PATH=$PATH:/sencha/

WORKDIR /


# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone https://github.com/c9/core.git /cloud9
WORKDIR /cloud9
RUN scripts/install-sdk.sh

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js 

# Add supervisord conf
ADD conf/cloud9.conf /etc/supervisor/conf.d/

# ------------------------------------------------------------------------------
# Add volumes
RUN mkdir /workspace
VOLUME /workspace

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 80
EXPOSE 8080
EXPOSE 1337
EXPOSE 3000

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
