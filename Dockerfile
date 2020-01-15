FROM ubuntu:latest

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    VSCODE=https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable \
    TINI_VERSION=v0.16.1 \
    GOVERSION=1.9.1

ARG VCF_REF
ARG BUILD_DATE
LABEL org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.license="MIT" \
      org.label-schema.name="e.g. VsCode" \
      org.label-schema.url="https://code.visualstudio.com/" \
      org.label-schema.vcs-type="e.g. Git" \
      org.label-schema.vcs-url="e.g.https://github.com/allamand/docker-vscode" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF


RUN apt-get update -qq && \
    echo 'Installing OS dependencies' && \
    apt-get install -qq -y --fix-missing \ 
      sudo software-properties-common libxext-dev libxrender-dev libxslt1.1 \
      libgconf-2-4 libnotify4 libnspr4 \
      libxtst-dev libgtk2.0-0 libcanberra-gtk-module \
      libxss1 \
      libxkbfile1 \
      git curl tree locate net-tools telnet \
      make bash-completion \
      bash-completion python-minimal python-pip meld npm \
      libxkbfile1 \
      libxss1 libnss3 \
       locales netcat
    
RUN npm install -g npm && \
    #pip install --upgrade pip && \
    pip install mkdocs && \
    echo 'Cleaning up' && \
    apt-get clean -qq -y && \
    apt-get autoclean -qq -y && \
    apt-get autoremove -qq -y &&  \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    updatedb && \
    locale-gen en_US.UTF-8

RUN echo 'Installing VsCode' && \
    curl -o vscode.deb -J -L "$VSCODE" && \
    dpkg -i vscode.deb && rm -f vscode.deb && \
    echo "Install OK"

#    echo "Downloading Go ${GOVERSION}" && \
#    echo curl -o /tmp/go.tar.gz -J -L "https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz" && \
#    curl -o /tmp/go.tar.gz -J -L "https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz" && \	    
    
#    echo "Installing Go ${GOVERSION}" && \
#    sudo tar -zxf /tmp/go.tar.gz -C /usr/local/ && \
#    rm -f /tmp/go.tar.gz && \

ENV TERM=xterm

ADD ./entrypoint.sh /entrypoint.sh

# Add Tini Init System
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini && chmod +x /entrypoint.sh
ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
CMD ["bash"]

