require File.expand_path(File.dirname(__FILE__)) + '/../test_helper'

module HotOrNot
  class TestUnitAnnouncerTest < AnnouncerTestCase
    context "run" do
      setup do
        intercept_io
        output_dir = 'test_results'
        @announcer = TestUnitAnnouncer.new output_dir
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
          assert_equal '  1) Not Hot:', test_output[2].chomp
        end

        should "print 'E' for a test that errors out" do
          urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'bar', 404)]
          Runner.new(urls, @announcer).run!

          assert_equal 'E', test_output[1].chomp
        end
      end

    end
  end
end
