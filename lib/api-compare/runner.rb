module ApiCompare
  class Runner
    def initialize(urls, output_dir)
      @urls, @output_dir = urls, output_dir
      @output_count = 0
    end

    def run!
      puts "Started"
      start = Time.now
      results = @urls.map do |url|
        begin
          result = ComparisonResult.for url
          if result.success?
            print "."
            { :status => :success, :result => result }
          else
            print "F"
            { :status => :failure, :result => result }
          end
        rescue StandardError, Exception => e
          print "E"
          { :status => :error, :url => url, :error => e }
        end
      end

      output results, Time.now - start
    end

    private
    def output(result_hashes, completion_time)
      counts = Hash.new(0)
      puts
      result_hashes.each do |result_hash| 
        status = result_hash[:status]
        send :"output_#{status}", result_hash
        counts[status] += 1
      end

      puts "Finsihed in %.6f seconds." % [completion_time]
      puts
      puts "#{result_hashes.count} tests, #{counts[:failure]} failures, #{counts[:error]} errors"
    end

    def output_success result_hash
      #do nothing
    end

    def output_failure result_hash
      result_hash[:result].output_to_files_in results_dir
      to_console "Failure:#{$/}#{result_hash[:result].message}"
    end

    def output_error result_hash
      to_console "Error:#{$/}Retreiving #{result_hash[:url].url} raised error: #{result_hash[:error].message}"
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
