require File.expand_path('../test_helper.rb', __FILE__)
class APITest < MiniTest::Test
        include Rack::Test::Methods
        def app
                API
        end

        def test_paths_returns_ok
		@paths  = YAML.load(File.read(File.expand_path( '../../paths.yml',__FILE__)))
		@paths.each do |path|
			get '/api/v1/'+path[0]['path']+'.json'
			assert last_response.ok?
			content = JSON.parse(last_response.body)
			assert !content.nil?
		end
        end
end
