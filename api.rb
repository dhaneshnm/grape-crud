require File.expand_path('../crud/api_maker', __FILE__)
require 'grape-swagger'
class API < Grape::API
  prefix 'api'
  format :json


  Crud::ApiMaker.mountable_paths.each do |new_class|
    mount new_class
  end

  add_swagger_documentation
end
