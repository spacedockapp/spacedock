require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

#Timestamp		Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots
ship = <<-SHIPTEXT
6/9/2014 15:55:35	Unique	I.K.S. B'Moth	Klingon	K'T'Inga Class	4	1	4	3	You can perform a Red Maneuver while there is an Auxiliary Power Token beside your ship.	Cloak, Evasive, Sensor Echo, Target Lock	24	0	1	1	2
6/9/2014 15:56:07		K'T'Inga Class	Klingon	K'T'Inga Class	4	1	4	2		Cloak, Evasive, Sensor Echo, Target Lock	22	0	1	1	1
6/9/2014 16:06:48	Unique	Gavroche	Independent	Maquis Raider	2	3	3	3	ACTION: Disable up to 2 of your [CREW] Upgrades and add +1 attack die to each of your attacks this round for each [CREW] Upgrade you disabled with this Action.	Battle Stations, Evasive, Scan, Target Lock	22	0	2	0	1
6/9/2014 16:06:57	Unique	I.R.W. Vorta Vor	Romulan	Romulan Bird of Prey Class	2	2	3	2	While you are Cloaked, after you perform a Green Maneuver, you may perform a [SENSOR ECHO] Action as a free Action.	Cloak, Evasive, Sensor Echo, Target Lock	18	0	1	1	2
6/9/2014 16:07:59		Romulan Bird of Prey Class	Romulan	Romulan Bird of Prey Class	2	2	3	1		Cloak, Evasive, Sensor Echo, Target Lock	16	0	1	1	1
6/9/2014 16:21:03	Unique	3rd Wing Attack Ship	Dominion	Jem'Hadar Attack Ship	3	2	3	3	When attacking with your Primary Weapon, during the Roll Attack Dice step of the Combat Phase you may disable one of your [CREW] Upgrades to add +1 attack die to your attack.	Battle Stations, Evasive, Scan, Target Lock	22	0	2	1	1
6/9/2014 16:22:05		Jem'Hadar Attack Ship	Dominion	Jem'Hadar Attack Ship	3	2	3	2		Battle Stations, Evasive, Scan, Target Lock	20	0	1	1	1
6/9/2014 16:25:01	Unique	U.S.S. Yaeger	Federation	Saber Class	3	2	3	3	When attacking with Photon Torpedoes, you do not need to disable the Photon Torpedoes.	Battle Stations, Evasive, Scan, Target Lock	22	0	2	0	2
6/9/2014 16:29:16		Federation Starship	Federation	Saber Class	3	2	3	2		Battle Stations, Evasive, Scan, Target Lock	20	0	1	0	2
6/9/2014 16:39:17		Maquis Starship	Independent	Maquis Raider	2	3	3	2		Battle Stations, Evasive, Scan, Target Lock	20	0	1	0	1
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

