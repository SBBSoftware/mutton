class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def set_menu
    @menu = { starters: [{ name: 'Fried Prawns', description: 'yes prawns' },
                         { name: 'Gammon Steak', description: 'its gammon, its steak' },
                         { name: 'Garlic Mushrooms', description: 'garlicy' }
    ],
              mains: [{ name: 'Roast Pork', description: 'Its roasted' },
                      { name: 'Roast Beef', description: 'Beef!' },
                      { name: 'Roast Chicken', description: 'The other other roast' },
                      { name: 'chicken_tikka', description: 'its still chicken', notes: [{ ingredients: 'with naan' }] }
              ]
    }
  end
end
