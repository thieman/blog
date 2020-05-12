FROM ubuntu:groovy-20200505

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y hugo

COPY . /app

WORKDIR /app

CMD hugo server