module HotOrNot
  class CompareUrl

    attr_reader :url, :base_a, :base_b, :options

    def initialize(name, url, base_a, base_b, options={})
      @name, @url, @base_a, @base_b = name, url, base_a, base_b
      @options = options
    end

    def full_name
      @name
    end

    def short_name
      @short_name ||= @name.underscore.gsub(/\s+/, '_')
    end

    def side_a
      @side_a ||= @base_a + @url
    end

    def side_b
      @side_b ||= @base_b + @url
    end

    def self.load_from(filename)
      contents = YAML.load(run_erb(filename)).symbolize_keys!
      side_a, side_b, comparisons = contents.delete(:side_a), contents.delete(:side_b), contents.delete(:comparisons)
      raise "Your file is not in the proper format" unless side_a && side_b && comparisons
      comparisons.map do |h|
        h.symbolize_keys!
        name = h.delete :name
        url = h.delete :url
        options = contents.merge h
        CompareUrl.new name, url, side_a, side_b, options
      end
    end

    private
    def self.run_erb(filename)
      contents = IO.read filename
      ERB.new(contents).result
    end
  end
end
