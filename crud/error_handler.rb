module Crud
  module ErrorHandler
    def self.included(sub_class)
      sub_class.rescue_from :all do |e|
        Rack::Response.new([{ data: {}, meta: {}, errors: [{ error: e.message, location: e.backtrace_locations.first.to_s, type: e.class.name }] }.to_json], 500,  'Content-type' => 'text/error').finish
      end
    end
  end
end
