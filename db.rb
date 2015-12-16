# use ActiveRecord::ConnectionAdapters::ConnectionManagement
@environment = 'development'
@dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection @dbconfig[@environment]
