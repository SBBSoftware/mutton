require 'test_helper'
class SprocketsHandlebarsConverterTest < ActiveSupport::TestCase

  def setup
    Mutton.template_namespace = 'JHT'
    Rails.application.assets.cache = nil
  end

  test 'should return single handlebar template with all partials exposed' do
    assets = Rails.application.assets
    sample_logical_path = File.join('templates', 'codeless', 'plain.hbs')
    sample_asset_path = Rails.root.join('app', 'handlebars', sample_logical_path)
    # need to invalidate the cache here
    handlebar_asset = assets.find_asset(sample_asset_path)
    assert_equal sample_logical_path.sub!('.hbs', '.js'), handlebar_asset.logical_path
    content = handlebar_asset.source
    assert content.include?('Handlebars.partials = this.JHT')
    assert content.include?("templates['codeless/plain'] = template")
    assert content.include?('})(this)')
  end

  test 'should use custom namespace' do
    custom_namespace = 'TEST_TEST_TEST_ME'
    Mutton.template_namespace = custom_namespace
    assets = Rails.application.assets
    sample_logical_path = File.join('templates', 'codeless', 'plain.hbs')
    sample_asset_path = Rails.root.join('app', 'handlebars', sample_logical_path)
    # need to invalidate the cache here
    handlebar_asset = assets.find_asset(sample_asset_path)
    assert_equal sample_logical_path.sub!('.hbs', '.js'), handlebar_asset.logical_path
    content = handlebar_asset.source
    assert content.include?("Handlebars.partials = this.#{custom_namespace}")
    assert content.include?("templates['codeless/plain'] = template")
    assert content.include?('})(this)')
  end

  test 'all templates should be added to the partial list if partial convention is set to everything' do
    assets = Rails.application.assets
    sample_logical_path = File.join('templates', 'codeless', 'plain.hbs')
    sample_asset_path = Rails.root.join('app', 'handlebars', sample_logical_path)
    # need to invalidate the cache here
    handlebar_asset = assets.find_asset(sample_asset_path)
    assert_equal sample_logical_path.sub!('.hbs', '.js'), handlebar_asset.logical_path
    content = handlebar_asset.source
    assert content.include?('Handlebars.partials = this.JHT;')
  end
end
