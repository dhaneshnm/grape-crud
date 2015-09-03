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
