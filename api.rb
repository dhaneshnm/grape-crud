require File.expand_path('../crud/error_handler', __FILE__)
require File.expand_path('../crud/generic_helpers', __FILE__)
require File.expand_path('../crud/request_template', __FILE__)

class API < Grape::API
  prefix 'api'
  format :json
  paths  = YAML.load(File.read(File.expand_path('../paths.yml', __FILE__)))
  api_classes = []
  paths.each do |class_hash|
    api_classes << Class.new(Grape::API) do
      include Crud::ErrorHandler
      version 'v1'
      format :json
      begin
          @@model = eval(class_hash['modelname'])
          @@path = class_hash['path']
        rescue
          @@model = Object.const_set(class_hash['modelname'], Class.new(ActiveRecord::Base) {})
          @@path = class_hash['path']
        end

      def self.model
        @@model
       end

      def self.path
        @@path
       end

      include Crud::RequestTemplate
    end
  end
  api_classes.each do |new_class|
    mount new_class
  end
end
