class ChangeDataTypeForMaxLengthAndMaxValue < ActiveRecord::Migration
  def up
    change_table :questions do |t|
      t.change :max_value, :integer, :limit => 8
      t.change :max_length, :integer, :limit => 8
    end
  end

  def down
    change_table :questions do |t|
      t.change :max_value, :integer
      t.change :max_length, :integer
    end
  end
end
