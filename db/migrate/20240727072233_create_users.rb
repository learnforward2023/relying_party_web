# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :uuid
      t.string :email

      t.timestamps
    end
  end
end
