require 'open-uri'
require 'nokogiri'
require 'time_series'

module Hexun
  class Fund
    def initialize(symbol)
      @symbol = "%06d" % symbol.to_i
    end

    def quotes
      Cache.get_or_set "#{@symbol}-quotes-#{Date.today}" do
        doc = Nokogiri::XML(open("http://data.funds.hexun.com/outxml/detail/openfundnetvalue.ashx?fundcode=#{@symbol}"))

        quotes = TimeSeries.new
        doc.root.xpath("Data").each do |quote|
          quotes << DataPoint.new(
            Date.parse(quote.xpath("fld_enddate").text),
            quote.xpath('fld_unitnetvalue').text.to_f
          )
        end

        quotes
      end
    end

    def dividends
      Cache.get_or_set "#{@symbol}-dividends-#{Date.today}" do
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

        dividends
      end
    end

    def holdings(year = Time.now.year, quarter = ((Time.now.month - 4) / 3) + 1)
      Cache.get_or_set "#{@symbol}-holdings-#{year}Q#{quarter}-#{Date.today}" do
        query_string = "fundcode=#{@symbol}&date=#{year}-#{(quarter * 3).to_s.rjust(2, "0")}-15"
        page = Nokogiri::HTML(open("http://jingzhi.funds.hexun.com/Detail/DataOutput/Top10HoldingStock.aspx?#{query_string}"))

        holdings = []
        page.css("table tr").drop(1).each do |line|
          values = line.css("td")

          holdings << {
            stock:  /\/(\d{6})\./.match(values[0].css('a').attribute('href').to_s)[1].rjust(6, "0"),
            amount: values[3].text.to_i,
            weight: values[4].text.to_f / 100
          }
        end

        holdings
      end
    end
  end
end
