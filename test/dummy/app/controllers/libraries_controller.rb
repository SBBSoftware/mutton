class LibrariesController < ApplicationController
  before_action :setup_data

  def setup_data
    @person = { firstName: 'Bob', lastName: 'Bobertson' }
  end
end
