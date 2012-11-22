class AddColumnIpAddressToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :ip_address, :string
  end
end
