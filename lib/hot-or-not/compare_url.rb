module HotOrNot
  class CompareUrl

    attr_reader :url, :base_a, :base_b

    def initialize(name, url, base_a, base_b)
      @name, @url, @base_a, @base_b = name, url, base_a, base_b
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
      contents = YAML.load run_erb filename
      side_a, side_b = contents['side_a'], contents['side_b']
      contents['comparisons'].map do |h|
        CompareUrl.new h['name'], h['url'], side_a, side_b
      end
    end

    private
    def self.run_erb(filename)
      contents = IO.read filename
      ERB.new(contents).result
    end
  end
end
