require File.expand_path('../test_helper.rb', __FILE__)
class APITest < MiniTest::Test
        include Rack::Test::Methods
        def app
                API
        end

        def test_slash_returns_empty_json
                get '/api/'
                assert last_response.ok?
                empty_hash = {}
                assert_equal empty_hash,JSON.parse(last_response.body)
        end
end
