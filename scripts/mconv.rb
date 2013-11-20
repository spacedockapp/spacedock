require "enumerator"

ship = <<-SHIPTEXT
Galaxy Class	
		WHITE				Front Arc
		WHITE				90°
RED	WHITE	GREEN	WHITE	RED		
	WHITE	GREEN	WHITE			Rear Arc
	GREEN	GREEN	GREEN			90°
		RED				
		RED				
Miranda Class	
						Front Arc
		WHITE				180°
WHITE	WHITE	WHITE	WHITE	WHITE		
WHITE	WHITE	GREEN	WHITE	WHITE		Rear Arc
	GREEN	GREEN	GREEN			90°
						
		RED				
Constitution Class	
						Front Arc
		WHITE				180°
RED	WHITE	WHITE	WHITE	RED		
WHITE	WHITE	GREEN	WHITE	WHITE		
	GREEN	GREEN	GREEN			
						
		RED				
Defiant Class	
						Front Arc
		WHITE				90°
WHITE	WHITE	WHITE	WHITE	WHITE	RED	
WHITE	WHITE	GREEN	WHITE	WHITE		Rear Arc
	GREEN	GREEN	GREEN			90°
						
						
D'deridex Class	
						Front Arc
		WHITE				90°
WHITE	WHITE	WHITE	WHITE	WHITE		
WHITE	WHITE	GREEN	WHITE	WHITE		
	GREEN	GREEN	GREEN			
						
		RED				
Valdore Class	
						Front Arc
		WHITE				90°
RED	WHITE	WHITE	WHITE	RED	RED	
WHITE	GREEN	GREEN	GREEN	WHITE		
	GREEN	GREEN	GREEN			
						
						
Romulan Science Vessel	
						Front Arc
		WHITE				90°
	WHITE	WHITE	WHITE			
WHITE	GREEN	GREEN	GREEN	WHITE	WHITE	
WHITE	GREEN	GREEN	GREEN	WHITE		
						
						
Romulan Bird of Prey Class	
						Front Arc
		WHITE				90°
WHITE	WHITE	WHITE	WHITE	WHITE	RED	
WHITE	WHITE	GREEN	WHITE	WHITE		
	GREEN	GREEN	GREEN			
						
						
Vor'cha Class	
						Front Arc
		WHITE				90°
RED	WHITE	WHITE	WHITE	RED	RED	
WHITE	GREEN	GREEN	GREEN	WHITE		
	GREEN	GREEN	GREEN			
						
						
D7 Class*	
						Front Arc
		WHITE				90°
RED	WHITE	WHITE	WHITE	RED	RED	
WHITE	WHITE	GREEN	WHITE	WHITE		
	GREEN	GREEN	GREEN			
						
						
Negh'var Class	
						Front Arc
		WHITE				90°
RED	WHITE	WHITE	WHITE	RED	RED	
WHITE	WHITE	GREEN	WHITE	WHITE		
	GREEN	GREEN	GREEN			
						
						
K'T'Inga Class	
						Front Arc
		WHITE				90°
RED	WHITE	WHITE	WHITE	RED	RED	
WHITE	WHITE	GREEN	WHITE	WHITE		Rear Arc
	GREEN	GREEN	GREEN			90°
						
						
Cardassian Galor Class	
		WHITE				Front Arc
		WHITE				180°
RED	WHITE	WHITE	WHITE	RED		
RED	WHITE	GREEN	WHITE	RED		
	GREEN	GREEN	GREEN			
						
						
Breen Battle Cruiser	
						Front Arc
		WHITE				90°
RED	WHITE	WHITE	WHITE	RED	RED	
WHITE	WHITE	GREEN	WHITE	WHITE		
	GREEN	GREEN	GREEN			
						
						
Jem'Hadar Attack Ship	
						Front Arc
		WHITE				90°
WHITE	WHITE	WHITE	WHITE	WHITE	RED	
WHITE	GREEN	GREEN	GREEN	WHITE		
	GREEN	GREEN	GREEN			
						
						
Ferengi D'Kora Class	
						Front Arc
		WHITE				90°
RED	WHITE	WHITE	WHITE	RED		
WHITE	WHITE	GREEN	WHITE	WHITE		
	GREEN	GREEN	GREEN			
		RED				
						
B'rel Class	
						Front Arc
		WHITE				90°
WHITE	WHITE	WHITE	WHITE	WHITE	RED	
WHITE	GREEN	GREEN	GREEN	WHITE		Rear Arc
	GREEN	GREEN	GREEN			90°
						
						
SHIPTEXT

directions = ["left-turn", "left-bank", "straight", "right-bank", "right-turn", "about"]
shipLines = ship.split "\n"
speed = 6
frontArc = ""
rearArc = ""
shipLines.each do |l|
  if speed == 6
    parts = l.split "\t"
    puts %Q(<Ship class="#{parts[0].chomp}">)
    puts %Q(\t<Maneuvers>)
  else
    parts = l.split "\t"
    directions.to_enum.with_index(0) do |direction, i|
      if i < parts.length
        move = parts[i].chomp
        if move.length > 0
          puts %Q[\t\t<Maneuver speed="#{speed}" type="#{direction}" color="#{move}" />]
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
    puts "</Ship>"
    speed = 6
    frontArc = rearArc = ""
  end
end
