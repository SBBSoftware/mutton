require 'test_helper'
class TemplateHandlerTest < ActionDispatch::IntegrationTest

  def template_file_content(directory, file)
    File.open(File.join(Rails.root.join(Mutton.template_path, directory), file), 'r').read
  end

  def assert_layout
    assert_select '#titleText'
  end

  def setup
    Capybara.use_default_driver
    Mutton.template_path = Rails.root.join('app', 'handlebars', 'templates')
  end

  test 'return plain text in default directory' do
    get '/codeless/plain'
    sample_file_content = template_file_content('codeless', 'plain.hbs')
    assert_layout
    assert_match sample_file_content, response.body
  end

  test 'return html in default directory' do
    get '/codeless/with_html'
    sample_file_content = template_file_content('codeless', 'with_html.hbs')
    assert_layout
    assert_match sample_file_content, response.body
  end

  test 'return compiled code with no partials' do
    expected_content = 'Hello Woooooorld'
    get '/samples/plain'
    assert_layout
    assert_match expected_content, response.body
  end

  test 'return compiled code with html no partials' do
    expected_content = '<p>The message is hello Woooooorld</p>'
    get '/samples/with_html'
    assert_match expected_content, response.body
  end

  test 'return code with 1 partial in same directory' do
    expected_content = "<p>The message is hello Woooooorld</p>\n<p>Including: I am a partial with the message: Woooooorld\n</p>"
    get '/samples/depth_1'
    assert_layout
    assert_match expected_content, response.body
  end

  test 'return code with 1 partial in the shared directory' do
    expected_content = "<p>The message is hello Woooooorld</p>\n<p>Including Shared: I am a shared partial with the message: Woooooorld\n</p>"
    get '/samples/depth_1_shared'
    assert_layout
    assert_match expected_content, response.body
  end

  test 'a partial does not need to start with _ does it?' do
    expected_content = "<p>The message is hello Woooooorld</p>\n<p>Including Odd Name: I am a non-underscore partial with the message: Woooooorld\n</p>"
    get '/samples/depth_1_name_anything'
    assert_layout
    # page.assert_text expected_content
    assert_match expected_content, response.body
  end

  test 'partials with multiple levels of depth' do
    get '/samples/depth_2'
    expected_content = "<p>I am including I am a shared partial 4 with the message: Woooooorld\n</p>"
    assert_layout
    assert_match expected_content, response.body
  end

  test 'partials with attribute set' do
    get '/samples/with_attributes'
    assert_layout
    assert_match("Today's Starters", response.body)
    assert_match('Fried Prawns yes prawns', response.body)
    assert_match('Gammon Steak its gammon, its steak', response.body)
    assert_match("Today's Mains", response.body)
    assert_match('Roast Pork Its roasted', response.body)
    assert_match('chicken_tikka its still chicken', response.body)
  end

  # javascript files in helper directory. two files
  test 'include javascript defined handler from sprockets' do
    get '/libraries/simple_helper'
    expected_content = 'The name is: The Right Honourable Anthony Eden'
    assert_layout
    assert_match expected_content, response.body
  end

  test 'include javascript custom handlers which accept parameters' do
    get '/libraries/complex_helper'
    expected_content = 'The name is: Bob Bobertson'
    assert_layout
    assert_match expected_content, response.body
  end

  test 'include javascript custom handlers in default directory from multiple files' do
    get '/libraries/many_helpers'
    expected_content_1 = 'The name is: Bob Bobertson'
    expected_content_2 = 'Who am I? I am Mutton'
    assert_layout
    assert response.body.include?(expected_content_1)
    assert response.body.include?(expected_content_2)
  end
end
