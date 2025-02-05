class CryptoCompareService
  include HTTParty
  base_uri "https://min-api.cryptocompare.com/data"

  headers "Authorization" => "Apikey #{ENV['CRYPTOCOMPARE_API_KEY']}"

  def self.get_price(crypto_code, currency)
    unless ENV["CRYPTOCOMPARE_API_KEY"]
      raise "CryptoCompare API key is missing. Please set the CRYPTOCOMPARE_API_KEY environment variable."
    end

    response = get("/price?fsym=#{crypto_code.upcase}&tsyms=#{currency.upcase}")
    if response.success?
      response.parsed_response[currency.upcase]
    else
      nil
    end
  end
end
