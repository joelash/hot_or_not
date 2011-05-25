module HotOrNot
  class Runner
    def initialize(urls, announcer)
      @urls, @announcer = urls, announcer
    end

    def run!
      @announcer.starting
      @urls.each do |url|
        begin
          result = ComparisonResult.for url
          if result.success?
            @announcer.announce_success result
          else
            @announcer.announce_failure result
          end
        rescue StandardError, Exception => e
          @announcer.announce_error url, e
        end
      end
      @announcer.ending
    end
  end
end
