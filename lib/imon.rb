module Dolittle
  class IMon

    require 'services'
    require 'fileutils'

    def initialize
      # settings
      @target_stop_file_array = []
      @stop_file_dir = "/usr/local/rms/admin/mon"
      @stop_file_prf = "STOP.MAINT."
      @instance_list_file = @stop_file_dir + "/list"
    end

    def set_target_stop_file(type, arg = nil)
      @target_stop_file_array = []

      case type
      when "each"
        @target_stop_file_array.push arg
      when "instance"
        instance_name = arg
        begin
          res = Service.find(:all, :select => ["instance_name", "host_name", "env_kbn", "engine"], :conditions => "instance_name = '" + instance_name + "'", :group => "host_name")
        rescue
          puts "db/sql error"
          return 1
        end
        res.each do |v|
          host_name_s = v.host_name.split(".")[0]
          # check env
          if v.env_kbn == 1
            svr_host = v.instance_name + "_" + host_name_s
          elsif v.env_kbn == 2
            svr_host = v.instance_name + "_" + host_name_s
          end
          # check engine
          if v.engine == "mysql"
            svr_host = v.instance_name + "_" + host_name_s
          elsif v.engine == "oracle"
            svr_host = v.instance_name
          elsif v.engine == "informix"
            svr_host = v.instance_name
          end
          @target_stop_file_array.push svr_host
        end
      when "list"
        begin
          File.open(@instance_list_file) do |io|
            while line = io.gets
              target = line.chomp
              @target_stop_file_array.push target
            end
          end
        rescue
          puts "open file error"
          return 1
        end
      else
        puts "error"
        puts "type, arg:(each, instance_hostname/instance, instance/list>"
        return 1
      end

      return
    end
    private :set_target_stop_file


    def check_stop_file
      valid_server_array = []
      invalid_server_array = []
      @target_stop_file_array.each do |target|
        stop_file = @stop_file_dir + "/" + @stop_file_prf + target
        if File.exist?(stop_file)
          invalid_server_array.push target
        else
          valid_server_array.push target
        end
      end
      puts
      puts "[monitor status]"
      puts "--starting---------"
      valid_server_array.each do |v|
        puts v
      end
      puts "-------------------"
      puts
      puts "--stopping---------"
      invalid_server_array.each do |v|
        puts v
      end
      puts "-------------------"
    end
    private :check_stop_file


    def ope(option, type, arg = nil)

      set_target_stop_file(type, arg)

      case option
      when "check"
        check_stop_file
      when "start", "stop"
        exec_monitor_ope(option)
      when "startcmd", "stopcmd"
        output_command(option)
      else
        puts "error"
        puts "option:(check/start/stop/startcmd/stopcmd)"
        return 1
      end

      return 0
    end


    def exec_monitor_ope(option)
      puts
      puts option + " monitoring?"
      puts "target:"
      puts "-------------------"
      @target_stop_file_array.each do |v|
        puts v
      end
      puts "-------------------"

      puts "input yes or no"
      while line = STDIN.gets
        if (/^yes$/ =~ line)
          puts
          STDOUT.puts "input text: #{line}"
          if option == "start"
            puts "exec start"
            begin
              @target_stop_file_array.each do |target|
                stop_file = @stop_file_dir + "/" + @stop_file_prf + target
                FileUtils.rm_f(stop_file)
              end
            rescue
              puts "error!"
            end
          elsif option == "stop"
            puts "exec stop"
            begin
              @target_stop_file_array.each do |target|
                stop_file = @stop_file_dir + "/" + @stop_file_prf + target
                FileUtils.touch(stop_file)
              end
            rescue
              puts "error!"
            end
          end
          puts "finished"
          return
        elsif (/^no$/ =~ line)
          puts
          STDOUT.puts "input text: #{line}"
          puts "return"
          return
        else
          puts "invalid text. input yes or no"
        end
      end
    end
    private :exec_monitor_ope


    def output_command(option)
      case option
      when "startcmd"
          command = "rm"
      when "stopcmd"
        command = "touch"
      end
      puts
      puts "[command]"
      puts "----------------------------------------------------------------"
      @target_stop_file_array.each do |target|
        stop_file = @stop_file_dir + "/" + @stop_file_prf + target
        puts command + " " + stop_file
      end
      puts "----------------------------------------------------------------"
    end
    private :output_command

  end

  def self.imon(args)
    # settings
    option = ARGV[1]
    type = ARGV[2]
    arg = ARGV[3]

    mon = IMon.new()
    #mon.check_stop_file
    mon.ope(option, type, arg)
    #mon.check_stop_file
  end

end
