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
require 'hot_or_not'

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
  def assert_false(truth, message='')
    assert !truth, message
  end
  alias_method :assert_not, :assert_false

  def assert_present(text)
    assert_not_nil text
    assert_not text.empty?, "#{text} was expected to not be empty"
  end

  private
  def mock_compare_url(name, url, body_a, body_b, code_a=200, code_b=200)
    HotOrNot::CompareUrl.new(name, url, 'http://side_a', 'http://side_b').tap do |compare_url|
      response_a, error_a = response_and_error_for body_a, code_a
      response_b, error_b = response_and_error_for body_b, code_b
      side_a_result = HotOrNot::UrlResult.new compare_url.side_a, response_a, error_a
      side_b_result = HotOrNot::UrlResult.new compare_url.side_b, response_b, error_b
      HotOrNot::ComparisonResult.expects(:for).with(compare_url).returns HotOrNot::ComparisonResult.new(compare_url, side_a_result, side_b_result)
    end
  end

  def response_and_error_for(body, code)
    response, error = nil, nil
    code = code.to_i
    if code == 200
      response = HotOrNot::FakeResponse.new body
    else
      error = RestClient::Exceptions::EXCEPTIONS_MAP[code].new
    end
    [response, error]
  end
end

module HotOrNot
  class AnnouncerTestCase < Test::Unit::TestCase
    private
    def intercept_io
      @output_filename = 'test_runner_tests.txt'
      @output_file = File.open(@output_filename, 'w+')
      @orig_stdout = STDOUT.dup
      STDOUT.reopen(@output_file)
    end

    def reset_io
      @output_file.close
      @test_output = nil
      FileUtils.rm_f @output_filename if leave_last_ouput?
      STDOUT.reopen @orig_stdout
    end

    def leave_last_ouput?
      ENV['HORN_io'].to_s.downcase != 'false'
    end
    
    def test_output
      @test_output ||= (
        STDOUT.flush
        File.readlines(@output_file) )
    end
  end
end
