require 'nokogiri'
require 'open-uri'
require 'csv'
require 'json'
require 'sqlite3'
require 'parallel'

@count503 = 0

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

def parse(url)
	return Nokogiri::HTML(open(url), nil, Encoding::UTF_8.to_s)
	rescue OpenURI::HTTPError => error	
		response = error.io
		puts "\n\t			***  SHIT HERE WE GO AGAIN  ***\n\t\t\t#{response.status}\n"
		status = response.status		
		if status.to_s =~ /503/
			@count503+=1
			puts "\n\t\t\tERRORS OCCURED: #{@count503} PEACES OF SHIT\n"
			sleep (Random.new.rand(15..24))		
			parse(url)
		end	
end

def parseJson(url)
	return JSON.parse(url.text)
	rescue JSON::ParserError => error
		puts "\n			MEGA SHIT			\n\t\t\tUNVALID JSON\n"
		return false
end

#db = SQLite3::Database.new 'Data.db'
#db.execute 'CREATE TABLE "products" ("id" integer, "type" string, "name" string, "price" integer, "descrition" string)'

#name = gets.chomp
apis = []
alpha_m = Mutex.new
alpha_p = Mutex.new

File.open("valid_api.txt",'r') do |f|
  f.each_line do |line|
	apis << line.strip
  end
end

Parallel.map(apis, in_threads: 5, progress:"Dick => Pussy") do |url|
	url_temp = url
	hash = []
	pages = []
	page_m = parse(url)
	jso = parseJson(page_m)
	sleep(0.5)
	hash = jso["page"]
	current_p = hash["current"]
	last_p = hash["last"]
	last_p.times do |i|
		pages << url_temp + "?page=" + (i+1).to_s
	end
	Parallel.map(pages, in_threads: 10, progress:"Page => Shit") do |uri|
		puts "\n #{uri} \n"
		href = []
		jso = []
		alpha_m.synchronize do
			page_m = parse(uri)
			jso = parseJson(page_m)
			if !jso
				next
			end
			sleep(0.5)
		end
		jso["products"].each do |uri|
			href << uri["html_url"]
		end
		alpha_p.synchronize do
			href.each do |uri|
				sleep(Random.new.rand(0.5..2))
				page = parse(uri)
				name = page.xpath('//*[@class="catalog-masthead__title"]/text()').text.strip
				descr = page.xpath('//p[@itemprop="description"]/text()').text
				price = page.xpath('//div[@class="offers-description__price offers-description__price_primary"]/a/text()').text.strip
				type = page.xpath('//ol/li[2]/a/span/text()').text
				
				puts "\n #{uri} \n"
				
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
	end
end
Parallel.map(User.all) do |user|
  raise Parallel::Break 
end