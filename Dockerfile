# Comments in docker look like this. Just make sure that the hash symbol is at beginning of the line.

# Choose a python tag from https://hub.docker.com/_/python
FROM python:3.10-alpine3.16

# Put your name/website here
LABEL maintainer="1hubert"

# The output from Python will be printed directly to the console
# That prevents delays of messages
ENV PYTHONUNBUFFERED 1

# First path is our local storage, second path will be inside of the container
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Set default directory for running commands to where the Django project will be
WORKDIR /app

# Expose port 8000 from the container to my local machine
EXPOSE 8000

# RUN runs the following set of commands on the Alpine image
# Similar effect could be achieved by RUNning these commands individually, but each RUN would create a new image layer and I want to keep my image lightweight

# By default run in non-dev mode
ARG DEV=false

# Create a new virtual environment for storing python dependencies
RUN python -m venv /py && \
# Upgrade pip
    /py/bin/pip install --upgrade pip && \
# Install dependencies listed in requirements.txt (the containerised txt file)
    /py/bin/pip install -r /tmp/requirements.txt && \

# If DEV=true install dev dependencies. The "fi" ends and if statement
if [ $DEV = true ]; \
    then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
fi && \

# Remove the temporary directory. It's best practice to keep Docker images as lightweight as possible
    rm -rf /tmp && \
# Add a new Alpine OS User. It's not recommended to run your application using the root user
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Update the PATH environmental variable
# PATH is an automatically created variable on linux that defines all executables that can be run
ENV PATH="/py/bin:$PATH"

# Switch to django-user from root
USER django-user
    