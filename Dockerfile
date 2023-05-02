FROM ubuntu:22.04

# Install common dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    groff \
    less \
    glibc-source \
    python3-pip=22.0.2+dfsg-1ubuntu0.2 \
    nodejs=12.22.9~dfsg-1ubuntu3 \ 
    npm=8.5.1~ds-1

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Install tfenv (Terraform Version Manager)
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
    echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(tfenv init -)"' >> ~/.bashrc && \
    /root/.tfenv/bin/tfenv install 1.4.2 && \
    /root/.tfenv/bin/tfenv use 1.4.2

# Install Go
RUN wget https://golang.org/dl/go1.20.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.2.linux-amd64.tar.gz && \
    rm go1.20.2.linux-amd64.tar.gz

ENV PATH="${PATH}:/usr/local/go/bin"

# Install AWSume
RUN pip3 install awsume==4.5.3 && \
    echo 'alias awsume="source awsume"' >> ~/.bashrc

# Clean up APT cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a working directory
WORKDIR /app