require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

script_path = Pathname.new(File.dirname(__FILE__))
root_path = script_path.parent()
src_path =  root_path.join("src")
xml_path = src_path.join("Data.xml").to_s
xml_text = File.read(xml_path)
doc = Nokogiri::XML(xml_text)

ships = doc.xpath("//Data//ShipClassDetails/ShipClassDetail/Id").collect do |node|
  node.content
end

v = ships.sort.last.to_i 
v+= 1

ship = <<-SHIPTEXT
Nova Class	
						Front Arc
		WHITE				90°
RED	WHITE	WHITE	WHITE	RED		
WHITE	WHITE	GREEN	WHITE	WHITE		Rear Arc
	GREEN	GREEN	GREEN			90°
		RED				
						
Raptor Class	
						Front Arc
		WHITE				90°
WHITE	WHITE	WHITE	WHITE	WHITE	RED	
WHITE	WHITE	GREEN	WHITE	WHITE		
	GREEN	GREEN	GREEN			
						
						
Jem'Hadar Battleship	
		WHITE				Front Arc
	WHITE	WHITE	WHITE			90°
RED	WHITE	GREEN	WHITE	RED		
	WHITE	GREEN	WHITE			
	WHITE	GREEN	WHITE			
								
							
SHIPTEXT

directions = ["left-turn", "left-bank", "straight", "right-bank", "right-turn", "about"]
shipLines = ship.split "\n"
speed = 6
frontArc = ""
rearArc = ""
externalId = v
shipLines.each do |l|
  if speed == 6
    parts = l.split "\t"
    name = parts[0].chomp
    puts %Q(<ShipClassDetail>)
    puts %Q(\t<Name>#{name}</Name>)
    puts %Q(\t<Id>#{sanitize_title(name).downcase()}</Id>)
    externalId += 1
    puts %Q(\t<Maneuvers>)
  else
    parts = l.split "\t"
    directions.to_enum.with_index(0) do |direction, i|
      if i < parts.length
        move = parts[i].chomp
        if move.length > 0
          puts %Q[\t\t<Maneuver speed="#{speed}" kind="#{direction}" color="#{move.downcase}" />]
          # LT Maneuver speed="3" type="tight" color="red" RT
          
        end
      end
    end
    case speed
    when 4
      if parts[6]
        frontArc = parts[6].to_i
      end
    when 1
      if parts[6]
        rearArc = parts[6].to_i
      end
      
    end
  end
  speed -= 1
  if speed == 0
    speed = -1
  end
  if speed == -3
    puts "\t</Maneuvers>"
    puts "\t<FrontArc>#{frontArc}</FrontArc>" if frontArc
    puts "\t<RearArc>#{rearArc}</RearArc>" if rearArc
    puts "</ShipClassDetail>"
    speed = 6
    frontArc = rearArc = ""
  end
end
