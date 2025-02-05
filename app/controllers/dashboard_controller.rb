class DashboardController < ApplicationController
  before_action :authenticate_user! # Devise method to authenticate user
  def index
    @cryptos = Crypto.group_and_sum(current_user)

    # Fetch live data from API
    @cryptos.each do |crypto|
      crypto.live_price = CryptoCompareService.get_price(crypto.crypto_code, "EUR")
    end
  end
end
