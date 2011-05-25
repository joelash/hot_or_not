require 'helper'

module HotOrNot
  class TestConsoleAnnouncer < Test::Unit::TestCase
    context "run" do
      setup do
        intercept_io
        output_dir = 'test_results'
        @announcer = ConsoleAnnouncer.new output_dir
      end

      teardown do
        reset_io
      end

      context "the console output" do
        should "print '.' for passing test" do
          urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'foo')]
          Runner.new(urls, @announcer).run!

          assert_equal '.', test_output[1].chomp
        end

        should "print 'N' for a failing test" do
          urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'bar')]
          Runner.new(urls, @announcer).run!

          assert_equal 'N', test_output[1].chomp
        end

        should "print 'E' for a test that errors out" do
          urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'bar', 404)]
          Runner.new(urls, @announcer).run!

          o = test_output
          assert_equal 'E', o[1].chomp
        end
      end

    end
    
    private
    def intercept_io
      @output_filename = 'test_runner_tests.txt'
      @output_file = File.open(@output_filename, 'w+')
      @orig_stdout = STDOUT.dup
      STDOUT.reopen(@output_file)
    end

    def reset_io
      @output_file.close
      FileUtils.rm_f @output_filename if leave_last_ouput?
      STDOUT.reopen @orig_stdout
    end

    def leave_last_ouput?
      ENV['HORN_io'].to_s.downcase != 'false'
    end
    
    def test_output
      STDOUT.flush
      File.readlines(@output_file)
    end
  end
end
