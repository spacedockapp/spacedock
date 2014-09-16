require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

#Timestamp		Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots
ship = <<-SHIPTEXT
9/15/2014 21:13:29	Unique	Bok's Marauder	Ferengi	D'kora Class	3	1	4	3	If you performed a Maneuver of 3 or higher this round, during the Roll Attack Dice step of the Combat Phase, you may add +1 attack die.  If you do so, place an Auxiliary Power Token beside your ship.	Evasive, Scan, Target Lock	22	0	1	1	2	71646a - Bok's Marauder	D'kora Class										
9/15/2014 21:14:08	Non-unique	Ferengi Starship	Ferengi	D'kora Class	3	1	4	2		Evasive, Scan, Target Lock	20	0	1	1	1	71646a - Bok's Marauder	D'kora Class										
9/15/2014 21:23:03	Non-unique	Mirror Universe Starship	Mirror Universe	Cardassian Galor Class	4	1	4	3		Evasive, Scan, Target Lock	24	0	1	1	1	71646b - Prakesh	Cardassian Galor Class										
9/15/2014 21:22:17	Mirror Universe Unique	Prakesh	Mirror Universe	Cardassian Galor Class	4	1	4	4	After you move, if you are within Range 1 of a friendly ship, you may immediately perform one of the Actions listed on your Action Bar as a free Action.	Evasive, Scan, Target Lock	26	0	1	1	2	71646b - Prakesh	Cardassian Galor Class										
9/15/2014 21:33:17	Non-unique	Kazon Starship	Kazon	Predator Class	4	1	5	2		Battle Stations, Evasive, Scan, Target Lock	24	0	1	1	2	71646c - Relora-Sankur	D'Kyr Class										
9/15/2014 21:32:11	Unique	Relora-Sankur	Kazon	Predator Class	4	1	5	3	If you performed a Green Maneuver this round, during the Roll Attack Dice step of the Combat Phase, roll +1 attack die.	Battle Stations, Evasive, Scan, Target Lock	26	0	2	1	2	71646c - Relora-Sankur	D'Kyr Class										
9/15/2014 21:24:04	Non-unique	Borg Starship	Borg	Borg Scout Cube	3	3	2	3	You cannot deploy a [BORG] Upgrade with a cost greater than 5 to this ship.	Evasive, Regenerate, Scan, Target Lock	22	1	1	1	0	71646d - Scout 255	Borg Scout Cube										
9/15/2014 21:13:55	Unique	Scout 255	Borg	Borg Scout Cube	3	3	2	4	If there is a [SCAN] Token beside your ship during the Modify Defense Dice step of the Combat Phase, roll +1 defense die. You cannot deploy a [BORG] Upgrade with a cost greater than 5 to this ship.	Evasive, Regenerate, Scan, Target Lock	24	1	1	1	1	71646d - Scout 255	Borg Scout Cube										
9/15/2014 21:40:52	Unique	Tal'Kir	Vulcan	D'Kyr Class	3	1	5	4	Each time you defend, during the Modify Defense Dice step of the Combat Phase, you may add 1 [EVADE] result to your roll.  If you do so, place 1 Auxiliary Power Token beside your ship.	Battle Stations, Evasive, Scan, Target Lock	26	0	2	1	1	71646e - Tal'Kir	D'Kyr Class										
9/15/2014 21:41:30	Non-unique	Vulcan Starship	Vulcan	D'Kyr Class	3	1	5	3		Battle Stations, Evasive, Scan, Target Lock	24	0	1	1	1	71646e - Tal'Kir	D'Kyr Class										
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

