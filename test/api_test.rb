require File.expand_path('../test_helper.rb', __FILE__)
class APITest < MiniTest::Test
  include Rack::Test::Methods

  def setup
    # init_db()
  end

  def teardown
    # @connection.release_connection
  end

  def app
    API
  end

  def test_paths_returns_ok
    @paths  = YAML.load(File.read(File.expand_path('../../paths.yml', __FILE__)))
    @paths.each do |path|
      url = '/api/v1/' + path['path'] + '.json'
      get url
      assert last_response.ok?, last_response.body
      content = JSON.parse(last_response.body)
      assert !content.nil?
    end
  end

  def test_id_path
    @paths  = YAML.load(File.read(File.expand_path('../../paths.yml', __FILE__)))
    @paths.each do |path|
      model = Object.const_set(path['modelname'], Class.new(ActiveRecord::Base) {})
      id = model.last.id
      url = '/api/v1/' + path['path'] + '/' + id.to_s + '.json'
      get url
      assert last_response.ok?, last_response.body
      content = JSON.parse(last_response.body)
      assert !content.nil?
      assert_equal model.last.to_json, content['data'].to_json
    end
  end
end
