class ContactosController < ApplicationController
  before_action :set_contacto, only: %i[ show edit update destroy ]

  # GET /contactos or /contactos.json
  def index

    from_page = params[:from_page]
    estado = params[:estado]
    carga = params[:carga_id]

    q_carga = ""
    q_estado = " and cc.estado = 1"

    if !from_page.blank? && from_page == 'carga' && !carga.blank?
      @carga = Carga.find(carga)
      q_estado = " and ca.id = #{carga}"
    end

    if !from_page.blank? && from_page == 'carga' && !estado.blank?
      @estado = estado == "1" ? "Cargados" :  "Rechazados"
      q_estado = " and cc.estado = #{estado}"
    end

    @contactos = Contacto.find_by_sql("select cc.* from contactos cc,
                        cargas ca
                        where 1=1
                        and cc.carga_id = ca.id
                        and ca.user_id = #{current_user.id}
                        #{q_carga}
                        #{q_estado}
                        ").paginate(page: params[:page], per_page: 10)
  end

  # GET /contactos/1 or /contactos/1.json
  def show
  end

  # GET /contactos/new
  def new
    @contacto = Contacto.new
  end

  # GET /contactos/1/edit
  def edit
  end

  # POST /contactos or /contactos.json
  def create
    @contacto = Contacto.new(contacto_params)

    respond_to do |format|
      if @contacto.save
        format.html { redirect_to @contacto, notice: "Contacto was successfully created." }
        format.json { render :show, status: :created, location: @contacto }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @contacto.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contactos/1 or /contactos/1.json
  def update
    respond_to do |format|
      if @contacto.update(contacto_params)
        format.html { redirect_to @contacto, notice: "Contacto was successfully updated." }
        format.json { render :show, status: :ok, location: @contacto }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @contacto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contactos/1 or /contactos/1.json
  def destroy
    @contacto.destroy
    respond_to do |format|
      format.html { redirect_to contactos_url, notice: "Contacto was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contacto
      @contacto = Contacto.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def contacto_params
      params.require(:contacto).permit(:carga_id, :nombre, :nacimiento, :telefono, :direccion, :tarjeta, :franquicia, :email)
    end
end
