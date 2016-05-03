require 'optparse'
require 'ostruct'

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('--url Url-Name-To-Scrape') {|o| options.url = o}
end.parse!

puts options.url

