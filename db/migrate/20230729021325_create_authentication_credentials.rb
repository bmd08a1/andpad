class CreateAuthenticationCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :authentication_credentials do |t|
      t.uuid :user_id
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
  end
end
