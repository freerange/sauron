class AddDeliveredToToMailIndex < ActiveRecord::Migration
  def change
    add_column :mail_index, :delivered_to, :string
  end
end
