require 'helper'

module ApiCompare
  class TestComparisonResult < Test::Unit::TestCase
    context "comparing results" do
      setup do
        @compare_url = CompareUrl.new 'Test People', '/api/people', 'http://side_a', 'http://side_b'
      end

      context "500 error" do
        setup do
          RestClient.expects(:get).with(@compare_url.side_a).returns FakeResponse.new('foo', 500)
        end

        should "raise error when response code is not 200" do
          assert_raises(Exception) {  ComparisonResult.for @compare_url }
        end
      end

      context "when results match" do
        setup do
          RestClient.expects(:get).with(@compare_url.side_a).returns FakeResponse.new 'foo'
          RestClient.expects(:get).with(@compare_url.side_b).returns FakeResponse.new 'foo'
          @result = ComparisonResult.for @compare_url
        end

        should "return success" do
          assert @result.success?
        end
      end

      context "when results don't match" do
        setup do
          RestClient.expects(:get).with(@compare_url.side_a).returns FakeResponse.new 'side_a'
          RestClient.expects(:get).with(@compare_url.side_b).returns FakeResponse.new 'side_b'
          @result = ComparisonResult.for @compare_url
        end

        should "not return success" do
          assert_not @result.success?
        end

        should "have test unit style failure message" do
          assert_match @result.message, /Test People:.*?\/api\/people/
        end

        should "provide a diff" do
          assert_present @result.diff
        end
      end
    end
  end
end
