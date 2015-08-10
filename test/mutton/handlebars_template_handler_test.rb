require 'test_helper'
class HandlebarsTemplateHandlerTest < ActiveSupport::TestCase

  def setup
    @handler = Mutton::HandlebarsTemplateHandler.new(nil)
    @msg = 'Woooooorld'
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

  test 'render template with plain text' do
    expected = 'I am the template in hbs'
    content = @handler.render_handlebars('codeless/plain', Rails.application.assets)
    assert_match expected, content
  end

  test 'render template with html' do
    expected = File.open(Rails.root.join('app', 'handlebars', 'templates', 'codeless', 'with_html.hbs'), 'r').read
    content = @handler.render_handlebars('codeless/with_html', Rails.application.assets)
    assert_match expected, content
  end

  test 'render template with partial and assigns' do
    expected = "<p>The message is hello Woooooorld</p>\n<p>Including: I am a partial with the message: Woooooorld\n</p>"
    content = @handler.render_handlebars('samples/depth_1', Rails.application.assets, msg: @msg)
    assert_match expected, content
  end

  test 'render template with partials using attribute set' do
    content = @handler.render_handlebars('samples/with_attributes', Rails.application.assets, menu: @menu)
    assert_match "Today's Starters", content
    assert_match 'Fried Prawns yes prawns', content
    assert_match 'Gammon Steak its gammon, its steak', content
    assert_match "Today's Mains", content
    assert_match 'Roast Pork Its roasted', content
    assert_match 'chicken_tikka its still chicken', content
  end
end
