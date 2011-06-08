require File.dirname(__FILE__) + '/helper'

module HotOrNot
  class TestCompareUrl < Test::Unit::TestCase
    context "load from file" do
      setup do
        @urls = CompareUrl.load_from File.dirname(__FILE__) + '/data/simple_urls.yml'
      end

      should "load right number of comparisons" do
        assert_equal 2, @urls.count
      end

      should "load all urls" do
        assert_equal 'People Test', @urls[0].full_name
        assert_equal 'Names Test', @urls[1].full_name
      end

      should "load options from file" do
        expected_options = { :headers => { 'authorization' => 'foo123bar' } }
        assert_equal expected_options, @urls[1].options
      end
    end

    context "load from file with erb" do
      setup do
        @urls = CompareUrl.load_from File.dirname(__FILE__) + '/data/simple_urls.yml.erb'
      end

      should "load all comparisons" do
        assert_equal 2, @urls.count
      end

      should "run erb on the file" do
        assert_equal "People Test #{Date.today}", @urls[0].full_name
      end
    end

    context "object" do
      setup do
        @compare_url = CompareUrl.new 'Foo Url', '/api/foo', 'http://side_a', 'http://side_b'
      end

      should "contain a test name" do
        assert_equal "Foo Url", @compare_url.full_name
        assert_equal "foo_url", @compare_url.short_name
      end

      should "create urls for the side_b release" do
        assert_equal 'http://side_a/api/foo', @compare_url.side_a
        assert_equal 'http://side_b/api/foo', @compare_url.side_b
      end

      should "default options to empty hash" do
        expected_options = {}
        assert_equal expected_options, @compare_url.options
      end
    end

    context "object with options" do
      setup do
        @compare_url = CompareUrl.new 'Foo Url', '/api/foo', 'http://side_a', 'http://side_b', :headers => { 'authorization' => 'baz321' }
      end

      should "read provid options as passed in" do
        expected_options = { :headers => { 'authorization' => 'baz321' } }
        assert_equal expected_options, @compare_url.options
      end
    end
  end
end
