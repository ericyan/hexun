require 'open-uri'
require 'nokogiri'
require 'json'

module Hexun
  class Stock
    attr_reader :name

    def initialize(symbol)
      @symbol = "%06d" % symbol.to_i

      @exchange = case @symbol[0]
                  when "0", "3" then :szse
                  when "6" then :sse
                  end

      get_basic_info

      get_last_quote
    end

    def price
      @price == 0 ? @previous_close : @price
    end

    def market_cap
      return price * @shares_outstanding
    end

    private
      def get_basic_info
        page = Nokogiri::HTML(open("http://stockdata.stock.hexun.com/#{@symbol}.shtml"))

        @name = page.css("#quoteName").text
        info = page.css("table.box6 td").collect { |td| td.text.strip }
        [29, 28, 25, 22, 5, 4].each { |index| info.delete_at(index) }
        data = Hash[info.each_slice(2).collect.to_a]

        @shares_outstanding = data["总股本(亿)"].to_f * 100000000
        @free_float = data["流通A股(亿)"].to_f * 100000000
        @eps = data["每股收益(元)"].to_f
      end

      def get_last_quote
        keys = ["DateTime", "LastClose", "Open", "High", "Low", "Price",
                "Volume", "Amount", "LastSettle", "SettlePrice", "OpenPosition", "ClosePosition",
                "BuyPrice", "BuyVolume", "SellPrice", "SellVolume", "PriceWeight",
                "EntrustRatio", "UpDown", "EntrustDiff", "UpDownRate", "OutVolume",
                "InVolume", "AvePrice", "VolumeRatio", "PE", "ExchangeRatio",
                "LastVolume", "VibrationRatio", "DateTime", "OpenTime", "CloseTime"]

        query_string = "code=#{@exchange}#{@symbol}&callback=callback&column=#{keys.join(',')}"
        quote = "http://webstock.quote.hermes.hexun.com/a/quotelist?#{query_string}"

        begin
          values = JSON.parse(/\((.*?)\);/.match(URI.parse(quote).read)[1])["Data"][0][0]
          data = Hash[keys.zip(values)]

          @open = data["Open"].to_f / 100
          @high = data["LastClose"].to_f / 100
          @low = data["Low"].to_f / 100
          @previous_close = data["LastClose"].to_f / 100
          @price = data["Price"].to_f / 100
          @volume = data["Volume"]
          @amount = data["Amount"].to_f / 100

          @bids = Hash[data["BuyPrice"].collect { |p| p.to_f / 100 }.zip(data["BuyVolume"])]
          @offers = Hash[data["SellPrice"].collect { |p| p.to_f / 100 }.zip(data["SellVolume"])]
        rescue
          @price = 0
          @previous_close = 0
        end

      end
  end
end
