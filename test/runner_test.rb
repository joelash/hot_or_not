require File.dirname(__FILE__) + '/test_helper'

module HotOrNot
  class RunnerTest < Test::Unit::TestCase
    def initialize(*args)
      @announcer = Class.new do
        include Announcer

        attr_reader :messages
        def initialize
          @messages = {}
        end

        def starting
          @messages[:starting] = true
        end

        def ending
          @messages[:ending] = true
        end

        def announce_success(result)
          @messages[:success] = true
        end

        def announce_failure(result)
          @messages[:failure] = true
        end

        def announce_error(result)
          @messages[:error] = true
        end
      end.new

      super
    end

    context "successful comparison" do
      setup do
        urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'foo')]
        Runner.new(urls, @announcer).run!
      end

      should "announce starting" do
        assert @announcer.messages[:starting]
      end

      should "announce ending" do
        assert @announcer.messages[:ending]
      end

      should "only annouce success" do
        assert @announcer.messages[:success]
        assert_false @announcer.messages[:failure]
        assert_false @announcer.messages[:error]
      end
    end

    context "failing comparison" do
      setup do
        urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'bar')]
        Runner.new(urls, @announcer).run!
      end

      should "announce starting" do
        assert @announcer.messages[:starting]
      end

      should "announce ending" do
        assert @announcer.messages[:ending]
      end

      should "only annouce failure" do
        assert @announcer.messages[:failure]
        assert_false @announcer.messages[:success]
        assert_false @announcer.messages[:error]
      end
    end

    context "error during retreival" do
      setup do
        urls = [mock_compare_url('Foo', '/api/foo', 'foo', 'bar', 404)]
        Runner.new(urls, @announcer).run!
      end

      should "announce starting" do
        assert @announcer.messages[:starting]
      end

      should "announce ending" do
        assert @announcer.messages[:ending]
      end

      should "only annouce error" do
        assert @announcer.messages[:error]
        assert_false @announcer.messages[:success]
        assert_false @announcer.messages[:failure]
      end
    end

  end
end
