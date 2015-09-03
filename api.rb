require File.expand_path('../crud/error_handler', __FILE__)
require File.expand_path('../crud/generic_helpers', __FILE__)
require File.expand_path('../crud/request_template', __FILE__)
class API < Grape::API
	  prefix 'api'
	  format :json
	  paths = [{'modelname' => 'Game','path' => 'games'},{'modelname' => 'School','path' => 'schools'}]
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
	  # new_class = Object.const_set(dynamic_name, new_class)
	  api_classes.each do |new_class|
	    mount new_class
	  end

end