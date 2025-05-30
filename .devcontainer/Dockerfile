FROM elixir:1.16.2

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
# hadolint ignore=DL3008

RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get -y install inotify-tools \
    && apt-get -y install --no-install-recommends postgresql-client

# Install bash tree
RUN apt-get -y install --no-install-recommends tree 

# Install git iproute2, procps, lsb-release (useful for CLI installs)
RUN apt-get -y install --no-install-recommends git iproute2 procps iproute2 lsb-release ca-certificates 

# install npm
RUN apt-get -y install nodejs npm 

# install postgres
RUN apt-get -y install postgresql postgresql-contrib \
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME 

RUN apt-get update -qq -y && \
    apt-get install -y \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-4-1 \
    libnss3 \
    xdg-utils \
    wget && \
    wget -q -O chrome-linux64.zip https://bit.ly/chrome-linux64-121-0-6167-85 && \
    unzip chrome-linux64.zip && \
    rm chrome-linux64.zip && \
    mv chrome-linux64 /opt/chrome/ && \
    ln -s /opt/chrome/chrome /usr/local/bin/ && \
    wget -q -O chromedriver-linux64.zip https://bit.ly/chromedriver-linux64-121-0-6167-85 && \
    unzip -j chromedriver-linux64.zip chromedriver-linux64/chromedriver && \
    rm chromedriver-linux64.zip && \
    mv chromedriver /usr/local/bin/

ENV PATH="/opt/chrome:${PATH}"

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

USER $USERNAME
ENV HOME /home/vscode