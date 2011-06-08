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
require 'hot-or-not'

module HotOrNot
  class FakeResponse
    attr_reader :body, :code, :headers
    def initialize(body, code = '200', headers = {})
      @body, @code = body, code
      @headers = { :content_type => 'html' }.merge headers
    end
  end
end

class Test::Unit::TestCase
  def assert_false(truth, message=nil)
    assert !truth, message
  end
  alias_method :assert_not, :assert_false

  def assert_present(text)
    assert_not_nil text
    assert_not text.empty?, "#{text} was expected to not be empty"
  end

  private
  def mock_compare_url(name, url, body_a, body_b, code='200')
    HotOrNot::CompareUrl.new(name, url, 'http://side_a', 'http://side_b').tap do |compare_url|
      RestClient::Request.expects(:execute).with(:method => :get, :url => compare_url.side_a).returns HotOrNot::FakeResponse.new(body_a, code)
      RestClient::Request.expects(:execute).with(:method => :get, :url => compare_url.side_b).returns HotOrNot::FakeResponse.new(body_b, code) if code.to_s == '200'
    end
  end
end
