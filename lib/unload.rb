module Dolittle
  def self.unload(args)

    # args
    # database name, table name, outfile_name
    dbname  = args[0]
    tbl     = args[1]
    outfile = args[2]

    # parameter
    username  = 'root'
    password  = 'root'
    separator = ','

    # SQL
    unload_sql = %Q{select * from #{tbl} INTO OUTFILE "#{outfile}" FIELDS TERMINATED BY "#{separator}"}
    puts unload_sql
    puts "Unloading..."

    # SQL execute
    result = system(%Q{mysql #{dbname} -u #{username} --password="#{password}" -e '#{unload_sql}';})
    puts result

  end
end

if __FILE__ == $0
  Dolittle.unload
end
