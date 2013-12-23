require 'net/http'
require 'uri'
require "enumerator"
require "nokogiri"
require "pathname"

script_path = Pathname.new(File.dirname(__FILE__))

url = "http://www.boardgamegeek.com/xmlapi2/thread?id=1031156&count=1"

uri = URI.parse(url)
response = Net::HTTP.get_response uri
xml_text = response.body

xml_doc  = Nokogiri::XML(xml_text)
titles = xml_doc.xpath("//thread/articles/article/body")
title = titles[0]

faq_text = title.content

faq_text.gsub! "<br/>", "\n"
faq_text.gsub! "</font>", ""

faq_text.gsub! /\n+/, "\n"
faq_text.gsub! /^<b>(\d+ *.*)<\/b>/, '=== \1 ==='
faq_text.gsub! /^<b>(.*)<\/b>/, '= \1 ='
faq_text.gsub! /<\/*b>/, '\'\'\''
faq_text.gsub! /<\/*i>/, '\'\''

puts faq_text