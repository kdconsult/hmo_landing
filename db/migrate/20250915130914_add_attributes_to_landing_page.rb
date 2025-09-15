class AddAttributesToLandingPage < ActiveRecord::Migration[8.0]
  def change
    add_column :landing_pages, :headline, :string
    add_column :landing_pages, :subheadline, :string
    add_column :landing_pages, :body, :text
    add_column :landing_pages, :primary_cta_label, :string
    add_column :landing_pages, :primary_cta_url, :string
  end
end
