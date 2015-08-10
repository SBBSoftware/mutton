class SamplesController < ApplicationController
  before_action :set_msg

  def with_attributes
    @menu = set_menu
  end

  def depth_1
    puts 'here'

  end

  private

  def set_msg
    puts view_paths.map(&:to_s)
    @msg = 'Woooooorld'
  end
end
