class DashboardController < ApplicationController
  before_action :authenticate_user! # Devise method to authenticate user
  def index
    @cryptos = Crypto.group_and_sum(current_user)
  end
end
