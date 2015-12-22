module Crud
  module RequestTemplate
    def self.included(sub_class)
      model = sub_class.model
      path  = sub_class.path
      sub_class.namespace path do
        helpers GenericHelpers

        desc 'Get all '+path

        get '/' do
          records = get_data_by_query(model, request)
          { data: records, meta: {}, errors: [] }
        end

        desc 'Get a single  '+model.name

        params do
          requires :id, type: Integer
        end

        get ':id' do
          record = get_data_by_id(model, params[:id])
          { data: record, meta: {}, errors: [] }
        end

        desc 'make a call to '+model.name+"'s relation"

        params do
          requires :id, type: Integer
          requires :relation, type: String
        end

        get ':id/:relation' do
          records = get_relation_data(model, params[:id], params[:relation])
          { data: records, meta: {}, errors: [] }
        end

        desc 'Update '+path+' in bulk'

        put '/' do
          update_many_records(path, request, model)
        end

        desc 'Update a single '+model.name+' record'

        params do
          requires :id, type: Integer
        end

        put ':id' do
          response = update_single_record(path, request, model, params[:id])
          response = {} if response.nil?
          { data: {result: response}, meta: {}, errors: [] }
        end

        desc 'Create a single '+model.name+' record'

        post '/' do
          new_record = create_new_record(path, request, model)
          { data: new_record, meta: {}, errors: [] }
        end

        desc 'Delete a single '+model.name+' record'

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

