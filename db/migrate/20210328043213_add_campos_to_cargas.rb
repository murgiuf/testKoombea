class AddCamposToCargas < ActiveRecord::Migration[5.2]
  def change
    add_column :cargas, :total, :integer
    add_column :cargas, :cargado, :integer
    add_column :cargas, :rechazado, :integer
  end
end
