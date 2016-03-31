class WebkiosksController < ApplicationController
  before_action :set_webkiosk, only: [:show, :edit, :update, :destroy]
  before_action :set_current_tab

  # GET /webkiosks
  def index
    @webkiosks = Webkiosk.all
  end

  # GET /webkiosks/1
  def show
  end

  # GET /webkiosks/new
  def new
    @webkiosk = Webkiosk.new
  end

  # GET /webkiosks/1/edit
  def edit
  end

  # POST /webkiosks
  def create
    @webkiosk = Webkiosk.new(webkiosk_params)

    if @webkiosk.save
      redirect_to @webkiosk, notice: 'Webkiosk was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /webkiosks/1
  def update
    if @webkiosk.update(webkiosk_params)
      redirect_to @webkiosk, notice: 'Webkiosk was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /webkiosks/1
  def destroy
    @webkiosk.destroy
    redirect_to webkiosks_url, notice: 'Webkiosk was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_webkiosk
      @webkiosk = Webkiosk.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def webkiosk_params
      params.require(:webkiosk).permit(:url, :account_id, :live, :platform, :notes)
    end
end
