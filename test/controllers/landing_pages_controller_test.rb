require "test_helper"

class LandingPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @landing_page = landing_pages(:one)
  end

  test "should get index" do
    get landing_pages_url
    assert_response :success
  end

  test "should get new" do
    get new_landing_page_url
    assert_response :success
  end

  test "should create landing_page" do
    new_campaign = Campaign.create!(
      title: "LP Test Campaign",
      slug: "lp-test-#{SecureRandom.hex(3)}",
      body: "Test",
      start_date: Date.today,
      end_date: Date.today,
      active: false
    )

    assert_difference("LandingPage.count") do
      post landing_pages_url, params: { landing_page: {
        campaign_id: new_campaign.id,
        headline: "New Headline",
        subheadline: "Sub",
        body: "Body",
        primary_cta_label: "CTA",
        primary_cta_url: "https://example.com",
        published_at: Time.current,
        schema: {},
        schema_version: 1,
        slug: "lp-#{SecureRandom.hex(3)}",
        status: "draft",
        template: "default"
      } }
    end

    assert_redirected_to landing_page_url(LandingPage.last)
  end

  test "should show landing_page" do
    get landing_page_url(@landing_page)
    assert_response :success
  end

  test "should get edit" do
    get edit_landing_page_url(@landing_page)
    assert_response :success
  end

  test "should update landing_page" do
    patch landing_page_url(@landing_page), params: { landing_page: { campaign_id: @landing_page.campaign_id, headline: @landing_page.headline, subheadline: @landing_page.subheadline, body: @landing_page.body, primary_cta_label: @landing_page.primary_cta_label, primary_cta_url: @landing_page.primary_cta_url, published_at: @landing_page.published_at, schema: @landing_page.schema, schema_version: @landing_page.schema_version, slug: @landing_page.slug, status: @landing_page.status, template: @landing_page.template } }
    assert_redirected_to landing_page_url(@landing_page)
  end

  test "should destroy landing_page" do
    assert_difference("LandingPage.count", -1) do
      delete landing_page_url(@landing_page)
    end

    assert_redirected_to landing_pages_url
  end
end
