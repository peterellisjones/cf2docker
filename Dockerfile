# IMAGE 0: CF BUILDER AND LAUNCHER
FROM golang

RUN go get \
  code.cloudfoundry.org/archiver/extractor \
  code.cloudfoundry.org/buildpackapplifecycle \
  code.cloudfoundry.org/bytefmt \
  code.cloudfoundry.org/cacheddownloader \
  code.cloudfoundry.org/goshims/osshim \
  code.cloudfoundry.org/lager \
  code.cloudfoundry.org/systemcerts \
  github.com/cloudfoundry-incubator/credhub-cli/credhub \
  gopkg.in/yaml.v2 \
  && go install code.cloudfoundry.org/buildpackapplifecycle/builder \
  && go install code.cloudfoundry.org/buildpackapplifecycle/launcher

# IMAGE 1: BUILDPACKS
FROM cloudfoundry/cflinuxfs2

RUN mkdir /tmp/buildpacks

ENV GO_BUILDPACK_VERSION=1.8.18
ENV RUBY_BUILDPACK_VERSION=1.7.17
ENV NODEJS_BUILDPACK_VERSION=1.6.23
# ENV JAVA_BUILDPACK_VERSION=4.11

RUN wget "https://github.com/cloudfoundry/go-buildpack/releases/download/v1.8.18/go-buildpack-v$GO_BUILDPACK_VERSION.zip" && unzip "go-buildpack-v$GO_BUILDPACK_VERSION.zip" -d "/tmp/buildpacks/$(echo -n 'go' | md5sum | awk '{print $1}')"
RUN wget "https://github.com/cloudfoundry/ruby-buildpack/releases/download/v$RUBY_BUILDPACK_VERSION/ruby-buildpack-v$RUBY_BUILDPACK_VERSION.zip" && unzip "ruby-buildpack-v$RUBY_BUILDPACK_VERSION.zip" -d "/tmp/buildpacks/$(echo -n 'ruby' | md5sum | awk '{print $1}')"
RUN wget "https://github.com/cloudfoundry/nodejs-buildpack/releases/download/v$NODEJS_BUILDPACK_VERSION/nodejs-buildpack-v$NODEJS_BUILDPACK_VERSION.zip" && unzip "nodejs-buildpack-v$NODEJS_BUILDPACK_VERSION.zip" -d "/tmp/buildpacks/$(echo -n 'nodejs' | md5sum | awk '{print $1}')"
# RUN wget "https://github.com/cloudfoundry/java-buildpack/releases/download/v$JAVA_BUILDPACK_VERSION/java-buildpack-v$JAVA_BUILDPACK_VERSION.zip" && unzip "java-buildpack-v$JAVA_BUILDPACK_VERSION.zip" -d "/tmp/buildpacks/$(echo -n 'java' | md5sum | awk '{print $1}')"

# IMAGE 2: STAGE
FROM cloudfoundry/cflinuxfs2

COPY --from=0 /go/bin/builder /usr/local/bin/builder
COPY --from=1 /tmp/buildpacks /tmp/buildpacks

ENV CF_STACK=cflinuxfs2

ARG APP_PATH
COPY ${APP_PATH} /tmp/app

RUN builder -buildpackOrder go,ruby,nodejs

RUN mkdir /tmp/droplet-contents
RUN tar -xf /tmp/droplet -C /tmp/droplet-contents

# IMAGE 3: RUN
FROM cloudfoundry/cflinuxfs2

COPY --from=0 /go/bin/launcher /usr/local/bin/launcher
COPY --from=2 /tmp/droplet-contents /

ENV PORT=8080
EXPOSE 8080

WORKDIR /app
RUN cp /staging_info.yml .
CMD launcher . "" ""
