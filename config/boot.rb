# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
# Require Google Cloud Secret Manager to enable 'on_container/load_env_secrets'
# loading secrets from GCP to ENV:
require "google/cloud/secret_manager"

# Load swarm/gcp secrets to ENV:
require "on_container/load_env_secrets"
