require "enumerator"
require "nokogiri"
require "pathname"
require "csv"

require_relative "common"

def column_for_turn(direction, kind)
  if direction == "left"
    if kind == "turn"
      0
    else
      1
    end
  else
    if kind == "turn"
      4
    else
      3
    end
  end    
end

def process_maneuvers(moves, maneuver_string, color)
  unless maneuver_string == nil
    maneuver_string = maneuver_string.downcase.gsub("forward", "straight")
    maneuvers = maneuver_string.split(/\s*,\s*/)
    maneuvers.each do |one_move|
      speed, kind = one_move.split(/\s+/)
      if kind == "straight" || kind == "flank" || kind == "stop"
        moves.push({:color => color, :speed => speed.to_i, :kind => kind, :column => 2})
      elsif kind == "rotate"
        moves.push({:color => color, :speed => 0, :kind => speed + "-" + kind, :column => 2})
      elsif kind == "reverse"
        moves.push({:color => color, :speed => speed.to_i * -1, :kind => "straight", :column => 2})
      else
        ["left", "right"].each do |direction|
          moves.push({:color => color, :speed => speed.to_i, :kind => "#{direction}-#{kind}", :column => column_for_turn(direction, kind)})          
        end
      end
    end
  end
end

# Timestamp	Uniqueness	Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots	Expansion Pack	Maneuver Grid	Firing Arcs	Build/Price Adjustment	Green Maneuvers	White Maneuvers	Red Maneuvers										
ship = <<-SHIPTEXT
7/18/2015 18:51:11	72009 - IKS T'Ong	Unique	I.K.S. T'Ong	Klingon	K'Tinga Class	K'Tinga Class				4	1	4	3	When attacking a ship with your Primary Weapon that has a larger Hull value and/or Primary Weapon value than your ship, gain +1 attack die.	Cloak, Evasive, Sensor Echo, Target Lock	24	0	1	1	2	90-degree forward, 90-degree rear		0
7/19/2015 16:56:38	72001 - USS Bellerophon	Unique	U.S.S. Bellerophon	Federation	Intrepid Class	Intrepid Class				4	2	4	5	When defending, during the Compare Results step, you may disable 2 of your Active Shields to cancel 1 of the attacking ship's [HIT] results.	Battle Stations, Evasive, Scan, Target Lock	30	0	2	1	2	90-degree forward, 90-degree rear		0
7/25/2015 14:18:06	72010 - IRW Vrax	Unique	I.R.W. Vrax	Romulan	Valdore Class	Valdore Class				4	2	6	3	If you reveal a 4 [FORWARD] maneuver, immediately before you move, you may change it to a 4 Bank maneuver.  Treat this as a Red Maneuver.	Cloak, Evasive, Sensor Echo, Target Lock	30	0	2	0	2	90-degree forward		0
7/30/2015 13:01:22	72001 - USS Bellerophon	Non-unique	Federation Starship	Federation	Intrepid Class	Intrepid Class				4	2	4	4		Battle Stations, Evasive, Scan, Target Lock	28	0	1	1	2	90-degree forward, 90-degree rear		0
7/30/2015 13:05:18	72010 - IRW Vrax	Non-unique	Romulan Starship	Romulan	Valdore Class	Valdore Class				4	2	6	2		Cloak, Evasive, Sensor Echo, Target Lock	28	0	2	0	1	90-degree forward		0
7/30/2015 13:05:57	72009 - IKS T'Ong	Non-unique	Klingon Starship	Klingon	K'Tinga Class	K'Tinga Class				4	1	4	2		Cloak, Evasive, Sensor Echo, Target Lock	22	0	1	1	1	90-degree forward, 90-degree rear		0
7/30/2015 14:43:56	72008 - USS Thunderchild	Unique	U.S.S. Thunderchild	Federation	Akira Class		1 Bank, 1 Forward, 2 Forward	2 Turn, 2 Bank, 3 Bank, 3 Forward, 4 Forward	3 Turn, 3 Come About	4	2	5	3	Each time you defend, if you take no damage from an attack, you may immediately roll 1 attack die. A [HIT] or [CRIT] result damages the attacking ship.	Battle Stations, Evasive, Scan, Target Lock	28	0	1	0	3	90-degree forward		0
7/30/2015 14:44:34	72008 - USS Thunderchild	Non-unique	Federation Starship	Federation	Akira Class	Akira Class				4	2	5	2		Battle Stations, Evasive, Scan, Target Lock	26	0	1	0	2	90-degree forward		0
SHIPTEXT


convert_terms(ship)

new_ships = File.open("new_ships.xml", "w")

shipLines = ship.split "\n"
shipLines.each do |l|
# Timestamp		Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots	Expansion Pack	Maneuver Grid										*
  parts = l.split "\t"
  title = parts[3]
  shipClass = parts[5]
  unique = parts[2] == "Unique" ? "Y" : "N"
  mirrorUniverseUnique = parts[2] == "Mirror Universe Unique" ? "Y" : "N"
  faction_string = parts[4]
  faction_parts = faction_string.split(/\s*,\s*/)
  faction = faction_parts[0]
  additional_faction = faction_parts[1]
  unless faction
    throw "Faction missing"
  end
  attack = parts[10]
  agility = parts[11]
  hull = parts[12]
  shield = parts[13]
  ability = parts[14]
  action_bar = parts[15].split(/,\s*/)
  evasiveManeuvers = action_bar.include?("Evasive") ? 1 : 0
  battleStations = action_bar.include?("Battle Stations") ? 1 : 0
  cloak = action_bar.include?("Cloak") ? 1 : 0
  sensorEcho = action_bar.include?("Sensor Echo") ? 1 : 0
  targetLock = action_bar.include?("Target Lock") ? 1 : 0
  scan = action_bar.include?("Scan") ? 1 : 0
  regenerate = action_bar.include?("Regenerate") ? 1 : 0
  cost = parts[16]
  borg = parts[17]
  crew = parts[18]
  tech = parts[19]
  squad = parts[23]
  weapon = parts[20]
  expansion = parts[1]
  firing_arcs = parts[21]
  arc_360 = firing_arcs.include?("360-degree") ? "Y" : "N"
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
if cost.length == 0
	cost = (agility.to_i + attack.to_i + hull.to_i + shield.to_i) * 2
end
  shipXml = <<-SHIPXML
  <Ship>
    <Title>#{title}</Title>
    <Unique>#{unique}</Unique>
    <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
    <ShipClass>#{shipClass}</ShipClass>
    <Faction>#{faction}</Faction>
    <AdditionalFaction>#{additional_faction}</AdditionalFaction>
    <Attack>#{attack}</Attack>
    <Agility>#{agility}</Agility>
    <Hull>#{hull}</Hull>
    <Shield>#{shield}</Shield>
    <Ability>#{ability}</Ability>
    <Cost>#{cost}</Cost>
    <EvasiveManeuvers>#{evasiveManeuvers}</EvasiveManeuvers>
    <TargetLock>#{targetLock}</TargetLock>
    <Scan>#{scan}</Scan>
    <Battlestations>#{battleStations}</Battlestations>
    <Cloak>#{cloak}</Cloak>
    <SensorEcho>#{sensorEcho}</SensorEcho>
    <Regenerate>#{regenerate}</Regenerate>
    <Borg>#{borg}</Borg>
    <Tech>#{tech}</Tech>
    <Weapon>#{weapon}</Weapon>
    <Crew>#{crew}</Crew>
    <SquadronUpgrade>#{squad}</SquadronUpgrade>
    <Has360Arc>#{arc_360}</Has360Arc>
    <Id>#{externalId}</Id>
    <Set>#{setId}</Set>
  </Ship>
  SHIPXML
  new_ships.puts shipXml
end

new_ship_class_details = File.open("new_ship_class_details.xml", "w")

shipLines.each do |l|
  parts = l.split "\t"
  ship_class = parts[5]
  ship_class_id = sanitize_title(ship_class).downcase
  maneuver_grid = parts[6]
  firing_arcs = parts[21]
  front_arc = ""
  rear_arc = ""
  firing_arc_parts = firing_arcs.split(",")
  firing_arc_parts.each do |arc_part|
    arc_part = arc_part.strip
    case arc_part.chomp
    when "90-degree forward"
      front_arc = "90"
    when "180-degree forward"
      front_arc = "180"
    when "90-degree rear"
      rear_arc = "90"
    end
  end
  moves = []
  green_maneuvers = parts[7]
  process_maneuvers(moves, green_maneuvers, "green")
  white_maneuvers = parts[8]
  process_maneuvers(moves, white_maneuvers, "white")
  red_maneuvers = parts[9]
  process_maneuvers(moves, red_maneuvers, "red")
  moves.sort! do |a,b| 
    v = b[:speed] <=> a[:speed]
    if v == 0
     v = a[:column] <=> b[:column] 
    end
    v
  end
  
  maneuver_parts = moves.collect do |one_move|
    %Q(      <Maneuver speed="#{one_move[:speed]}" kind="#{one_move[:kind]}" color="#{one_move[:color]}" />)
  end
  shipClassXml = <<-SHIPXML
  <ShipClassDetail>
    <Name>#{ship_class}</Name>
    <Id>#{ship_class_id}</Id>
    <Maneuvers>
#{maneuver_parts.join("\n")}
    </Maneuvers>
    <FrontArc>#{front_arc}</FrontArc>
    <RearArc>#{rear_arc}</RearArc>
  </ShipClassDetail>
  SHIPXML
  new_ship_class_details.puts shipClassXml
end
