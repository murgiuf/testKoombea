json.extract! carga, :id, :user_id, :archivo, :estado, :created_at, :updated_at
json.url carga_url(carga, format: :json)
