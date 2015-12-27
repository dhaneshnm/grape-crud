require File.expand_path('../error_handler', __FILE__)
require File.expand_path('../generic_helpers', __FILE__)
require File.expand_path('../request_template', __FILE__)
require 'grape'
require 'grape-swagger'
module Crud
	class ApiMaker
		def self.mountable_paths
		  paths  = YAML.load(File.read(File.expand_path('../../paths.yml', __FILE__)))
		  api_classes = []
		  paths.each do |class_hash|
		    api_classes << Class.new(Grape::API) do
		      include Crud::ErrorHandler
		      version 'v1'
		      format :json

		      @@model = Object.const_set(class_hash['modelname'], Class.new(ActiveRecord::Base) {})
		      @@path = class_hash['path']

		      def self.model
		        @@model
		      end

		      def self.path
		        @@path
		      end

		      include Crud::RequestTemplate
		    end
		  end
		  api_classes
		end
	end
end

