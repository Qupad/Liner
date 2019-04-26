require 'nokogiri'
require 'open-uri'
require 'csv'
require 'json'

def valid_json?(string)
  !!JSON.parse(string)
rescue JSON::ParserError
  false
end

last_p = 0
current_p = 0

page_m = Nokogiri::HTML(open('https://catalog.onliner.by/', 'User-Agent' => 'Yandex'))
page_m.xpath('//a[@class="catalog-navigation-list__dropdown-item"]').each do |page|
	href =  page.xpath('./@href').text
	href.sub!("https://catalog.onliner.by","https://catalog.api.onliner.by/search")
	puts href
	puts valid_json?(href)
	if valid_json?(href)
		puts href
		
		hrefs << href
	end
end

#jso = JSON.parse(page_m.text)
#hash = jso["page"]
#puts hash["current"]
	
