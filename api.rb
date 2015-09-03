module Crud
  module ErrorHandler
    def self.included(sub_class)
      sub_class.rescue_from :all do |e|
        Rack::Response.new([{ data: {}, meta: {}, errors: [{ error: e.message, type: e.class.name }] }.to_json], 500,  'Content-type' => 'text/error').finish
      end
    end
  end
end
module Crud
  module GenericHelpers
    def parse_request(request)
      JSON.parse(URI.decode(request.body.read))
    end

    def param_hash(request)
      Hash[CGI.parse(request.query_string).map { |key, values| [key.to_sym, values[0] || true] }]
    end

    def split_data(data, model)
      remainders = data.slice!('id')
      data['id'] = data['id'].to_i
      { primary: data, other_fields: remainders }
    end

    def get_data_by_id(model, id)
      model.find(id)
    end

    def get_data_by_query(model, request)
      query = param_hash(request)
      page_number = query.delete(:page)
      offset = query.delete(:offset)
      order_fields = query.delete(:order_by)
      result = apply_query(query, order_fields, model)
    end

    def update_single_record(path, request, model, id)
      name_string = path.to_s.singularize
      record = parse_request(request)[name_string]
      model_instance =  get_data_by_id(model, id)
      data_fields = split_data(record, model)[:other_fields]
      model_instance.update_attributes(data_fields)
    end

    def update_many_records(path, request, model)
      records = parse_request(request)[name_string]
      records.each do |record|
        data_hash = split_data(record, model)
        model_instance = model.find(model.primary_key => data_hash[:primary].values[0])
        model_instance.update_attributes(data_hash[:other_fields])
      end
    end

    def create_new_record(path, request, model)
      name_string = path.to_s.singularize
      record = parse_request(request)[name_string]
      model.create(record)
    end

    def delete_record(model, id)
      model.find(id).destroy
    end

    def get_relation_data(model, id, relation)
      model.find(id).send(relation).uniq
    end

    def apply_query(query, order_fields, model)
      result = query.any? ? construct_where(model, query) : model.all
      result = order_by(result, order_fields) unless order_fields.nil?
      result
    end

    def construct_where(model, query)
      model.where(query)
    end



  end
end

module Crud
  module RequestTemplate
    def self.included(sub_class)
      model = sub_class.model
      path  = sub_class.path
      sub_class.namespace path do
        helpers GenericHelpers

        get '/' do
          records = get_data_by_query(model, request)
          { data: records, meta: {}, errors: [] }
        end

        params do
          requires :id, type: Integer
        end

        get ':id' do
          record = get_data_by_id(model, params[:id])
          { data: record, meta: {}, errors: [] }
        end

        params do
          requires :id, type: Integer
          requires :relation, type: String
        end

        get ':id/:relation' do
          records = get_relation_data(model, params[:id], params[:relation])
          { data: records, meta: {}, errors: [] }
        end


        put '/' do
          update_many_records(path, request, model)
        end

        params do
          requires :id, type: Integer
        end

        put ':id' do
          response = update_single_record(path, request, model, params[:id])
          response = {} if response.nil?
          { data: {result: response}, meta: {}, errors: [] }
        end

        post '/' do
          new_record = create_new_record(path, request, model)
          { data: new_record, meta: {}, errors: [] }
        end

        params do
          requires :id, type: Integer
        end

        delete ':id' do
          count = delete_record(model, params[:id])
          { data: { delete_records: count }, meta: {}, errors: [] }
        end
      end
    end
  end
end


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