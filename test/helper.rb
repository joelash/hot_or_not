require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'api-compare'

class Test::Unit::TestCase
  def assert_false(truth, message=nil)
    assert !truth, message
  end
  alias_method :assert_not, :assert_false

  def assert_present(text)
    assert_not_nil text
    assert_not text.empty?, "#{text} was expected to not be empty"
  end
end

module ApiCompare
  class FakeResponse
    attr_reader :body, :code
    def initialize(body, code = '200')
      @body, @code = body, code
    end
  end
end
