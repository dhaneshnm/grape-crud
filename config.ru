require 'active_record'
require 'pg'
require 'grape'
require File.expand_path('../api.rb', __FILE__)
require File.expand_path('../db.rb',__FILE__)
use ActiveRecord::ConnectionAdapters::ConnectionManagement
#@environment = 'development'
#@dbconfig = YAML.load(File.read('config/database.yml'))
#ActiveRecord::Base.establish_connection @dbconfig[@environment]
run API
