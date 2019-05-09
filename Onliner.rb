require 'nokogiri'
require 'open-uri'
require 'csv'
require 'json'
require 'sqlite3'
require 'parallel'

@count503 = 0
@alpha_m = Mutex.new

def write_in_file(type, name, price, descr, status)
	CSV.open('Onliner1.txt', 'a') do |file|
    file << [type, name, price, descr, status]
  end
end

def parse(url)
	Nokogiri::HTML(open(url), nil, Encoding::UTF_8.to_s)
rescue OpenURI::HTTPError => e
  response = e.io
  puts "\n\t			***  HTTP ERROR  ***\n\t\t\t#{response.status}\n"
  status = response.status
  if status.to_s =~ /503/
    @count503 += 1
		puts "\n\t\t\tERRORS OCCURED: #{@count503} PEACES\n"
    sleep Random.new.rand(20..29)
    parse(url)
  end
end

def parseJson(url, uri)
  JSON.parse(url.text)
rescue JSON::ParserError => e
	puts "\n			MEGA ERROR			\n\t\tUNVALID JSON IN URL #{uri}\n"
	false
end

apis = []

File.open('valid_api.txt', 'r') do |f|
  f.each_line do |line|
    apis << line.strip
  end
end

Parallel.map(apis, in_threads: 5, progress: 'Main thread') do |url|
  url_temp = url
  hash = []
	jso = []
  pages = []
	sleep Random.new.rand(0.6..3.5)
	page_m = parse(url)
	jso = parseJson(page_m, url)
	hash = jso['page']
  current_p = hash['current']
  last_p = hash['last']
	amount = hash['items']
	amount.times do |i|
		if jso['products'][i]['prices'].nil?
			status = 'inactive'
			price = 'null'
		else
			price = jso['products'][i]['prices']['price_min']['amount']
			status = 'active'
		end
			name = jso['products'][i]['extended_name'].gsub(/,/, ' ')
			type = jso['products'][i]['name_prefix'].gsub(/"/, '')
			descr = jso['products'][i]['description'].gsub(/,/, ' ')
			write_in_file(type, name, price, descr, status)
	rescue
		puts "\n\t JSON ERROR IN #{url}"
		next
	end
  last_p.times do |i|
		if i >= 1
			pages << url_temp + '?page=' + (i + 1).to_s
		end
  end
  Parallel.map(pages, in_threads: 5, progress: 'Pages') do |uri|
    jso = []
		page_p = ''
		sleep Random.new.rand(1.0..2.5)
		@alpha_m.synchronize do
			sleep Random.new.rand(0.2..1.0)
			page_p = parse(uri)
		end
		jso = parseJson(page_p, uri)	
		next unless jso
		amount = jso['page']['items']
		puts "\n #{uri} \n"
		amount.times do |i|
			if jso['products'][i]['prices'].nil?
				status = 'inactive'
				price = 'null'
			else
				price = jso['products'][i]['prices']['price_min']['amount']
				status = 'active'
			end
			name = jso['products'][i]['extended_name'].gsub(/,/, ' ')
			type = jso['products'][i]['name_prefix'].gsub(/"/, '')
			descr = jso['products'][i]['description'].gsub(/,/, ' ')
			write_in_file(type, name, price, descr, status)
		rescue
			puts "\n\t JSON ERROR IN #{uri}"
			next
		end
		
		sleep Random.new.rand(0.2..1.0)
  end
rescue
	puts "\n\t\t GLOBAL ERROR \N"
	next
end
