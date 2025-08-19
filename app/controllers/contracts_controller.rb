class ContractsController < ApplicationController
  before_action :set_contract, only: [:show, :edit, :update, :destroy]

  # GET /contracts
  def index
    @contracts = Contract.all
  end

  # GET /contracts/1
  def show
  end

  # GET /contracts/new
  def new
    @contract = Contract.new
  end

  # GET /contracts/1/edit
  def edit
  end

  # POST /contracts
  def create
    @contract = Contract.new(contract_params)

    if @contract.save
      redirect_to @contract, notice: 'Contract was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /contracts/1
  def update
    if @contract.update(contract_params)
      redirect_to @contract, notice: 'Contract was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /contracts/1
  def destroy
    @contract.destroy
    redirect_to contracts_url, notice: 'Contract was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract
      @contract = Contract.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def contract_params
      params.require(:contract).permit(:start_date, :end_date, :status, :contract_original_text, :account_id)
    end
end
