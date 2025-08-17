require "application_system_test_case"

class LandingPagesTest < ApplicationSystemTestCase
  setup do
    @landing_page = landing_pages(:one)
  end

  test "visiting the index" do
    visit landing_pages_url
    assert_selector "h1", text: "Landing Pages"
  end

  test "should create landing page" do
    visit landing_pages_url
    click_on "New landing page"

    select @landing_page.campaign.title, from: "Campaign"
    fill_in "Slug", with: @landing_page.slug
    fill_in "Headline", with: @landing_page.headline
    fill_in "Subheadline", with: @landing_page.subheadline
    fill_in "Body", with: @landing_page.body
    fill_in "Primary cta label", with: @landing_page.primary_cta_label
    fill_in "Primary cta url", with: @landing_page.primary_cta_url
    select @landing_page.status, from: "Status"
    fill_in "Schema", with: @landing_page.schema.to_json
    fill_in "Schema version", with: @landing_page.schema_version
    fill_in "Published at", with: @landing_page.published_at
    click_on "Create Landing page"

    assert_text "Landing page was successfully created"
    click_on "Back"
  end

  test "should update Landing page" do
    visit landing_page_url(@landing_page)
    click_on "Edit", match: :first

    select @landing_page.campaign.title, from: "Campaign"
    fill_in "Slug", with: @landing_page.slug
    fill_in "Headline", with: @landing_page.headline
    fill_in "Subheadline", with: @landing_page.subheadline
    fill_in "Body", with: @landing_page.body
    fill_in "Primary cta label", with: @landing_page.primary_cta_label
    fill_in "Primary cta url", with: @landing_page.primary_cta_url
    select @landing_page.status, from: "Status"
    fill_in "Schema", with: @landing_page.schema.to_json
    fill_in "Schema version", with: @landing_page.schema_version
    fill_in "Published at", with: @landing_page.published_at.to_s
    click_on "Update Landing page"

    assert_text "Landing page was successfully updated"
    click_on "Back"
  end

  test "should destroy Landing page" do
    visit landing_page_url(@landing_page)
    accept_confirm { click_on "Delete", match: :first }

    assert_text "Landing page was successfully destroyed"
  end
end
