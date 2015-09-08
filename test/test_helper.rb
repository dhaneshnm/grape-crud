ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'grape'
require 'active_record'
require 'pg'
require File.expand_path '../../api.rb', __FILE__
@environment = 'development'
path = File.expand_path '../../config/database.yml', __FILE__
@dbconfig = YAML.load(File.read(path))
ActiveRecord::Base.establish_connection @dbconfig[@environment]
require File.expand_path '../../api.rb', __FILE__
