class CargasController < ApplicationController
  before_action :set_carga, only: %i[ show edit update destroy ]

  include CargasHelper

  def import_carga

    omitir_cabeceras = params[:cabecera].nil? ? false : true
    carga = Carga.create!(user: current_user, nombre_archivo: params[:file].original_filename,
                                               estado: Constantes::Cargas::ESPERA)
    @list_valid = h_import_contactos(params[:file], omitir_cabeceras, carga)

    obj = S3_BUCKET.object("#{carga.id}_#{carga.nombre_archivo}")
    obj.put(body: params[:file].to_io)

    carga.archivo = obj.public_url
    carga.save
    redirect_to cargas_path
  end

def descarga_archivo
  carga = Carga.find(params[:id].to_i)

  file_name = "#{carga.id}_#{carga.nombre_archivo}"
  file_path = Rails.root.join("tmp")+ file_name

   S3_BUCKET.object("#{carga.id}_#{carga.nombre_archivo}").download_file(file_path)

   File.open(file_path) do |f|
     send_data(f.read, type: "text/csv", disposition: 'attachment', filename: file_name)
   end
   File.delete(file_path)

end

  # GET /cargas or /cargas.json
  def index
    @cargas = Carga.find_by_sql("select * from cargas where user_id = #{current_user.id} order by id desc").paginate(page: params[:page], per_page: 10)
  end

  # GET /cargas/1 or /cargas/1.json
  def show
  end

  # GET /cargas/new
  def new
    @carga = Carga.new
    h_mira_si_tiene_mapeo(current_user.id)
    @mapeos = Ordenmapeo.find_by_sql("Select * from ordenmapeos where user_id = #{current_user.id} order by orden asc")
  end

  # GET /cargas/1/edit
  def edit
  end

  # POST /cargas or /cargas.json
  def create
    @carga = Carga.new(carga_params)

    respond_to do |format|
      if @carga.save
        format.html { redirect_to @carga, notice: "Carga was successfully created." }
        format.json { render :show, status: :created, location: @carga }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @carga.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cargas/1 or /cargas/1.json
  def update
    respond_to do |format|
      if @carga.update(carga_params)
        format.html { redirect_to @carga, notice: "Carga was successfully updated." }
        format.json { render :show, status: :ok, location: @carga }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @carga.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cargas/1 or /cargas/1.json
  def destroy
    @carga.destroy
    respond_to do |format|
      format.html { redirect_to cargas_url, notice: "Carga was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  def modificaMapeo
    mapeo_id = params[:mapeo_id].to_i
    mov = params[:mov].to_i

    mapeo = Ordenmapeo.find(mapeo_id)


    if mov <0 && mapeo.orden != 0
      mapeo_anterior = Ordenmapeo.find_by(orden: mapeo.orden - 1)
      mapeo_anterior.orden = mapeo_anterior.orden + 1
      mapeo.orden = mapeo.orden - 1
      mapeo_anterior.save
    end

    if mov > 0 && mapeo.orden != 5
      mapeo_anterior = Ordenmapeo.find_by(orden: (mapeo.orden + 1))
      mapeo_anterior.orden = mapeo_anterior.orden - 1
      mapeo.orden = mapeo.orden + 1
      mapeo_anterior.save

    end

    mapeo.save

    render json: "ok"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_carga
      @carga = Carga.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def carga_params
      params.require(:carga).permit(:user_id, :archivo, :estado)
    end
end
