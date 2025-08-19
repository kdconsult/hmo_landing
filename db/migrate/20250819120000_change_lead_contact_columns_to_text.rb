class ChangeLeadContactColumnsToText < ActiveRecord::Migration[8.0]
  def up
    change_column :leads, :email_ciphertext, :text
    change_column :leads, :phone_ciphertext, :text
  end

  def down
    change_column :leads, :email_ciphertext, :string
    change_column :leads, :phone_ciphertext, :string
  end
end
