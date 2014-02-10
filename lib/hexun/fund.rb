require 'open-uri'
require 'nokogiri'
require 'time_series'

module Hexun
  class Fund
    def initialize(symbol)
      @symbol = "%06d" % symbol.to_i
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

    def dividends
      page = Nokogiri::HTML(open("http://jingzhi.funds.hexun.com/database/jjfh.aspx?fundcode=#{@symbol}"))

      dividends = []
      page.css("table#fundData tr").drop(1).each do |line|
        values = line.css("td").collect { |td| td.text }
        dividends << {
          declaration_date: Date.parse(values[0]),
          amount:           values[2].to_f,
          record_date:      Date.parse(values[3]),
          ex_dividend_date: Date.parse(values[4]),
          payment_date:     Date.parse(values[5])
        }
      end

      return dividends
    end
  end
end
