ARG PHP_IMAGE=8.3-cli-alpine3.23

FROM --platform=${TARGETPLATFORM:-linux/amd64} php:${PHP_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/bulgac/docker-php-grpc"

ENV TZ="UTC"

COPY --from=ghcr.io/mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/install-php-extensions

ARG XDEBUG_ENABLED=false
ARG PROTOBUF_VERSION="4.29.1"
ARG GRPC_VERSION="1.68.0"

RUN apk update && apk add --no-cache \
  bash \
  ca-certificates \
  icu-data-full icu-libs icu-dev \
  linux-headers \
  lz4-libs \
  openssh-client \
  libzip-dev \
  ca-certificates \
  postgresql-dev \
  libpq-dev \
  protobuf-dev \
  librdkafka-dev \
  git \
  ${PHPIZE_DEPS}

RUN install-php-extensions grpc-${GRPC_VERSION} \
  && install-php-extensions protobuf-${PROTOBUF_VERSION} \
  && install-php-extensions intl \
  && install-php-extensions zip \
  && install-php-extensions curl \
  && install-php-extensions opcache \
  && install-php-extensions pcntl \
  && install-php-extensions sockets \
  && install-php-extensions xsl \
  && install-php-extensions dom \
  && install-php-extensions exif \
  && install-php-extensions bcmath \
  && install-php-extensions rdkafka \
  && install-php-extensions mbstring \
  && install-php-extensions pdo \
  && install-php-extensions pdo_pgsql \
  && install-php-extensions tokenizer \
  && install-php-extensions ctype \
  && install-php-extensions curl \
  && install-php-extensions bz2 \
  && install-php-extensions iconv \
  && install-php-extensions xml \
  && install-php-extensions soap \
  && install-php-extensions apcu \
  && docker-php-ext-enable grpc protobuf

RUN if [ "${XDEBUG_ENABLED}" == "true" ]; then install-php-extensions xdebug && docker-php-ext-enable xdebug; fi

RUN apk del --no-cache ${PHPIZE_DEPS} \
    && rm -rf /tmp/*

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
