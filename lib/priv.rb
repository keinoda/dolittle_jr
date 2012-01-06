module Dolittle

  class Privilege
    require 'rubygems'
    require 'mysql2'

    def initialize()
    end
    #
    # connect db
    #
    def connect_db()
    
      host = 'localhost'
      username = 'root'
      password = ''
      database = 'mysql'

      # connect db
      begin
        db = Mysql2::Client.new(:host => host, :username => username, :password => password, :database => database)
      rescue Mysql2::Error => e
        puts
        puts "[Error:#{e.errno}]"
        puts "#{e.error}"
      end
      return db
    end

    #
    # show priv
    #
    def show_priv(db, sql)
      begin
        rs = db.query(sql)
        rs.each do |row|
          puts
          puts "db : #{row['db']}"
          puts "user : #{row['user']}"
          puts "host : #{row['host']}"
        end
      rescue Mysql2::Error => e
        puts
        puts "[Error:#{e.errno}]"
        puts "#{e.error}"
      end
      return rs
    end

    #
    # exec pviv
    #
    def exec_priv(db, sql)
      begin
        rs = db.query(sql)
        db.query("flush privileges;")
      rescue Mysql2::Error => e
        puts
        puts "[Error:#{e.errno}]"
        puts "#{e.error}"
      end
      return rs
    end
  end

  def priv(args)

    # args
    # usage: [disable|enable|status] <TARGET_DB>
    command = args[0]
    target_db = args[1]

    # set sql
    sql_check = "select db, user, host from db where db like '%#{target_db}';"
    case command
    when 'disable'
      exec_flg = 1
      sql_exec = "update db set db = 'tmp_#{target_db}' where db = '#{target_db}';"
    when 'enable'
      exec_flg = 1
      sql_exec = "update db set db = '#{target_db}' where db = 'tmp_#{target_db}';"
    when 'status'
      sql_exec = ""
    else
      sql_exec = ""
    end

    # output arg
    puts "---------------------------"
    puts "target_db : #{target_db}"
    puts "command   : #{command}"
    puts "---------------------------"

    # connect db
    priv = Privilege.new()
    db = priv.connect_db()

    # check
    puts "sql_check = #{sql_check}"
    priv.show_priv(db, sql_check)

    # exec
    if exec_flg
      puts "sql_exec = #{sql_exec}"
      priv.exec_priv(db, sql_exec)
      priv.show_priv(db, sql_check)
    end
  end
  module_function :priv
end

if __FILE__ == $0
  Dolittle.priv
end
