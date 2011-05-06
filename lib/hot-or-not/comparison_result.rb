module HotOrNot
  class ComparisonResult

    class << self
      def for(compare_url)
        new compare_url, retreive(compare_url.side_a), retreive(compare_url.side_b)
      end

      private
      def retreive(url)
        RestClient.get(url).tap { |r| raise Exception.new("Invalid response code #{r.code} for '#{url}'") unless r.code.to_s == '200' }
      end
    end

    attr_reader :message

    def initialize(compare_url, side_a_results, side_b_results)
      @compare_url, @side_a_results, @side_b_results = compare_url, side_a_results, side_b_results
      @message, @diff = '', ''
      init
    end

    def success?
      @success
    end

    def side_a_body
      @side_a_body ||= body_by_content_type @side_a_results
    end

    def side_b_body
      @side_b_body ||= body_by_content_type @side_b_results
    end

    def diff(format = :text)
      @diff.to_s format
    end

    def output_to_files_in(directory)
      write_to directory, "side_a", side_a_body
      write_to directory, "side_b", side_b_body
      write_to directory, "diff", diff
    end

    private
    def init
      return if @success = side_a_body == side_b_body
      @message = "#{@compare_url.full_name}: #{@compare_url.url}: Body from #{@compare_url.base_a} did not match body from #{@compare_url.base_b}"
      @diff = Diffy::Diff.new(side_a_body, side_b_body)
    end

    def body_by_content_type(result)
      case result.headers[:content_type]
      when /json/i
        h = JSON.parse result.body
        JSON.pretty_generate h
      else
        result.body
      end
    end

    def write_to(directory, ext, text)
      filename = File.join(directory, "#{@compare_url.short_name}.#{ext}")
      File.open(filename, 'w+') do |f|
        f << text
      end
    end
  end
end
