#
# Dockerfile for dr_py
#

# FROM python:3.7-alpine as builder
FROM python:3.8-slim as builder

RUN set -ex \
  && apk add --update --no-cache \
     alpine-sdk \
     libffi-dev \
     libxslt-dev \
  && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /builder
COPY requirements.txt /builder

RUN set -ex \
  && pip install --upgrade pip \
  && mkdir whl \
  && pip wheel -r requirements.txt -w ./whl \
  && ls whl

FROM python:3.7-alpine

COPY --from=builder /builder /builder
COPY docker-entrypoint.sh /entrypoint.sh
COPY supervisord.init /etc/supervisord.init

ENV REPO_URL https://gitcode.net/qq_32394351/dr_py.git

RUN set -ex \
  && apk add --update --no-cache \
     git \
     libstdc++ \
     libxslt \
  && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /builder

RUN set -ex \
  && ls whl \
  && pip install --upgrade pip \
  && pip install --no-index --find-links ./whl -r requirements.txt \
  && rm -rf /builder

WORKDIR /root/sd/pywork/dr_py
VOLUME /root/sd/pywork/dr_py

ENV PYTHONUNBUFFERED=1
ENV AUTOUPDATE=

ENV PORT=5705

EXPOSE 5705

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord","-c","/etc/supervisord.conf"]
