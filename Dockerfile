FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y hugo

COPY . /app

WORKDIR /app

CMD hugo server