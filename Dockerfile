# I: Runtime Stage: ============================================================
# This is the stage where we build the runtime base image, which is used as the
# common ancestor by the rest of the stages, and contains the minimal runtime
# dependencies required for the application to run:

# Use the official Ruby 2.7.1 Slim Buster image as base:
FROM ruby:2.7.1-slim-buster AS runtime

# We'll set MALLOC_ARENA_MAX for optimization purposes & prevent memory bloat
# https://www.speedshop.co/2017/12/04/malloc-doubles-ruby-memory.html
ENV MALLOC_ARENA_MAX="2"

# We'll set the LANG encoding to be UTF-8 for special character support:
ENV LANG C.UTF-8

# We'll install the apt packages required for the app to run:
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    openssl \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# II: Testing stage: ======================================================

# Continue from the "runtime" stage:
FROM runtime AS testing

# Install gnupg
RUN apt-get update \
 && apt-get install -y --no-install-recommends gnupg \
 && rm -rf /var/lib/apt/lists/*

# Add nodejs debian LTS repo:
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Add the Yarn debian repository:
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install the app build system dependency packages:
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gnupg \
    git \
    nodejs \
    sudo \
    yarn \
 && rm -rf /var/lib/apt/lists/*

# Build the su-exec executable - used to de-escalate from root on the final
# releasable image, instead of sudo:
RUN curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c \
 && gcc -Wall /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec \
 && chown root:root /usr/local/bin/su-exec \
 && chmod 0755 /usr/local/bin/su-exec \
 && rm /usr/local/bin/su-exec.c

# Receive the developer user's UID, GID and username:
ARG DEVELOPER_UID=1000
ARG DEVELOPER_GID=${DEVELOPER_UID}
ARG DEVELOPER_USERNAME=you

# Set the developer's UID, GID and username as environment variables:
ENV DEVELOPER_UID=${DEVELOPER_UID} \
    DEVELOPER_GID=${DEVELOPER_GID} \
    DEVELOPER_USERNAME=${DEVELOPER_USERNAME}

# Create the developer group and user:
RUN addgroup --gid ${DEVELOPER_GID} ${DEVELOPER_USERNAME} \
 ; useradd -r -m -u ${DEVELOPER_UID} --gid ${DEVELOPER_GID} \
   --shell /bin/bash -c "Developer User,,," ${DEVELOPER_USERNAME}

# Add the developer user to the sudoers list:
RUN echo "${DEVELOPER_USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/${DEVELOPER_USERNAME}"

# Set the developer user as the current user:
USER ${DEVELOPER_USERNAME}

# Create the app directory (hopefully with the developer user as owner... using
# Kaniko seems to disregard the 'USER' step...)
RUN mkdir /home/${DEVELOPER_USERNAME}/rails-google-cloud-run-and-tasks

# Set '/home/DEVELOPER_USERNAME/rails-google-cloud-run-and-tasks' path as the
# working directory:
WORKDIR /home/${DEVELOPER_USERNAME}/rails-google-cloud-run-and-tasks

# Add the project's "bin" folder to $PATH:
ENV PATH=/home/${DEVELOPER_USERNAME}/rails-google-cloud-run-and-tasks/bin:$PATH

# Copy the project's Gemfile + lock:
COPY --chown=${DEVELOPER_USERNAME} Gemfile* /home/${DEVELOPER_USERNAME}/rails-google-cloud-run-and-tasks/

# Install the gems in the Gemfile, except for the ones in the "development"
# group, which shouldn't be required in order to run the tests with the leanest
# Docker image possible:
RUN bundle install --jobs=4 --retry=3 --without="development"

# Copy the project's node package dependency lists:
COPY --chown=${DEVELOPER_USERNAME} package.json yarn.lock /home/${DEVELOPER_USERNAME}/rails-google-cloud-run-and-tasks/

# Install the project's node packages:
RUN yarn install

# III: Development Stage: ======================================================
# In this stage we'll install all the project's development libraries, and
# the default development commands.

# Continue from the "testing" stage:
FROM testing AS development

# Add development-time dependencies:
RUN sudo apt-get update \
 && sudo apt-get install -y --no-install-recommends \
    openssh-client \
 && sudo rm -rf /var/lib/apt/lists/*

# Set the default command:
CMD [ "rails", "server", "-b", "0.0.0.0" ]

# Install the current project gems - they can be safely changed later during the
# development session via `bundle install` or `bundle update`:
RUN bundle install --jobs=4 --retry=3 --with="development"

# IV: Builder stage: ===========================================================
# In this stage we'll add the rest of the code, compile assets, and perform a 
# cleanup for the releasable image.

# Continue from the testing stage:
FROM testing AS builder

# Copy the complete application code
COPY --chown=${DEVELOPER_USERNAME} . /srv/rails-google-cloud-run-and-tasks

# Set the working directory:
WORKDIR /srv/rails-google-cloud-run-and-tasks

# Precompile the application assets:
RUN export SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece RAILS_ENV=production \
 && rails assets:precompile \
 # Test if everything is OK:
 && rails secret > /dev/null

# Remove installed gems that belong to the development & test groups -
# we'll copy the remaining system gems into the deployable image on the next
# stage:
RUN bundle config without development test \
 && bundle clean --force \
 # Remove unneeded files (cached *.gem, *.o, *.c)
 && sudo rm -rf /usr/local/bundle/cache/*.gem \
 && sudo find /usr/local/bundle/gems/ -name "*.c" -delete \
 && sudo find /usr/local/bundle/gems/ -name "*.o" -delete

# Remove files not used on release image:
RUN rm -rf \
    .rspec \
    Guardfile \
    bin/rspec \
    bin/checkdb \
    bin/dumpdb \
    bin/restoredb \
    bin/setup \
    bin/spring \
    bin/update \
    bin/dev-entrypoint.sh \
    config/spring.rb \
    spec \
    config/initializers/listen_patch.rb

# VI: Release stage: ===========================================================
# In this stage, we build the final, releasable, deployable Docker image, which
# should be smaller than the images generated on previous stages:

# Continue from the runtime stage image:
FROM runtime AS release

# Set the default command:
CMD [ "puma", "-e" , "production" ]

# Copy the remaining installed gems from the "builder" stage:
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy the su-exec executable:
COPY --from=builder /usr/local/bin/su-exec /usr/local/bin/su-exec

# Copy from app code from the "builder" stage:
COPY --from=builder --chown=nobody:nogroup /srv/rails-google-cloud-run-and-tasks /srv/rails-google-cloud-run-and-tasks

# Set the installed app directory as the working directory:
WORKDIR /srv/rails-google-cloud-run-and-tasks

# Set the RAILS/RACK_ENV and PORT default values:
ENV HOME=/srv/rails-google-cloud-run-and-tasks RAILS_ENV=production RACK_ENV=production PORT=3000

# Set the container user to 'nobody':
USER nobody

# Add label-schema.org labels to identify the build info:
ARG SOURCE_BRANCH="master"
ARG SOURCE_COMMIT="000000"
ARG BUILD_DATE="2017-09-26T16:13:26Z"
ARG IMAGE_NAME="vovimayhem/rails-google-cloud-run-and-tasks:latest"
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="rails-google-cloud-run-and-tasks" \
      org.label-schema.description="rails-google-cloud-run-and-tasks" \
      org.label-schema.vcs-url="https://github.com/vovimayhem/rails-google-cloud-run-and-tasks.git" \
      org.label-schema.vcs-ref=$SOURCE_COMMIT \
      org.label-schema.schema-version="1.0.0-rc1" \
      build-target="release" \
      build-branch=$SOURCE_BRANCH
