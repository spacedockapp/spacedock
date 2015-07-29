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
6/23/2015 19:35:36	71805 - USS Dauntless	Unique	U.S.S. Dauntless	Independent	Dauntless Class		1 Bank, 1 Forward, 2 Forward	2 Bank, 2 Turn, 3 Forward, 3 Bank, 4 Forward, 5 Forward	3 Turn	2	2	4	5	Each time you perform an Action or use an ability on any of your [TECH] Upgrades, place 1 Mission Token on this card.  During the Roll Attack dice step, you may spend up to 2 of these tokens to gain +1 attack die for that attack for each token spent.	Battle Stations, Evasive, Scan, Target Lock	26	0	0	4	0	90-degree forward		0
6/23/2015 19:56:51	72000p - IRW Terix	Mirror Universe Unique	I.R.W. Terix	Mirror Universe	D'deridex Class	D'deridex Class				3	2	6	4	After you perform a Green Maneuver, you may immediately perform a [SCAN] Action as a free Action.	Cloak, Evasive, Sensor Echo, Target Lock	30	0	1	2	2	90-degree forward		0
6/23/2015 19:57:28	72000p - IRW Terix	Non-unique	Mirror Universe Starship	Mirror Universe	D'deridex Class	D'deridex Class				3	2	6	3		Cloak, Evasive, Sensor Echo, Target Lock	28	0	1	1	2	90-degree forward		0
6/25/2015 21:57:08	71805 - USS Dauntless	Non-unique	Independent Starship	Independent	Dauntless Class	Dauntless Class				2	2	4	4		Battle Stations, Evasive, Scan, Target Lock	24	0	0	3	0	90-degree forward		0
6/27/2015 18:42:53	71806 - Kreechta	Unique	Kreechta	Ferengi	D'kora Class	D'Kora Class				3	1	4	3	When attacking a ship that has damaged Shields, during the Modify Attack Dice step, you may re-roll a number of your Attack dice up to the number of the defending ship's damaged Shields.	Evasive, Scan, Target Lock	22	0	1	2	1	90-degree forward		0
6/27/2015 18:43:26	71806 - Kreechta	Non-unique	Ferengi Starship	Ferengi	D'kora Class	D'kora Class				3	1	4	2		Evasive, Scan, Target Lock	20	0	1	1	1	90-degree forward		0
6/29/2015 19:40:04	71807 - USS Pasteur	Mirror Universe Unique	U.S.S. Pasteur	Mirror Universe	Olympic Class		1 Bank, 1 Forward, 2 Forward	2 Bank, 3 Forward, 3 Bank, 4 Forward, 5 Forward	3 Turn, 1 Reverse, 6 Forward	1	1	5	4	After you perform a maneuver with a speed of 5 or greater, you may immediately perform an [EVADE] Action as a free Action.	Battle Stations, Evasive, Scan	22	0	2	2	0	90-degree forward		0
7/2/2015 21:46:15	71807 - USS Pasteur	Non-unique	Mirror Universe Starship	Mirror Universe	Olympic Class	Olympic Class				1	1	5	3		Battle Stations, Evasive, Scan	20	0	1	2	0	90-degree forward		0
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
