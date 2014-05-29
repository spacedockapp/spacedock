require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

#Timestamp		Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots
ship = <<-SHIPTEXT
5/27/2014 20:13:14	Unique	S'Gorn	Independent	Gorn Raider	3	1	3	4	When attacking with your Primary Weapon, if you inflict at least 1 Critical Damage to the enemy ship's hull, that ship must also discard 1 [CREW] Upgrade (of its choice).	Battle Stations, Evasive, Scan, Target Lock	22	0	1	2	0
5/27/2014 20:13:47		Gorn Starship	Independent	Gorn Raider	3	1	3	3		Battle Stations, Evasive, Scan, Target Lock	20	0	1	1	0
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

