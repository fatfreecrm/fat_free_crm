class KiosksController < ApplicationController
  before_action :set_kiosk, only: [:show, :edit, :update, :destroy]
  before_filter :set_current_tab

  # GET /kiosks
  def index
    @kiosks = Kiosk.all
  end

  # GET /kiosks/1
  def show
  end

  # GET /kiosks/new
  def new
    @kiosk = Kiosk.new
    @accounts_list = Account.all.map { |acc| [acc.name, acc.id] }
  end

  # GET /kiosks/1/edit
  def edit
  end

  # POST /kiosks
  def create
    @kiosk = Kiosk.new(kiosk_params)

    if @kiosk.save
      redirect_to @kiosk, notice: 'Kiosk was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /kiosks/1
  def update
    if @kiosk.update(kiosk_params)
      redirect_to @kiosk, notice: 'Kiosk was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /kiosks/1
  def destroy
    @kiosk.destroy
    redirect_to kiosks_url, notice: 'Kiosk was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kiosk
      @kiosk = Kiosk.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def kiosk_params
      params.require(:kiosk).permit(:name, :purchase_date, :contract_type, :contract_length, :password, :cd_password, :notes, :account_id)
    end
end
