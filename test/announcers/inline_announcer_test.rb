require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'

module HotOrNot
  class InlineAnnouncerTest < AnnouncerTestCase
    context "run" do
      setup do
        intercept_io
        output_dir = 'test_results'
        @announcer = InlineAnnouncer.new output_dir
      end

      teardown do
        reset_io
      end

      context "the inline console output" do
        should "print Hot and testname for passing test" do
          urls = [mock_compare_url('Passing Test', '/api/foo', 'foo', 'foo')]
          Runner.new(urls, @announcer).run!

          expected_output = /^Hot:\s+Passing Test\s+1.0000s, 1.0000s$/
          assert_match expected_output, test_output[1].chomp
        end

        should "print Not Hot and testname for failing test" do
          urls = [mock_compare_url('Failing Test', '/api/foo', 'foo', 'bar')]
          Runner.new(urls, @announcer).run!

          expected_output = /^Not Hot:\s+Failing Test\s+1.0000s, 1.0000s$/
          assert_match expected_output, test_output[1].chomp
        end

        should "print Error and testname for test that causes error" do
          urls = [mock_compare_url('Error test', '/api/foo', 'foo', 'bar', 404)]
          Runner.new(urls, @announcer).run!

          assert_match /^Error:\s+Error test\s+1.0000s, 1.0000s$/, test_output[1].chomp
        end
      end
    end
  end
end
