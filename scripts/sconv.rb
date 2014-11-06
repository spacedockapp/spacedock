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
      if kind == "straight"
        moves.push({:color => color, :speed => speed.to_i, :kind => kind, :column => 2})
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
11/4/2014 18:07:07	71512 - Assimilated Vessel 80279	Non-unique	Klingon/Borg Starship	Borg, Klingon	B'rel Class	B'rel Class				5	1	3	3		Cloak, Evasive, Sensor Echo, Target Lock	24	1	1	0	2	90-degree forward, 90-degree rear	
11/4/2014 18:08:05	71512 - Assimilated Vessel 80279	Non-unique	Klingon Starship	Klingon	B'rel Class	B'rel Class				4	1	3	2		Cloak, Evasive, Sensor Echo, Target Lock	20	0	1	0	2	90-degree forward, 90-degree rear	
11/4/2014 18:09:45	71512 - Assimilated Vessel 80279	Unique	Assimilated Vessel 80279	Borg, Klingon	B'rel Class	B'rel Class				5	1	3	4	When attacking, during the Modify Attack Dice step, you may spend 3 Drone Tokens to choose any number of your attack dice and re-roll them (even if they have already been re-rolled).	Cloak, Evasive, Sensor Echo, Target Lock	26	1	1	1	2	90-degree forward, 90-degree rear	
11/4/2014 18:11:04	71512 - Assimilated Vessel 80279	Unique	Korok's Bird-of-Prey	Klingon	B'rel Class	B'rel Class				4	1	3	3	When you initiate an attack at Range 1, while Cloaked, your opponent rolls -1 defense die.  You cannot deploy this card to the same fleet as "Assimilated Vessel 80279."	Cloak, Evasive, Sensor Echo, Target Lock	22	0	1	1	2	90-degree forward, 90-degree rear	
11/4/2014 18:14:31	71513a - Tactical Cube 001	Non-unique	Borg Starship	Borg	Borg Tactical Cube	Borg Tactical Cube				6	0	9	7		Regenerate, Scan, Target Lock	44	2	1	1	1	360-degree	
11/4/2014 18:16:07	71513a - Tactical Cube 001	Unique	Tactical Cube 001	Borg	Borg Tactical Cube	Borg Tactical Cube				6	0	9	8	When defending, during the Compare Results step, you may discard up to 3 of your [BORG] Upgrades.  Cancel 1 [HIT] or [CRIT] result for each Upgrade you discard with this card.	Regenerate, Scan, Target Lock	46	2	1	1	2	360-degree	
11/4/2014 18:19:20	71532 - Chang's Bird of Prey	Unique	Chang's Bird-of-Prey	Klingon	Klingon Bird-of-Prey		1 Forward, 2 Forward, 1 Bank, 2 Bank	3 Forward, 4 Forward, 2 Turn, 3 Bank	3 Turn, 3 Come About	4	1	3	3	If you attack with Torpedoes while Cloaked, you do not flip your [CLOAK] Token over to its red side.	Cloak, Evasive, Sensor Echo, Target Lock	22	0	1	1	2	90-degree forward, 90-degree rear	
11/4/2014 18:20:50	71529 - I.S.S. Defiant	Mirror Universe Unique	I.S.S. Defiant	Mirror Universe	Defiant Class (Mirror)		1 Forward, 2 Forward, 1 Bank	3 Forward, 4 Forward, 2 Bank, 3 Bank, 2 Turn	3 Turn, 3 Come About	4	2	3	3	Each time you suffer damage from an attack, you may place an Auxiliary Power Token beside your ship to reduce the amount of damage from that attack by 1.	Battle Stations, Evasive, Scan, Target Lock	24	0	2	0	2	90-degree forward, 90-degree rear	
11/4/2014 20:14:07	71533 - Scimitar	Unique	Scimitar	Romulan	Reman Warbird		1 Forward, 2 Forward, 1 Bank	3 Forward, 4 Forward, 5 Forward, 6 Forward, 2 Bank, 3 Bank, 3 Turn	4 Come About	6	2	7	4	After you attack while Cloaked, you may place an Auxiliary Power Token beside your ship to keep your [CLOAK] Token from flipping to its red side.	Cloak, Evasive, Sensor Echo, Target Lock	38	0	1	2	2	90-degree forward, 90-degree rear	
11/4/2014 20:57:31	71533 - Scimitar	Non-unique	Reman Starship	Romulan	Reman Warbird	Reman Warbird				6	2	7	3		Cloak, Evasive, Sensor Echo, Target Lock	36	0	1	1	2	90-degree forward, 90-degree rear	
11/4/2014 21:16:36	71532 - Chang's Bird of Prey	Non-unique	Klingon Starhip	Klingon	Klingon Bird-of-Prey	Klingon Bird-of-Prey				4	1	3	2		Cloak, Evasive, Sensor Echo, Target Lock	20	0	1	1	1	90-degree forward, 90-degree rear	
11/4/2014 21:38:58	71529 - I.S.S. Defiant	Non-unique	Mirror Universe Starship	Mirror Universe	Defiant Class (Mirror)	Defiant Class (Mirror)				4	2	3	2		Battle Stations, Evasive, Scan, Target Lock	22	0	1	0	2	90-degree forward, 90-degree rear	
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
