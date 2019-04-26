require 'nokogiri'
require 'open-uri'
require 'csv'
require 'json'
require 'sqlite3'

def wait(i,x=0)
#0 = even ; 1 = odd .
	if x == 0 && i%2 == 0 
		sleep(10)
	elsif x == 1 && i%2 != 0
		sleep(10)
	end
end

def valid_json?(string)
  !!JSON.parse(string)
rescue JSON::ParserError
  false
end

#db = SQLite3::Database.new 'Data.db'
#db.execute 'CREATE TABLE "products" ("id" integer, "type" string, "name" string, "price" integer, "descrition" string)'

#name = gets.chomp
threads_m = []
threads_p = []
hrefs = []

File.open("valid_api.txt",'r') do |f|
  f.each_line do |line|
	hrefs << line.strip
  end
end

size = hrefs.size

size.times do |i|
	threads_m << Thread.new(i) do |thr_n|
		url = hrefs[thr_n]
		url_temp = url
		hash = []
		wait(thr_n)
		puts thr_n
		sleep(9999)
		page_m = Nokogiri::HTML(open(url, 'User-Agent' => 'Yandex'))
		sleep(5)
		jso = JSON.parse(page_m.text)
		sleep(5)
		hash = jso["page"]
		current_p = hash["current"]
		last_p = hash["last"]
		last_p.times do |i|
			url_t = url_temp + "?page=" + (i+1).to_s
			puts url_t
			threads_p << Thread.new(url_t) do |uri|
				href = []
				wait(thr_n,1)
				page_m = Nokogiri::HTML(open(uri, 'User-Agent' => 'Yandex'))
				sleep(5)
				jso = JSON.parse(page_m.text)
				jso["products"].each do |uri|
					href << uri["html_url"]
				end
				href.each do |uri|
					sleep(1)
					page = Nokogiri::HTML(open(uri), nil, Encoding::UTF_8.to_s)
					sleep(5)
					name = page.xpath('//*[@class="catalog-masthead__title"]/text()').text.strip
					descr = page.xpath('//p[@itemprop="description"]/text()').text
					price = page.xpath('//div[@class="offers-description__price offers-description__price_primary"]/a/text()').text.strip

					puts name
					puts descr
					puts price

					type = page.xpath('//ol/li[2]/a/span/text()').text
					puts type
					
=begin
					i = 0		
					page.xpath('//*[@class="value__text"]').each do |node| 
						i += 1
						info = node.xpath('./text()').text
						if i == 1 || i == 4 || i == 5 || info =~ /\d+.(ГБ)$/
							arr << info
						end
					end	
					puts arr
=end	
					
					CSV.open("Onliner1.txt",'a'){ |file| 
						file << [name,type,price,descr]
					}	
				end
			end
			threads_p.each {|thr| thr.join }
		end
	end
end
threads_m.each {|thr| thr.join }