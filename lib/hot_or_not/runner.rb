module HotOrNot
  class Runner
    def self.run_from(file, announcer)
      new CompareUrl.load_from(file), announcer
    end

    def initialize(urls, announcer)
      @urls, @announcer = urls, announcer
    end

    def run!(to_run = :all)
      @to_run = to_run
      @announcer.starting
      @urls.each do |url|
        next unless should_run? url
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

    private
    def should_run?(url)
      return true if @to_run == :all
      Array(@to_run).any? do |to_run|
        url.full_name == to_run || url.short_name == to_run
      end
    end
  end
end
