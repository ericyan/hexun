require 'open-uri'
require 'nokogiri'
require 'time_series'

module Hexun
  class Fund
    def initialize(symbol)
      @symbol = symbol.to_i
    end

    def quotes
      doc = Nokogiri::XML(open("http://data.funds.hexun.com/outxml/detail/openfundnetvalue.ashx?fundcode=#{@symbol}"))

      quotes = TimeSeries.new
      doc.root.xpath("Data").each do |quote|
        quotes << DataPoint.new(
          Date.parse(quote.xpath("fld_enddate").text),
          quote.xpath('fld_unitnetvalue').text.to_f
        )
      end

      return quotes
    end
  end
end
