require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

#Timestamp		Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots
ship = <<-SHIPTEXT
6/30/2014 8:30:38	Unique	U.S.S. Enterprise	Federation	Constitution Class (Refit)	3	1	4	4	ACTION: Disable up to 2 of your Active Shields.  For each Shield you disabled with this Action, gain +1 attack die for all of your attacks with your Primary Weapon this round.	Battle Stations, Evasive, Scan, Target Lock	24	0	4	0	1										
6/30/2014 8:31:16		Federation Starship	Federation	Constitution Class (Refit)	3	1	4	3		Battle Stations, Evasive, Scan, Target Lock	22	0	3	0	1										
6/30/2014 8:50:30	Unique	Soong	Borg	Borg Type 03	6	1	7	5	After performing a 5 [STRAIGHT] Maneuver, if there are no enemy ships in your forward firing arc, you may perform an [EVASIVE MANEUVERS] Action as a free Action.	Evasive, Scan, Target Lock	38	1	2	1	1										
6/30/2014 8:51:05		Borg Starship	Borg	Borg Type 03	6	1	7	4		Evasive, Scan, Target Lock	36	1	1	1	1										
6/30/2014 9:08:42	Unique	2nd Division Cruiser	Dominion	Jem'Hadar Battle Cruiser	5	1	6	5	Each time you defend, if you are within Range 1-2 of at least one friendly Jem'Hadar Attack Ship, roll 1 extra defense die.	Battle Stations, Evasive, Scan, Target Lock	34	0	2	1	2										
6/30/2014 9:09:36		Dominion Starship	Dominion	Jem'Hadar Battle Cruiser	5	1	6	4		Battle Stations, Evasive, Scan, Target Lock	32	0	1	1	2
SHIPTEXT


convert_terms(ship)

new_ships = File.open("new_ships.xml", "w")

shipLines = ship.split "\n"
shipLines.each do |l|
    parts = l.split "\t"
    title = parts[2]
    shipClass = parts[4]
    unique = parts[1] == "Unique" ? "Y" : "N"
    faction = parts[3]
    unless faction
      throw "Fo"
    end
    attack = parts[5]
    agility = parts[6]
    hull = parts[7]
    shield = parts[8]
    ability = parts[9]
    action_bar = parts[10].split(/,\s*/)
    evasiveManeuvers = action_bar.include?("Evasive") ? 1 : 0
    battleStations = action_bar.include?("Battle Stations") ? 1 : 0
    cloak = action_bar.include?("Cloak") ? 1 : 0
    sensorEcho = action_bar.include?("Sensor Echo") ? 1 : 0
    targetLock = action_bar.include?("Target Lock") ? 1 : 0
    scan = action_bar.include?("Scan") ? 1 : 0
    regenerate = action_bar.include?("Regenerate") ? 1 : 0
    cost = parts[11]
    borg = parts[12]
    crew = parts[13]
    tech = parts[14]
    weapon = parts[15]
    setId = set_id_from_faction(faction)
    externalId = make_external_id(setId, title)
	if cost.length == 0
		cost = (agility.to_i + attack.to_i + hull.to_i + shield.to_i) * 2
	end
    shipXml = <<-SHIPXML
    <Ship>
      <Title>#{title}</Title>
      <Unique>#{unique}</Unique>
      <ShipClass>#{shipClass}</ShipClass>
      <Faction>#{faction}</Faction>
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
      <Id>#{externalId}</Id>
      <Set>#{setId}</Set>
    </Ship>
    SHIPXML
    new_ships.puts shipXml
    end

