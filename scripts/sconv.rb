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
    maneuver_string = maneuver_string.downcase.gsub("come about", "about")
    maneuvers = maneuver_string.split(/\s*,\s*/)
    maneuvers.each do |one_move|
      speed, kind = one_move.split(/\s+/)
      if kind == "straight" || kind == "flank" || kind == "stop" || kind == "about"
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
11/9/2017 13:54:03	72945 - Romulan Faction Pack	Unique	I.R.W. Suran	Romulan	Valdore Class	Valdore Class				4	2	6	3	COMBAT PHASE: After this ship attacks:  This ship may perform a 2 [GREEN BANK LEFT] or a 2 [GREEN BANK RIGHT] Maneuver.	Cloak, Evasive, Sensor Echo, Target Lock	28	0	2	1	1	90-degree forward		0
11/10/2017 12:47:09	72944 - Federation vs. Klingons Starter Set	Unique	U.S.S. Enterprise-D	Federation	Galaxy Class	Galaxy Class				4	1	5	4	WHEN DEFENDING:  The attacking ship rolls -1 attack die.	Battle Stations, Evasive, Scan, Target Lock	26	0	3	1	1	90-degree forward, 90-degree rear		0
11/10/2017 12:49:02	72946 - Dominion Faction Pack	Unique	3rd Division Battle Cruiser	Dominion	Jem'Hadar Battle Cruiser	Jem'Hadar Battle Cruiser				5	1	6	5	Jem'Hadar Attack Ships within Range 1 roll +1 defense dice.	Battle Stations, Evasive, Scan, Target Lock	33	0	2	2	1	90-degree forward		0
11/11/2017 12:28:48	72944 - Federation vs. Klingons Starter Set	Unique	K'Mpec's Attack Cruiser	Klingon	Vor'Cha Class	Vor'Cha Class				5	1	5	3	ACTION: Target all Cloaked friendly ships within Range 1-2.  Place a [BATTLE STATIONS] Token beside all target ships.	Cloak, Evasive, Sensor Echo, Target Lock	25	0	2	1	1	90-degree forward		0
11/16/2017 12:14:50	72945 - Romulan Faction Pack	Unique	Jarok's Scout Vessel	Romulan	Romulan Scout Vessel	Romulan Scout Vessel				1	3	2	2	ACTIVATION PHASE: Place 2 [TIME] Tokens on this card and target a friendly [ROMULAN] ship within Range 1.  The target ship may perform an Action as a Free Action.	Cloak, Evasive, Scan, Sensor Echo	12	0	1	1	1	90-degree forward		0
11/16/2017 16:33:25	72946 - Dominion Faction Pack	Unique	2nd Wing Patrol Ship	Dominion	Jem'Hadar Attack Ship	Jem'Hadar Attack Ship				3	2	3	3	This ship rolls +2 defense dice if there is another Jem'Hadar Attack Ship within Range 1.	Battle Stations, Evasive, Scan, Target Lock	16	0	2	1	1	90-degree forward		0
11/21/2017 14:47:16	72945 - Romulan Faction Pack	Non-unique	Romulan Starship	Romulan	Valdore Class	Valdore Class				4	2	6	2		Cloak, Evasive, Sensor Echo, Target Lock	24	0	2	0	1	90-degree forward		0
11/21/2017 14:48:31	72946 - Dominion Faction Pack	Non-unique	Dominion Starship	Dominion	Jem'Hadar Battle Cruiser	Jem'Hadar Battle Cruiser				5	1	6	4		Battle Stations, Evasive, Scan, Target Lock	29	0	1	1	2	90-degree forward		0
11/21/2017 14:50:41	72945 - Romulan Faction Pack	Unique	Mirok's Science Vessel	Romulan	Romulan Science Vessel	Romulan Science Vessel				1	2	2	2	ACTION: Target a friendly ship within Range 1-2.  Repair 1 Shield or 1 Hull on the target ship.	Cloak, Evasive, Scan, Sensor Echo	10	0	1	1	0	90-degree forward		0
11/21/2017 14:51:38	72944 - Federation vs. Klingons Starter Set	Unique	U.S.S. Sutherland	Federation	Nebula Class	Nebula Class				4	1	4	4	WHEN DEFENDING:  Cancel 1 [HIT].	Battle Stations, Evasive, Scan, Target Lock	23	0	3	1	1	90-degree forward		0
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
