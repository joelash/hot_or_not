require 'helper'

module HotOrNot
  class TestRunner < Test::Unit::TestCase
    context "run" do
      setup do
        intercept_io
        @output_dir = 'test_results'
      end

      teardown do
        reset_io
      end

      context "the console output" do
        should "print '.' for passing test" do
          urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'foo')]
          Runner.new(urls, @output_dir).run!

          assert_equal '.', test_output[1].chomp
        end

        should "print 'F' for a failing test" do
          urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'bar')]
          Runner.new(urls, @output_dir).run!

          assert_equal 'F', test_output[1].chomp
        end

        should "print 'E' for a test that errors out" do
          urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'bar', 404)]
          Runner.new(urls, @output_dir).run!

          o = test_output
          assert_equal 'E', o[1].chomp
        end
      end


    end
    private
    def mock_compare_url(name, url, body_a, body_b, code='200')
      CompareUrl.new(name, url, 'http://side_a', 'http://side_b').tap do |compare_url|
        RestClient.expects(:get).with(compare_url.side_a).returns FakeResponse.new(body_a, code)
        RestClient.expects(:get).with(compare_url.side_b).returns FakeResponse.new(body_b, code) if code.to_s == '200'
      end
    end
    
    def intercept_io
      @output_filename = 'test_runner_tests.txt'
      @output_file = File.open(@output_filename, 'w+')
      @orig_stdout = STDOUT.dup
      STDOUT.reopen(@output_file)
    end

    def reset_io
      @output_file.close
      FileUtils.rm_f @output_filename
      STDOUT.reopen @orig_stdout
    end
    
    def test_output
      STDOUT.flush
      File.readlines(@output_file)
    end
  end
end
