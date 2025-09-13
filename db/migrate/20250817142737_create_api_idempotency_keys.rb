class CreateApiIdempotencyKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_idempotency_keys do |t|
      t.string :key
      t.string :endpoint
      t.string :request_hash
      t.json :response_body
      t.integer :response_status
      t.datetime :expires_at

      t.timestamps
    end
    add_index :api_idempotency_keys, :key, unique: true
    add_index :api_idempotency_keys, [ :endpoint, :request_hash ]
    add_index :api_idempotency_keys, :expires_at
  end
end
