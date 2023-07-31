class ChangeCredentialsToAccount < ActiveRecord::Migration[7.0]
  def change
    rename_table :authentication_credentials, :authentication_accounts
  end
end
