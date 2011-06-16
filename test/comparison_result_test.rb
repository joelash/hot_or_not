require File.dirname(__FILE__) + '/test_helper'

module HotOrNot
  class ComparisonResultTest < Test::Unit::TestCase
    context "" do
      setup do
        @compare_url = CompareUrl.new 'Test People', '/api/people', 'http://side_a', 'http://side_b'
      end

      context "building from compare url" do
        setup do
          @compare_url = CompareUrl.new 'Test People', '/api/people', 'http://side_a', 'http://side_b'
          RestClient::Request.expects(:execute).with(:method => :get, :url => @compare_url.side_a).returns FakeResponse.new 'foo'
          RestClient::Request.expects(:execute).with(:method => :get, :url => @compare_url.side_b).returns FakeResponse.new 'foo'
        end

        should "not throw an exception when building" do
          assert_nothing_raised { ComparisonResult.for @compare_url }
        end
      end

      context "comparing results" do

        context "when results match" do
          setup do
            response = FakeResponse.new 'foo'
            side_a_results = UrlResult.new @compare_url.side_a, response, nil
            side_b_results = UrlResult.new @compare_url.side_b, response, nil
            @result = ComparisonResult.new @compare_url, side_a_results, side_b_results
          end

          should "return success" do
            assert @result.success?
          end
        end

        context "when results don't match" do
          setup do
            response_a = FakeResponse.new 'side_a'
            response_b = FakeResponse.new 'side_b'
            side_a_results = UrlResult.new @compare_url.side_a, response_a, nil
            side_b_results = UrlResult.new @compare_url.side_b, response_b, nil
            @result = ComparisonResult.new @compare_url, side_a_results, side_b_results
          end

          should "not return success" do
            assert_not @result.success?
          end

          should "have test unit style failure message" do
            assert_match /Test People:.*?\/api\/people/, @result.message
          end

          should "provide a diff" do
            assert_present @result.diff
          end
        end

        context "when one result has an error" do
          setup do
            response_a = FakeResponse.new 'side_a'
            error_b = RestClient::InternalServerError.new
            side_a_results = UrlResult.new @compare_url.side_a, response_a, nil
            side_b_results = UrlResult.new @compare_url.side_b, nil, error_b
            @result = ComparisonResult.new @compare_url, side_a_results, side_b_results
          end

          should "not return success" do
            assert_not @result.success?
          end

          should "return error" do
            assert @result.error?
          end

          should "have a message containing the error" do
            assert_match /#{@compare_url.side_b}.*?: Internal Server Error/, @result.message
          end
        end
      end
    end
  end
end
