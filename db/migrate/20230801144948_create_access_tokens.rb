class CreateAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :access_tokens do |t|
      t.uuid :token, null: false
      t.uuid :refresh_token, null: false
      t.integer :created_at, null: false

      t.uuid :user_id
    end

    add_index :access_tokens, :token, unique: true
  end
end
