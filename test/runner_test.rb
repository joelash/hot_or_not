require File.expand_path(File.dirname(__FILE__)) + '/test_helper'

module HotOrNot
  class RunnerTest < Test::Unit::TestCase

    def initialize(*args)
      @announcer = Class.new do
        include Announcer

        attr_reader :messages
        def initialize
          @messages = Hash.new { |hash, key| hash[key] = [] }
        end

        def starting
          @messages[:starting] << :starting
        end

        def ending
          @messages[:ending] << :ending
        end

        def announce_success(result)
          @messages[:success] << result.short_name
        end

        def announce_failure(result)
          @messages[:failure] << result.short_name
        end

        def announce_error(result)
          @messages[:error] << result.short_name
        end
      end.new

      super
    end

    context "running" do

      context "all" do
        setup do
          @url1 = mock_compare_url('Foo', '/api/foo', 'foo', 'foo')
          @url2 = mock_compare_url('Bar', '/api/bar', 'bar', 'bar')
          @urls = [@url1, @url2]
        end

        should "if nothing passed in" do
          Runner.new(@urls, @announcer).run!
          assert_ran @announcer, @url1.full_name, @url2.full_name
        end

        should "if :all passed in" do
          Runner.new(@urls, @announcer).run! :all
          assert_ran @announcer, @url1.full_name, @url2.full_name
        end

        should "run all specified tests" do
          Runner.new(@urls, @announcer).run! @urls.map(&:short_name)
          assert_ran @announcer, @url1.full_name, @url2.full_name
        end
      end

      context "one" do
        setup do
          @url1 = mock_compare_url('Foo', '/api/foo', 'foo', 'foo')
          @url2 = CompareUrl.new('Bar', '/api/bar', 'bar', 'bar')
          @urls = [@url1, @url2]
        end

        should "only run specified test" do
          Runner.new(@urls, @announcer).run! @url1.full_name

          assert_ran @announcer, @url1.full_name
          assert_not_ran @announcer, @url2.full_name
        end
      end
    end

    context "successful comparison" do
      setup do
        urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'foo')]
        Runner.new(urls, @announcer).run!
      end

      should "announce starting" do
        assert_called @announcer, :starting
      end

      should "announce ending" do
        assert_called @announcer, :ending
      end

      should "only annouce success" do
        assert_called @announcer, :success
        assert_not_called @announcer, :failure
        assert_not_called @announcer, :error
      end
    end

    context "failing comparison" do
      setup do
        urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'bar')]
        Runner.new(urls, @announcer).run!
      end

      should "announce starting" do
        assert_called @announcer, :starting
      end

      should "announce ending" do
        assert_called @announcer, :ending
      end

      should "only annouce failure" do
        assert_called @announcer, :failure
        assert_not_called @announcer, :success
        assert_not_called @announcer, :error
      end
    end

    context "error during retreival" do
      setup do
        urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'bar', 404)]
        Runner.new(urls, @announcer).run!
      end

      should "announce starting" do
        assert_called @announcer, :starting
      end

      should "announce ending" do
        assert_called @announcer, :ending
      end

      should "only annouce error" do
        assert_called @announcer, :error
        assert_not_called @announcer, :success
        assert_not_called @announcer, :failure
      end
    end

    private
    def assert_called(announcer, type, times = 1, msg = nil)
      msg ||= "The #{type} message was not announced #{times} time(s)."
      assert_equal times, announcer.messages[type.to_sym].count, msg
    end
    
    def assert_not_called(announcer, type)
      assert_called announcer, type, 0, "The #{type} messages was called when it shouldn't have been"
    end

    def assert_ran(announcer, *tests)
      tests.each do |test|
        assert_equal 1, count_results(announcer, test), "Test '#{test}' was not run."
      end
    end

    def assert_not_ran(announcer, *tests)
      tests.each do |test|
        assert_equal 0, count_results(announcer, test), "Test '#{test}' was run and shouldn't have been."
      end
    end

    def count_results(announcer, test)
      test_name = test.underscore.gsub(/\s+/, '_')
      count = 0
      count += announcer.messages[:success].count { |result_name| result_name == test_name }
      count += announcer.messages[:failure].count { |result_name| result_name == test_name }
      count += announcer.messages[:error].count { |result_name| result_name == test_name }
      count
    end

  end
end
