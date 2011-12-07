module HotOrNot
  class UrlResult
    extend Forwardable

    DEFAULT_OPTIONS = { :method => :get }

    class << self
      def retrieve_for(url, options)
        options = DEFAULT_OPTIONS.merge options
        options[:url] = url
        response, error = nil, nil
        start = Time.now
        begin
          response = RestClient::Request.execute(options)
        rescue RestClient::Exception => e
          error = e
        end

        new url, response, error, Time.now - start
      end
    end

    attr_reader :url, :latency
    def_delegators :@response, :code, :body, :headers

    def initialize(url, response, error, latency)
      @url, @error, @latency = url, error, latency
      @response = response || error.response
    end

    def success?
      @error.nil?
    end

    def error?
      !success?
    end

    def error_message
      "The url #{@url} received error: #{@error.message}"
    end

  end
end
