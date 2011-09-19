module HotOrNot
  class InlineAnnouncer
    include Announcer

    def initialize(output_dir)
      @output_dir = output_dir
      @counts = Hash.new(0)
      @start = nil
    end

    def starting
      puts "Starting to compare the bodies"
      @start = Time.now
    end

    def ending
      completion_time = Time.now - @start
      total = @counts.values.reduce(:+)
      puts
      puts "Finished in %.6f seconds." % [completion_time]
      puts
      puts "#{total} body comparisons, #{@counts[:success]} hot bodies, #{@counts[:failure]} not-hot bodies, #{@counts[:error]} errored bodies"
    end

    def announce_success(result)
      @counts[:success] += 1
      say 'Hot', result
    end

    def announce_failure(result)
      @counts[:failure] += 1
      say 'Not Hot', result
      result.output_to_files_in results_dir
    end

    def announce_error(result)
      @counts[:error] += 1
      say 'Error', result
      result.output_to_files_in results_dir
    end

    private
    def say(what, result)
      what += ':'
      puts "%-10s #{result.full_name}" % [what]
    end

    def results_dir
      @results_dir ||= @output_dir.tap do |dir| 
        FileUtils.rm_rf dir
        FileUtils.mkdir_p dir
      end
    end

  end
end
