class CreateLandingPages < ActiveRecord::Migration[8.0]
  def change
    create_table :landing_pages, if_not_exists: true do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :name
      t.string :slug
      t.string :template
      t.string :status, default: "draft", null: false
      t.json :schema
      t.integer :schema_version
      t.datetime :published_at

      t.timestamps
    end
    add_index :landing_pages, :slug, unique: true, if_not_exists: true
    add_index :landing_pages, :campaign_id, unique: true, if_not_exists: true
  end
end
