require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

#Timestamp		Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots
ship = <<-SHIPTEXT
8/18/2019/9/2014 10:02:36	Unique	U.S.S. Stargazer	Federation	Constellation Class	3	1	4	3	During the Activation Phase, you may disable 1 of your Active Shields to remove 1 Auxiliary Power Token from beside your ship.	Battle Stations, Evasive, Scan, Target Lock	22	0	1	1	1	71510 -  U.S.S. Stargazer	Nova Class										
9/9/2014 10:03:29	Non-unique	Federation Starship	Federation	Constellation Class	3	1	4	2		Battle Stations, Evasive, Scan, Target Lock	20	0	1	0	1	71510 -  U.S.S. Stargazer	Nova Class										
9/9/2014 10:05:47	Mirror Universe Unique	U.S.S. Enterprise-D	Mirror Universe	Galaxy Class	5	1	5	3	During the Roll Attack Dice step of the Combat Phase, you may disable 1 of your Active Shields to gain +1 attack die.	Battle Stations, Evasive, Scan, Target Lock	28	0	2	0	3	71510b - Assimilation Target Prime											
9/9/2014 10:06:40	Non-unique	Mirror Universe Starship	Mirror Universe	Galaxy Class	5	1	5	2		Battle Stations, Evasive, Scan, Target Lock	26	0	1	0	3	71510b - Assimilation Target Prime											
9/9/2014 10:08:11	Mirror Universe Unique	Assimilation Target Prime	Borg, Mirror Universe	Galaxy Class	5	1	5	4	ACTION: Spend 1 Drone Token to repair 1 damage to your Hull or Shields.	Evasive, Regenerate, Scan, Target Lock	30	1	1	1	2	71510b - Assimilation Target Prime											
9/9/2014 10:09:03	Non-unique	Mirror Universe/Borg Starship	Borg, Mirror Universe	Galaxy Class	5	1	5	3		Evasive, Regenerate, Scan, Target Lock	28	1	1	1	1	71510b - Assimilation Target Prime											
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
    mirrorUniverseUnique = parts[1] == "Mirror Universe Unique" ? "Y" : "N"
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
      <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
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

