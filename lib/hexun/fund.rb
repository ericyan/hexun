require 'open-uri'
require 'nokogiri'
require 'time_series'

module Hexun
  class Fund
    def initialize(symbol)
      @symbol = symbol.to_i
    end

    def quotes(type = :nav)
      doc = Nokogiri::XML(open("http://data.funds.hexun.com/outxml/detail/openfundnetvalue.ashx?fundcode=#{@symbol}"))
      key = case type
            when :nav then "fld_unitnetvalue" # Net Asset Value
            when :auv then "fld_netvalue"     # Accumulated Unit Value
            end

      quotes = TimeSeries.new
      doc.root.xpath("Data").each do |quote|
        quotes << DataPoint.new(
          Date.parse(quote.xpath("fld_enddate").text),
          quote.xpath(key).text.to_f
        )
      end

      return quotes
    end
  end
end
