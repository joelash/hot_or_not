module HotOrNot
  class ComparisonResult
    extend Forwardable

    class << self
      def for(compare_url)
        side_a_result = UrlResult.retrieve_for compare_url.side_a, compare_url.options
        side_b_result = UrlResult.retrieve_for compare_url.side_b, compare_url.options
        new compare_url, side_a_result, side_b_result
      end
    end

    attr_reader :message
    def_delegators :@compare_url, :short_name, :full_name

    def initialize(compare_url, side_a_results, side_b_results)
      @compare_url, @side_a_results, @side_b_results = compare_url, side_a_results, side_b_results
      @message = ''
      init_message unless success?
    end

    def success?
      !error? &&
        @side_a_results.code == @side_b_results.code &&
        !different?
    end

    def error?
      @side_a_results.error? || @side_b_results.error?
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

    def different?
      return side_a_body != side_b_body if @diff.nil?
      @diff.diff != side_a_body.gsub(/^/, ' ')
    end

    def output_to_files_in(directory)
      return if success?
      if error?
        write_to directory, "error", message
      else
        write_to directory, "side_a", side_a_body
        write_to directory, "side_b", side_b_body
        write_to directory, "diff", diff
      end
    end

    private
    def init_message
      @message = if error?
                   message = "#{@compare_url.full_name}: #{@compare_url.url}: Error retrieving body"
                   message += "#{$/}  #{@compare_url.base_a} => #{@side_a_results.error_message}" if @side_a_results.error?
                   message += "#{$/}  #{@compare_url.base_b} => #{@side_b_results.error_message}" if @side_b_results.error?
                   message
                 else
                   diff_options = ['-U 3']
                   diff_options += Array(@compare_url.options[:diff]) if @compare_url.options[:diff]

                   @diff = Diffy::Diff.new(side_a_body, side_b_body, :diff => diff_options)
                   "#{@compare_url.full_name}: #{@compare_url.url}: Body from #{@compare_url.base_a} did not match body from #{@compare_url.base_b}"
                 end
    end

    def body_by_content_type(result)
      case result.headers[:content_type]
      when /json/i
        JSON.pretty_generate JSON.parse(result.body).sort
      when /html/i
        @compare_url.options[:selector] ? Hpricot(result.body).search(@compare_url.options[:selector]).to_html : result.body
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
