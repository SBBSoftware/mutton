class ExamplesController < ApplicationController
  before_action :set_menu

  def uses_helpers
    @person = { firstName: 'Bob', lastName: 'Bobertson' }
  end
end
