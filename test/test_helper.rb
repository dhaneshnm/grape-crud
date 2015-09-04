ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'grape'
require 'active_record'
require File.expand_path '../../api.rb', __FILE__
