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
COPY ./scripts /scripts

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
# These deps are not going to be deleted
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
# These deps are GOING TO BE DELETED LATER
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
# Install dependencies listed in requirements.txt (the containerised txt file)
    /py/bin/pip install -r /tmp/requirements.txt && \

# If DEV=true install dev dependencies. The "fi" ends and if statement
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \

# Remove the temporary directory. It's best practice to keep Docker images as lightweight as possible
    rm -rf /tmp && \
    apk del .tmp-build-deps && \

# Add a new Alpine OS User. It's not recommended to run your application using the root user
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
# chown - change owner
# We're setting the user of /vol to django-user and the GROUP to django-user
    chown -R django-user:django-user /vol && \
# chmod - change mode
# Now the owner of that directory can make any changes to subdirectories/files
    chmod -R 755 /vol && \
    chmod -R +x /scripts

# Update the PATH environmental variable
# PATH is an automatically created variable on linux that defines all executables that can be run
ENV PATH="/scripts:/py/bin:$PATH"

# Switch to django-user from root
USER django-user

CMD ["start.sh"]
