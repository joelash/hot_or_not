module ApiCompare
  class CompareUrl

    attr_reader :url

    def initialize(name, url, base_a, base_b)
      @name, @url, @base_a, @base_b = name, url, base_a, base_b
    end

    def full_name
      @name
    end

    def short_name
      @short_name ||= underscore @name
    end

    def side_a
      @side_a ||= @base_a + @url
    end

    def side_b
      @side_b ||= @base_b + @url
    end

    def self.load_from(filename)
      contents = File.open(filename)  { |yf| YAML.load yf }
      side_a, side_b = contents['side_a'], contents['side_b']
      contents['comparisons'].map do |h|
        CompareUrl.new h['name'], h['url'], side_a, side_b
      end
    end

    private
    def underscore str
      str.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        gsub(/\s+/, '_').
        tr("-", "_").
        downcase
    end
  end
end
