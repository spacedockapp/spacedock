require "enumerator"
require "nokogiri"
require "pathname"

script_path = Pathname.new(File.dirname(__FILE__))
root_path = script_path.parent()
src_path =  root_path.join("src")
build_path =  root_path.join("build")
xml_path = src_path.join("Data.xml").to_s
xml_text = File.read(xml_path)
doc = Nokogiri::XML(xml_text)

titles = {}

ships = doc.xpath("//Data//Ships/Ship").collect do |ship|
  title = ship.at_xpath("Title")
  faction = ship.at_xpath("Faction")
  unique = ship.at_xpath("Unique")
  set = ship.at_xpath("Set")
  if unique.content == "Y"
    s = { :title => title.content, :faction => faction.content, :type => "Ship", :set => set.content }
  end
  s
end

$sets = {}
doc.xpath("//Data//Sets/Set").each do |set|
  $sets[set[:id]] = set.content
end

sort_order = {
  "Ship" => 1,
  "Captain" => 2,
  "Crew" => 3,
  "Talent" => 4,
  "Tech" => 5,
  "Weapon" => 6
}

captains = doc.xpath("//Data//Captains/Captain").collect do |captain|
  title = captain.at_xpath("Title")
  faction = captain.at_xpath("Faction")
  unique = captain.at_xpath("Unique")
  set = captain.at_xpath("Set")
  if unique && unique.content == "Y"
    s = { :title => title.content, :faction => faction.content, :type => "Captain", :set => set.content }
  end
  s
end

upgrades = doc.xpath("//Data//Upgrades/Upgrade").collect do |upgrade|
  title = upgrade.at_xpath("Title")
  faction = upgrade.at_xpath("Faction")
  type = upgrade.at_xpath("Type")
  set = upgrade.at_xpath("Set")
  s = { :title => title.content, :faction => faction.content, :type => type.content, :set => set.content }
  s
end

items = ships + captains + upgrades

items.compact!.sort! do |a,b| 
  v = a[:faction] <=> b[:faction]
  if v == 0
    v = sort_order[a[:type]] <=> sort_order[b[:type]]
  end
  if v == 0
    v = a[:title] <=> b[:title]
  end
  v
end

items.each do |item|
  title = item[:title]
  count = titles[title]
  if count == nil
    count = 1
  else
    count = count + 1
  end
  titles[title] = count
end

def set_name(set_string)
  set_parts = set_string.split ","
  set_names = set_parts.collect { |p| $sets[p.chomp] }
  set_names[0]
end

faction = ""
type = ""
items.each do |a|
  if a[:faction] != faction
    faction = a[:faction]
    puts "== #{faction} ==\n\n"
  end
  if a[:type] != type
    type = a[:type]
    puts "=== #{type} ===\n\n"
  end
  title = a[:title]
  type = a[:type]
  set_id = a[:set]
  set_name = set_name set_id
  puts "[[Star Trek: Attack Wing: #{title} (#{set_name})|#{title} (#{set_name})]]\n\n"
end