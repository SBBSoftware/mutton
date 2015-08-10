require 'test_helper'
# integration test to determine browser content after sprockets handling
# TODO: more efficient to reuse handler test
class HandlebarsConverterTest < ActionDispatch::IntegrationTest

  def setup
    Capybara.current_driver = Capybara.javascript_driver
    Rails.application.config.assets.paths << Mutton.sprockets_path
    Mutton.template_namespace = 'JHT'
  end

  test 'returns text without code' do
    visit '/examples/index'
    click_link('without_code')
    wait_for_ajax
    assert find('h4', text: 'Hello world, I have no code')
  end

  test 'return code with blocks but no partials' do
    visit '/examples/index'
    click_link('no_partials')
    wait_for_ajax
    assert find('h4', text: "Today's Starters")
    assert find('p', text: 'Fried Prawns yes prawns')
    assert find('p', text: 'Gammon Steak its gammon, its steak')
  end

  test 'return code with blocks with partials' do
    visit '/examples/index'
    click_link('partials_included')
    wait_for_ajax
    assert find('h4', text: "Today's Starters")
    assert find('p', text: 'Fried Prawns yes prawns')
    assert find('p', text: 'Gammon Steak its gammon, its steak')
    assert find('h4', text: "Today's Mains")
    assert find('p', text: 'Roast Pork Its roasted')
    assert find('p', text: 'chicken_tikka its still chicken')
  end

  test 'partial in same directory must have a directory prefix' do
    visit '/examples/index'
    click_link('partials_within_directory')
    wait_for_ajax
    assert find('p', text: 'Let them puff all about mine ears, present me')
  end

  test 'partial does not need underscore if set to everything' do
    visit '/examples/index'
    click_link('partials_without_underscore')
    wait_for_ajax
    assert find('p', text: "Who wears my stripes impress'd upon him")
  end

  test 'return evaluation including helpers in default directory' do
    visit '/examples/index'
    click_link('uses_helpers')
    wait_for_ajax
    assert find('p', text: 'The name is: Bob Bobertson')
    assert find('p', text: 'Who am I? I am Mutton')
  end

  test 'javascript registered partial' do
    skip
  end

end
