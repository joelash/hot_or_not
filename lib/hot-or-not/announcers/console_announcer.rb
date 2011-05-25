module HotOrNot
  class ConsoleAnnouncer
    include Announcer

    def initialize(output_dir)
      @output_dir = output_dir
      @start, @results = nil, []
      @output_count = 0
    end

    def starting
      puts "Starting to compare the bodies"
      @start = Time.now
    end

    def ending
      completion_time = Time.now - @start
      counts = Hash.new(0)
      puts
      @results.each do |result_hash| 
        status = result_hash[:status]
        send :"output_#{status}", result_hash
        counts[status] += 1
      end

      puts "Finsihed in %.6f seconds." % [completion_time]
      puts
      puts "#{@results.count} body comparisons, #{counts[:success]} hot bodies, #{counts[:failure]} not-hot bodies, #{counts[:error]} errored bodies"
    end

    def announce_success(result)
      @results << { :status => :success, :result => result }
      print "."
    end

    def announce_failure(result)
      @results << { :status => :failure, :result => result }
      print "N"
    end

    def announce_error(url, error)
      @results << { :status => :error, :url => url, :error => error }
      print "E"
    end

    private
    def output_success result_hash
      #do nothing
    end

    def output_failure result_hash
      result_hash[:result].output_to_files_in results_dir
      to_console "Not Hot:#{$/}#{result_hash[:result].message}"
    end

    def output_error result_hash
      to_console "Error:#{$/}Retreiving #{result_hash[:url].url} raised error: #{result_hash[:error].message}#{$/}#{result_hash[:error].backtrace.join($/)}"
    end
    
    def to_console(message)
      @output_count += 1
      puts "  #{@output_count}) #{message}"
    end

    def results_dir
      @results_dir ||= @output_dir.tap do |dir| 
        FileUtils.rm_rf dir
        FileUtils.mkdir_p dir
      end
    end
  end
end
