module HotOrNot
  class Runner
    def self.run_from(file, announcer)
      new CompareUrl.load_from(file), announcer
    end

    def initialize(urls, announcer)
      @urls, @announcer = urls, announcer
    end

    def run!
      @announcer.starting
      @urls.each do |url|
        result = ComparisonResult.for url
        if result.success?
          @announcer.announce_success result
        elsif result.error?
          @announcer.announce_error result
        else
          @announcer.announce_failure result
        end
      end
      @announcer.ending
    end
  end
end
