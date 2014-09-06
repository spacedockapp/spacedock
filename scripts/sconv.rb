require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

#Timestamp		Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots
ship = <<-SHIPTEXT
8/18/2014 17:02:28	Unique	Enterprise NX-01	Federation	Federation NX Class	2	3	3	0	You may equip the Enhanced Hull Plating [TECH] Upgrade to your ship for free even if it exceeds your ship's restrictions.	Battle Stations, Evasive, Scan, Target Lock	16	0	3	0	1	71526 - Enterprise											
8/18/2014 17:45:57	Unique	Ni'Var	Vulcan	Suurok Class	2	1	4	3	Whenever you attack an enemy ship at Range 3 with your Primary Weapon, if there is a [SCAN] Token beside your ship, you gain +1 attack die for that attack.	Battle Stations, Evasive, Scan, Target Lock	20	0	2	1	0	71527 - Ni’Var											
8/18/2014 18:12:39	Unique	Scout 608	Borg	Borg Scout Cube	3	3	2	4	After you move, you may discard one of your Upgrades to perform an additional Green or White Maneuver.  You cannot deploy a [BORG] Upgrade with a cost greater than 5 to this ship.	Evasive, Regenerate, Scan, Target Lock	24	1	1	1	1	71525 - Scout Cube											
8/18/2014 17:02:28		Federation Starship	Federation	Federation NX Class	2	3	3	0		Battle Stations, Evasive, Scan, Target Lock	16	0	1	0	1	71526 - Enterprise											
8/18/2014 17:45:57		Vulcan Starship	Vulcan	Suurok Class	2	1	4	2		Battle Stations, Evasive, Scan, Target Lock	18	0	1	1	0	71527 - Ni’Var											
8/18/2014 18:12:39		Borg Starship	Borg	Borg Scout Cube	3	3	2	3	You cannot deploy a [BORG] Upgrade with a cost greater than 5 to this ship.	Evasive, Regenerate, Scan, Target Lock	22	1	1	1		71525 - Scout Cube											
SHIPTEXT


convert_terms(ship)

new_ships = File.open("new_ships.xml", "w")

shipLines = ship.split "\n"
shipLines.each do |l|
# Timestamp		Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots	Expansion Pack	Maneuver Grid										*
    parts = l.split "\t"
    title = parts[2]
    shipClass = parts[4]
    unique = parts[1] == "Unique" ? "Y" : "N"
    faction = parts[3]
    unless faction
      throw "Faction missing"
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
    expansion = parts[16]
    setId = set_id_from_expansion(expansion)
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

