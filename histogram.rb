require 'mechanize'
require 'nokogiri'
require 'ruby-tf-idf'
require 'httparty'
require 'optparse'
require 'ostruct'

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('--url Url-Name-To-Scrape') {|o| options.url = o}
end.parse!

base_url = options.url

raise "Input the url ! ! ! for example: ruby histogram.rb --url https://google.com" unless base_url
puts "Your url is avaliable!!!"
# Mechanize initialize
agent = Mechanize.new

# Mechanize config setting
agent.user_agent_alias = 'Windows Chrome'
agent.follow_meta_refresh = true
agent.ignore_bad_chunking = true

# Bring the html for base url
page = agent.get(base_url)
puts "Scrape your url ....."

link_url = []
main_url = []

# Get the urls that are accessible from base page
page.search('a').each do |a|
   link_url << {url:a.attributes["href"].value} if a.attributes["href"] && (a.attributes["href"].value.to_s.include? "http")
end

# distinct and count urls that are accessible
link_url.each do |a|
   i = 0
   next if main_url.any? {|m| m[:url] == a[:url]}
   link_url.each do |b|
      i += 1 if a == b
   end
   main_url << {url: a[:url], value: i} unless i == 0
end

$main_text = []

# Get the text from main page 
$main_text << page.parser.css('div').text

# Scrape page using urls that are accessible
puts "Scrape the urls that are accessible ....."
$global_text = ''
main_url.each do |m|
   begin
	result = agent.get(m[:url])
 	$main_text << result.parser.css('div').text
	$global_text += result.parser.css('div').text
   rescue Mechanize::ResponseCodeError => e
	redirect_url = HTTParty.get(m[:url]).request.last_uri.to_s
 	puts e
   rescue Exception => e
	puts e
   end
end

# make file name
puts "Make file name ...."
filename = "" 
8.times{filename  << (65 + rand(25)).chr}

filename = Time.now.to_s + filename + ".txt"
link_filename = "link_" + filename

# Get the value using TF-IDF
t = RubyTfIdf::TfIdf.new($main_text, 0, false)

global_t = RubyTfIdf::TfIdf.new($global_text.split(' '), 0, false)
puts "Get the value using TF-IDF ......"

# global text ranking
global_sort = global_t.tf_idf.sort_by{ |value| value.values[0] }.reverse

global_sort.uniq!{|value| value}

# Write the info to file
puts "Write file into txt format ......"
puts "File name is " + filename
special = "\?<>',?[]}{=-)(*&^%$#`~{}\/"
regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/


global_sort.each  do |a|
   key, value = a.first
   next if key =~ regex
   File.open(filename, "a+"){|file| file.write( key+':'+ value.to_s + "\n")}
end

i = 1000
t.tf_idf.each do |a|
   eachfilename = filename + i.to_s
   a.each do |b|
       next if b[0] =~ regex
       File.open(eachfilename, "a+") { |file| file.write(b.join(":") + "\n")}
   end
   i += 1
end

main_url.each do |m|
  File.open(link_filename, "a+") { |file| file.write(m[:url].to_s + ":" + m[:value].to_s + "\n") }
end


