require 'helper'

module XmlTruth
  module DOM
    module XML
      ###
      # This benchmark is for comparing document parsing speeds
      class LargeDocumentXPathSearchTest < TestCase
        def setup
          @n        = (ENV['N'] || 1000).to_i
          @filename = File.join(ASSETS, 'itunes.xml')
          @stat     = File.stat(@filename)
          @xml      = File.read(@filename)

          puts
          puts "#{name} N=#{@n}"

          @ndoc = Nokogiri::XML(@xml)
          @ldoc = LibXML::XML::Parser.string(@xml).parse

          @hdoc = Hpricot.XML(@xml) if ENV['SLOW'] || ENV['HPRICOT']
          @rdoc = REXML::Document.new(@xml) if ENV['SLOW'] || ENV['HPRICOT']

          GC.start
        end

        def teardown
          GC.start
        end

        def test_simple_xpath
          bm(12) do |x|
            GC.start
            measure('nokogiri') do @n.times {
              @ndoc.xpath('//integer').length
            } end

            GC.start
            measure('libxml-ruby') do @n.times {
              @ldoc.find('//integer').length
            } end

            if ENV['HPRICOT'] || ENV['SLOW']
              GC.start
              measure('hpricot') do @n.times {
                @hdoc.search('//integer').length
              } end

            end
            
            if ENV['REXML'] || ENV['SLOW']
              GC.start
              measure('rexml') do @n.times {
                REXML::XPath.match(@rdoc, '//integer').length
              } end
            end
            
          end
        end
      end
    end
  end
end
