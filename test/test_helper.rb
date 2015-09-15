ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'grape'
require 'active_record'
require 'pg'
require File.expand_path '../../db.rb', __FILE__ 
require File.expand_path '../../api.rb', __FILE__		
		

