require 'nokogiri'
require 'open-uri'
require 'csv'
require 'json'
require 'parallel'
require 'ruby-progressbar'


def test1
	html = open('https://catalog.onliner.by/', 'User-Agent' => 'google.com, pub-8835043496074756').read
	puts html
end

def test2
	url = "https://catalog.onliner.by/"
	open(url, 'User-Agent' => 'google.com, pub-8835043496074756') do |f|
	puts f.read
	end
end

def valid_json?(string)
	!!JSON.parse(string)
	rescue JSON::ParserError
	  false
end

def write(href)
	File.open("valid_api.txt",'a'){ |file| file.puts(href) }	
end

def write_valid
	page_m = parse('https://catalog.onliner.by/')
	Parallel.map(page_m.xpath('//a[@class="catalog-navigation-list__dropdown-item"]'), in_threads: 3, progress:"Dick => Pussy") do |page|
		href =  page.xpath('./@href').text
		href.sub!("https://catalog.onliner.by","https://catalog.api.onliner.by/search")
		href.sub!(/[?].+/,'')
		page_m = parse(href)
		if valid_json?(page_m)
			puts href
			puts valid_json?(page_m)
			write(href)
		end
	end
end

def read_valid
	x = []

	File.open("valid_api.txt",'r') do |f|
	  f.each_line do |line|
		x << line
	  end
	end
	puts x[1]
end

def thrTest
	threads_m = []
	threads_p = []
	hrefs = []

	File.open("valid_api.txt",'r') do |f|
	  f.each_line do |line|
		hrefs << line.strip
	  end
	end

	size = hrefs.size

	20.times do |i|
		threads_m << Thread.new(i) do |thr_n|
			#puts i
			#sleep(1)
			10.times do |dick|
				threads_p << Thread.new(dick) do |pussy|
					puts pussy
				end
			end
		end
		threads_p.each {|thr| thr.join }
	end
	threads_m.each {|thr| thr.join }
end

def parse(url)

	return Nokogiri::HTML(open(url), nil, Encoding::UTF_8.to_s)
	rescue OpenURI::HTTPError => error
		puts "\n			***  SHIT HERE WE GO AGAIN  ***\n"
		response = error.io
		puts response.status
		puts response.string
		sleep (20)
		parse(url)
end

def parallelTest
	hrefs = []

	File.open("valid_api.txt",'r') do |f|
	  f.each_line do |line|
		hrefs << line.strip
	  end
	end
	i = 0

	Parallel.map(hrefs, in_threads: 3, progress:"Dick => Pussy") do |h|
		href = []
		page = parse(h)
		jso = JSON.parse(page.text)
		title = jso["products"]
		jso["products"].each do |uri|
			href << uri["name"]
		end
		print i+=1 	
		puts "   #{href[0]}"
		
	end

	Parallel.map(User.all) do |user|
	  raise Parallel::Break 
	end
	puts "yes"
end
def parseJson(url)
	return JSON.parse(url)
	rescue JSON::ParserError => error
		puts "\n			MEGA SHIT			\n\t\t\tUNVALID JSON\n"
		return false
end

@count503 = 0
@inactive_queue = []

def counter503
	@count503+=1
	sleep(0.2)
	puts "\n\t\t 503 ERRORS OCCURED: #{@count503} PEACES OF SHIT\n"
end

def queue(url)
	@inactive_queue.push(url)
	if @inactive_queue.size > 2
		return @inactive_queue.shift
	else
		return false
	end
end
