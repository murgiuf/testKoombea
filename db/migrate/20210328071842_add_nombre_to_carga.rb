class AddNombreToCarga < ActiveRecord::Migration[5.2]
  def change
    add_column :cargas, :nombre_archivo, :string
  end
end
