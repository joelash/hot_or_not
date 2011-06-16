require File.dirname(__FILE__) + '/test_helper'

module HotOrNot
  class UrlResultTest < Test::Unit::TestCase
    context "error" do
      setup do
        @url = 'http://url/request/test'
        exception = RestClient::InternalServerError.new
        RestClient::Request.expects(:execute).with(:method => :get, :url => @url).raises exception
      end

      should "not raise error on 500" do
        assert_nothing_raised { UrlResult.retrieve_for @url, {} }
      end

      should "report as error" do
        result = UrlResult.retrieve_for @url, {}
        assert result.error?
        assert_false result.success?
      end

      should "report the error message" do
        result = UrlResult.retrieve_for @url, {}
        assert_match /error: Internal Server Error/, result.error_message
      end
    end

    context "successfull response" do
      setup do
        @url = 'http://url/request/test'
        RestClient::Request.expects(:execute).with(:method => :get, :url => @url).returns FakeResponse.new 'hello', 200
        @result = UrlResult.retrieve_for @url, {}
      end

      should "report success" do
        assert @result.success?
      end

      should "return the body" do
        assert_equal 'hello', @result.body
      end

      should "return the http response code" do
        assert_equal 200, @result.code
      end

    end
  end
end
