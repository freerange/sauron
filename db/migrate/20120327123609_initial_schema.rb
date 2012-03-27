class InitialSchema < ActiveRecord::Migration
  def change
    create_table :messages do |table|
      table.string :uid
      table.string :subject
      table.datetime :date
      table.string :from
    end
  end
end
