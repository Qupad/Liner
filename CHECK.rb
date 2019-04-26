require 'nokogiri'
require 'open-uri'
require 'csv'
require 'json'


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
	File.open("valid_api.txt",'a'){ |file| 
							file.puts(href)
						}	
end

def write_valid
	page_m = Nokogiri::HTML(open('https://catalog.onliner.by/', 'User-Agent' => 'Yandex'))
	page_m.xpath('//a[@class="catalog-navigation-list__dropdown-item"]').each do |page|
		href =  page.xpath('./@href').text
		href.sub!("https://catalog.onliner.by","https://catalog.api.onliner.by/search")
		sleep(1.5)
		page_m = Nokogiri::HTML(open(href))
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
