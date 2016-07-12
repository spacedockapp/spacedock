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
5/26/2016 14:06:09	72006 - Cube 384/Sphere 936	Non-unique	Borg Starship	Borg	Borg Cube	Borg Cube				6	0	10	9		Regenerate, Scan, Target Lock	50	1	1	1	2	360-degree		0
5/26/2016 14:07:28	72006 - Cube 384/Sphere 936	Non-unique	Borg Starship	Borg	Borg Sphere	Borg Sphere				6	0	7	6		Regenerate, Scan, Target Lock	38	1	1	1	1	360-degree		0
5/26/2016 14:08:58	72006 - Cube 384/Sphere 936	Unique	Sphere 936	Borg	Borg Sphere	Borg Sphere				6	0	7	7	If this ship is a support ship, you may equip 1 Upgrade (of your choice) at -2 SP to this ship and you may use a 1 [FORWARD], 2 [FORWARD] or a 3 [FORWARD] Maneuver Template to place it in the play area when it becomes Active.	Regenerate, Scan, Target Lock	40	2	1	1	1	360-degree		0
5/26/2016 14:10:42	72006 - Cube 384/Sphere 936	Unique	Cube 384	Borg	Borg Cube	Borg Cube				6	0	10	10	Your shields cannot be affected by Upgrades from an opponent's fleet.	Regenerate, Scan, Target Lock	52	2	1	1	2	360-degree		0
6/15/2016 17:04:47	72319g - USS Enterprise-A	Non-unique	Federation Starship	Federation	Constitution Class (Refit)	Constitution Class (Refit)				3	1	4	3		Battle Stations, Evasive, Scan, Target Lock	22	0	3	0	1	180-degree forward		0
6/15/2016 17:07:23	72319g - USS Enterprise-A	Unique	U.S.S. Enterprise-A	Federation	Constitution Class (Refit)	Constitution Class (Refit)				3	1	4	4	When attacking, during the Roll Attack Dice step, if there is a [SCAN] Token beside your ship, gain +1 attack die (+2 if the defending ship is Cloaked).	Battle Stations, Evasive, Scan, Target Lock	24	0	3	1	1	180-degree forward		0
6/17/2016 11:16:56	72319p - HMS Bounty	Non-unique	Klingon Starship	Klingon	B'rel Class	B'rel Class				4	1	3	2		Cloak, Evasive, Sensor Echo, Target Lock	20	0	2	0	1	90-degree forward, 90-degree rear		0
6/17/2016 11:18:24	72319p - HMS Bounty	Unique	H.M.S. Bounty	Federation	B'rel Class	B'rel Class				4	1	3	3	If there are only Federation cards assigned to this ship, add the [SCAN] and [BATTLE STATIONS] icons to the Action Bar.  This ship cannot be in the same fleet as Kruge's Bird-of-Prey.	Cloak, Evasive, Sensor Echo, Target Lock	22	0	4	0	1	90-degree forward, 90-degree rear		0
6/22/2016 23:28:49	72320p - USS Cairo	Unique	U.S.S. Cairo	Federation	Excelsior Class	Excelsior Class				3	1	5	4		Battle Stations, Evasive, Scan, Target Lock	26	0	2	1	2	180-degree forward, 90-degree rear		0
6/22/2016 23:31:53	72320p - USS Cairo	Non-unique	Federation Starship	Federation	Excelsior Class	Excelsior Class				3	1	5	3		Battle Stations, Evasive, Scan, Target Lock	24	0	2	1	1	180-degree forward, 90-degree rear		0
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
