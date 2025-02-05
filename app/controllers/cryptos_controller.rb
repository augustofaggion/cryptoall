class CryptosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_crypto, only: [ :edit, :update, :destroy ]

  def index
    @cryptos = current_user.cryptos
  end

  def create
    # Get data from params
    crypto = current_user.cryptos.build(crypto_params)

    if crypto.save
      redirect_to cryptos_path, notice: "Crypto added successfully"
    else
      redirect_to cryptos_path, alert: "Failed to add crypto: #{crypto.errors.full_messages.join(', ')}"
    end
  end

  def edit
  end

  def update
    if @crypto.update(crypto_params)
      redirect_to cryptos_path, notice: "Crypto updated successfully"
    else
      render :edit, alert: "Failed to update crypto: #{crypto.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    if @crypto.destroy
      redirect_to cryptos_path, notice: "Crypto deleted successfully"
    else
      redirect_to cryptos_path, alert: "Failed to delete crypto"
    end
  end

  private

  def set_crypto
    @crypto = current_user.cryptos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to cryptos_path, alert: "Crypto not found"
  end

  def crypto_params
    params.require(:crypto).permit(:crypto_name, :crypto_code, :crypto_amount, :euro_invested)
  end
end
