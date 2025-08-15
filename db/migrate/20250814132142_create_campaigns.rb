class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.date :start_date
      t.date :end_date
      t.boolean :active

      t.timestamps
    end
  end
end
