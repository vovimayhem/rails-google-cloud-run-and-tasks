# frozen_string_literal: true

#= Performable
# Implements common functionality for services
module Performable
  extend ActiveSupport::Concern

  # A conflict between Rubocop Naming/RescuedExceptionsVariableName
  # and :reek:UncommunicativeVariable over the "e" variable...
  def perform
    perform!
  rescue StandardError => e
    return false unless e.is_a? NoMethodError

    raise
  end

  #= Performable::ClassMethods
  # Implements common class-level functionality for services
  module ClassMethods # :nodoc:
    def perform(*args)
      new(*args).perform
    end

    def perform!(*args)
      new(*args).perform!
    end
  end
end
