module Dolittle
  require 'rubygems'
  require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "mysql2",
  :host    => "localhost",
  :username => "root",
  :password => "",
  :database => "dolittle"
)

class Service < ActiveRecord::Base

  validates_uniqueness_of :service_name
  validates_presence_of :service_name, :host_name, :port_num, :engine, :db_name

  def connect
    begin
      con = Mysql2.new(self[:host_name],"dolittle","dolittle",self[:db_name])
      return con
    rescue
      return raise
    end
  end

  def self.set_from_dsn(dsn)
    srv=Service.new

    srv.host_name=dsn.host
    srv.port_num=dsn.port
    srv.engine=dsn.scheme
    srv.db_name=dsn.path.tr("/","")

    return srv
  end
end
end
