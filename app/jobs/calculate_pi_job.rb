# frozen_string_literal: true

#= CalculatePiJob
# Used to enqueue a calculation round
class CalculatePiJob < ApplicationJob
  queue_as :default

  def perform(digit_count)
    PiCalculator.perform! digit_count
  end
end
