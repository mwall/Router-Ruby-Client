require "test/unit"
require "webmock/test_unit"
require_relative '../lib/router'

class RouterTest < Test::Unit::TestCase

  def setup
    @router_client = RouterClient.new("http://router.gov.uk")
  end

  def test_can_create_update_and_delete_applications
    # Create application
    stub_request(:post, "http://router.gov.uk/applications/test-application").
        with(:body => {"backend_url"=>"http://jobs.alphagov.co.uk"}).
        to_return(:status => 201, :body => '{"application_id":"test-application","backend_url":"http://jobs.alphagov.co.uk"}')

    application = @router_client.create_application("test-application", "http://jobs.alphagov.co.uk")
    assert_equal("test-application", application.application_id)
    assert_equal("http://jobs.alphagov.co.uk", application.backend_url)

    # Attempt to re-create application
    stub_request(:post, "http://router.gov.uk/applications/test-application").
        with(:body => {"backend_url"=>"http://jobs.alphagov.co.uk"}).
        to_return(:status => 409, :body => '{"application_id":"test-application","backend_url":"http://jobs.alphagov.co.uk"}')

    assert_raise Conflict do
      @router_client.create_application("test-application", "http://jobs.alphagov.co.uk")
    end

    # Get created application
    stub_request(:get, "http://router.gov.uk/applications/test-application").
        to_return(:status => 200, :body => '{"application_id":"test-application","backend_url":"http://jobs.alphagov.co.uk"}')

    application = @router_client.get_application("test-application")
    assert_equal("test-application", application.application_id)
    assert_equal("http://jobs.alphagov.co.uk", application.backend_url)

    #application = @router_client.update_application("test-application", "http://sausages.alphagov.co.uk")
    #assert_equal("http://sausages.alphagov.co.uk", application.backend_url)
  end

  def test_cannot_update_application_name
    # todo
  end

end