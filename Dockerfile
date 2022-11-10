FROM python:3-slim-buster

# Install all the required packages
WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app
RUN apt-get -qq update
RUN apt-get -qq install -y --no-install-recommends curl git gnupg2 unzip wget pv jq

# install required packages
RUN apt-get update && apt-get -y install python build-essential
ENV LANG C.UTF-8
ENV PORT=10000

# we don't have an interactive xTerm
ENV DEBIAN_FRONTEND noninteractive

# sets the TimeZone, to be used inside the container
ENV TZ Asia/Kolkata

# rclone
RUN curl https://rclone.org/install.sh | bash

# Copies config(if it exists)
COPY . .

# Install requirements and start the bot
RUN npm install

#install requirements
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# setup workdir
COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx.conf /etc/nginx/nginx.conf
RUN dpkg --add-architecture i386 && apt-get update && apt-get -y dist-upgrade

CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon on;' && cd /usr/src/app && mkdir Downloads && bash start.sh
