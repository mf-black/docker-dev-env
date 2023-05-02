# Docker as Your Dev Environment Tutorial

This tutorial will guide you through setting up Docker as your local development environment. You will learn how to install Docker, create a Dockerfile, build and run a Docker container, and use Docker effectively for your projects.

## Prerequisites

- Basic understanding of Docker and containers
- A computer with Docker installed (instructions provided)

## Table of Contents

1. [Installing Docker](#installing-docker)
2. [Quickstart](#Quickstart)
3. [Creating a Dockerfile](#creating-a-dockerfile)
4. [Building the Docker Image](#building-the-docker-image)
5. [Running the Docker Container](#running-the-docker-container)
6. [Best Practices for Using Docker Effectively](#best-practices-for-using-docker-effectively)
7. [Conclusion](#conclusion)

## Installing Docker

Install Docker on your computer using the official Docker documentation at this link:

[Docker Installation Guide](https://docs.docker.com/get-docker/)

Once you have successfully installed Docker, make sure it is running before proceeding to the next section of the tutorial.

## Quickstart

1. Clone the repository to your local machine.

2. Build the Docker image

    Navigate to the repository directory and build the Docker image usinf the provided `Dockerfile`:
    ```bash
    docker build -t <image_name> .
    ```

3. Run the Docker container

    Create and start a new Docker container using the built image:
    ```bash
    docker run -it --rm \
        --name <container_name> \
        -v ${PWD}:/app \
        <image_name> \
        /bin/bash
    ```
    replace `<container_name>` with a name for your Docker container, and `<image_name>` with the name you used in the previous step.

4. Develop your project

    Now, you're inside the Docker container with your project files mounted. You can start developing your project using the tools and dependencies provided by the container. With this setup, any changes made to the project files on your host machine are immediately reflected inside the container, and vice versa.

## Creating a Dockerfile

A Dockerfile is a script containing instructions to create a Docker image. It is a text file that contains a set of commands that Docker executes in the order they are written. In this section, we'll discuss the provided Dockerfile and explain the purpose of each instruction.

Here's the Dockerfile:

```docker
FROM ubuntu:22.04
```

`FROM` specifies the base image for the Docker container. In this case, we are using the official Ubuntu 22.04 image. This means that our container will be built on top of the Ubuntu 22.04 distribution, inheriting its system libraries and utilities.

```docker
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
```

`RUN` is used to execute commands during the image building process. In this case, we are updating the package list, setting `DEBIAN_FRONTEND` to noninteractive to avoid prompts during installation, and installing several common dependencies, including Git, cURL, Wget, Unzip, Groff, Less, Glibc source, Python3-pip, Node.js, and NPM. These tools are required for various development tasks and interacting with AWS services. Feel free to add/remove tools to customize for your workflow.

```docker
# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip
```

This `RUN` command downloads and installs AWS CLI v2, a command-line tool for managing AWS services. It downloads the AWS CLI package, unzips it, installs it, and then removes the installation files to save space.

```docker
# Install tfenv (Terraform Version Manager)
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
    echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(tfenv init -)"' >> ~/.bashrc && \
    /root/.tfenv/bin/tfenv install 1.4.2 && \
    /root/.tfenv/bin/tfenv use 1.4.2
```

This command installs tfenv, a Terraform version manager, allowing you to switch between different versions of Terraform easily. It clones the tfenv repository, adds the tfenv binary to the PATH, initializes tfenv, installs Terraform 1.4.2, and sets it as the default version.

```docker
# Install Go
RUN wget https://golang.org/dl/go1.20.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.2.linux-amd64.tar.gz && \
    rm go1.20.2.linux-amd64.tar.gz
```

This command downloads and installs the Go programming language, which is required for developing Go applications. It downloads the Go binary, extracts it to `/usr/local`, and then removes the downloaded archive.

```docker
ENV PATH="${PATH}:/usr/local/go/bin"
```

`ENV` is used to set environment variables within the container. This command adds the Go binary to the `PATH` environment variable, making the go command available for use throughout the container.

```docker
# Install AWSume
RUN pip3 install awsume==4.5.3 && \
    echo 'alias awsume="source awsume"' >> ~/.bashrc
```

This command installs AWSume, a tool that simplifies working with AWS profiles and temporary credentials. It installs AWSume using pip3 and creates an alias for the `awsume` command in the `.bashrc` file to ensure it's properly sourced.

```docker
# Clean up APT cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

To reduce the size of the final Docker image, this command cleans the APT cache and removes the package lists that were downloaded during the earlier `apt-get update` step.

```docker
# Create a working directory
WORKDIR /app
```

`WORKDIR` sets the working directory for any subsequent `RUN`, `CMD`, `ENTRYPOINT`, `COPY`, and `ADD` instructions. In this case, we set the working directory to `/app`. If the directory does not exist, Docker will create it when building the image.

This Dockerfile provides a development environment with essential tools and utilities pre-installed, such as Git, Node.js, NPM, Python, Go, Terraform, and AWS CLI. It is designed to facilitate working with AWS and streamline the development process.

## Building the Docker Image

Once you have created the Dockerfile, you need to build the Docker image. A Docker image is a lightweight, stand-alone, executable package that includes everything needed to run your application, including the code, runtime, system tools, libraries, and settings. Building a Docker image creates a snapshot of your application (or in this case environment)and its dependencies, making it easy to share and deploy.

Follow these steps to build the Docker image:

1. Open a terminal or command prompt in the directory containing your Dockerfile.

2. Run the following command to build the Docker image. Replace `<image_name>` with a name for your image, such as `my-dev-environment`.

```bash
docker build -t <image_name> .
```

This command tells Docker to build an image using the Dockerfile in the current directory (indicated by the `.`) and to tag the image with the specified name. The `-t` flag is used to provide a tag for the image, which makes it easier to identify and manage.

Wait for the build process to complete. Docker will execute each command in the Dockerfile, layer by layer, creating an image with all the tools and dependencies you specified. The build process may take a few minutes, depending on your internet connection and system performance.

Once the build is complete, you can verify that the image has been created by running:

```docker
docker images
```

## Running the Docker Container

After building the Docker image, you can use it to create and run a Docker container, which is a running instance of the image. A container provides an isolated environment where your application and its dependencies can run without affecting the host system or other containers.

To create and run a Docker container from your image, follow these steps:

1. Open a terminal or command prompt.

2. Run the following command to create and start a new Docker container. Replace `<container_name>` with a name for your container, and `<image_name>` with the name of the image you built in the previous section.

```bash
docker run -it --rm --name <container_name> -v ~/.aws:/root/.aws -v ${PWD}:/app <image_name> -v ~/.zsh_history:/root/.bash_history /bin/bash
```
This command tells Docker to create and run a new container with the specified name, using the specified image. The `-it` flag is a combination of `-i` and `-t` flags. The `-i` flag keeps STDIN open, and the `-t` flag allocates a pseudo-TTY, which allows you to interact with the container through the terminal. Running the container interactively enables you to use the development tools and utilities inside the container as if they were installed on your local system.
> It is important to include the -it flag when working with development containers, as it allows you to interact with the container in real-time and use the development tools and utilities as if they were installed on your local system.

The `--rm` flag tells Docker to automatically remove the container when it exits. This helps to keep your system clean by not leaving behind stopped containers, which can consume disk space and other resources. When using Docker as a development environment, it's essential to manage containers effectively to prevent clutter and ensure that you're working with the latest configurations.

The `-v` flag is used to create bind mounts, which map local directories or files on your host system to directories or files within the container. In this case, there are two bind mounts created:

1. `-v ~/.aws:/root/.aws`: This bind mount maps the `~/.aws` directory on your host system to the `/root/.aws` directory within the container. This allows the container to access and use your AWS configuration files and credentials stored on your local machine. By creating this bind mount, you enable the container to manage AWS resources seamlessly, as it will have access to your local AWS configuration and credentials.

2. `${PWD}:/app`: This bind mount maps the current directory (`${PWD}`) on your host system to the `/app` directory within the container. This allows you to share files and folders between the host and the container, enabling you to work on your local files while using the tools and dependencies installed in the container. Any changes you make to files in the `/app` directory will be reflected in the corresponding directory on your host system, and vice versa.

3. `~/.zsh_history:/root/.bash_history`: This bind mount maps your local shell history file (in this case, the Zsh history file) to the shell history file within the container. This enables you to persist and access your command history across multiple container sessions. By preserving your command history, you can easily recall and reuse previously executed commands, improving your workflow and productivity within the container. This is especially useful when working with complex or frequently used commands, as you can quickly access them from your history instead of typing them out again. Additionally, the persisted command history provides a reference for any actions you've performed in the container, which can be helpful for troubleshooting and documentation purposes.

Bind mounts allow you to share data between your host system and the container, making it easier to work with your local files and maintain your command history while leveraging the isolated environment provided by the container.

Once the container is running, you will be taken to a command prompt inside the container. You can now use the tools and utilities installed in the container to work on your project. Any changes you make to files in the /app directory will be reflected in the corresponding directory on your host system, and vice versa.

To exit the container, type exit at the command prompt. This will stop the container and return you to your host system's command prompt.

By using Docker containers, you can ensure a consistent development environment across different systems and platforms. This makes it easier for developers to collaborate on projects and reduces the risk of environment-related issues.

## Conclusion

Using Docker as your development environment offers numerous benefits, such as consistency, portability, and ease of collaboration. By following the steps and best practices outlined in this tutorial, you can create a Docker-based development environment tailored to your needs, making it easier to work with AWS and streamline your development process.

With your Docker-based development environment in place, you can now easily share and deploy your development setup across different systems and platforms, ensuring a consistent experience for all developers working on your project.



docker run -it --rm -v ~/.aws:/root/.aws -v ${PWD}:/work -v ~/.zsh_history:/root/.bash_history develop
docker compose run --rm env
add quickstart