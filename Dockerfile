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

# II: Build Dependencies: ======================================================
# This stage will be the common base for development, testing and builder
# stages. In this stage we'll add all the compilers and system libraries
# required to build and run the app, and the dependency lists for the app
# itself - since there are different sets of gems (See bundler groups) for
# development, test and "production", we'll leave the installing of these
# libraries to the following stages, so save weight and time on CI/CD.

# Continue from the "runtime" stage:
FROM runtime AS build-deps

# Install gnupg
RUN apt-get update && apt-get install -y --no-install-recommends gnupg && rm -rf /var/lib/apt/lists/*

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
    yarn \
 && rm -rf /var/lib/apt/lists/*

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

# Set '/home/DEVELOPER_USERNAME/prex-messaging' path as the working directory:
WORKDIR /home/${DEVELOPER_USERNAME}/prex-messaging

# Add the project's "bin" folder to $PATH:
ENV PATH=/home/${DEVELOPER_USERNAME}/prex-messaging/bin:$PATH

# Copy the project's Gemfile + lock:
COPY Gemfile* /home/${DEVELOPER_USERNAME}/prex-messaging/

# III: Development Stage: ======================================================
# In this stage we'll install all the project's development libraries, and
# the default development commands.

# Continue from the "build-deps" stage:
FROM build-deps AS development

# Add development-time dependencies:
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    sudo \
 && rm -rf /var/lib/apt/lists/*

# Add the developer user to the sudoers list:
RUN echo "${DEVELOPER_USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/${DEVELOPER_USERNAME}"

# Set the developer user as the current user:
USER ${DEVELOPER_USERNAME}

# Set the default command:
CMD [ "rails", "server", "-b", "0.0.0.0" ]

# Install the current project gems - they can be safely changed later during the
# development session via `bundle install` or `bundle update`:
RUN bundle install --jobs=4 --retry=3

# IV: Testing stage: ===========================================================
# In this stage we'll create an image with the minimal stuff for the test suites
# to run on our CI/CD environment.

# Continue from the "build-deps" stage:
FROM build-deps AS testing

# Install the gems in the Gemfile, except for the ones in the "development"
# group, which shouldn't be required in order to run the tests:
RUN bundle config without development && bundle install --jobs=4 --retry=3
