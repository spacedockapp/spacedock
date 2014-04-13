require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

script_path = Pathname.new(File.dirname(__FILE__))
root_path = script_path.parent()
src_path =  root_path.join("src")
xml_path = src_path.join("Data.xml").to_s
xml_text = File.read(xml_path)
doc = Nokogiri::XML(xml_text)

#	Name	Ship Type	Faction	Weapon	Agility	Hull	Shield	Ship Ability	Evasive Maneuvers	Target Lock	Scan	Battlestations	Cloak	Sensor Echo	Other	Tech	Weapon	Crew	Other	Cost	Set

ship = <<-SHIPTEXT
4/9/2014 11:55:09	Borg Sphere 4270	Borg Sphere	Unique	Borg	6	0	7	7	Each time you attack with your Primary Weapon, you may divide your attack between 2 different ships.  You may divide your attack dice however you like, but you must roll at least 1 die against each ship.	Regenerate, Scan, Target Lock	40	2	1	1	1
4/9/2014 11:55:09	Borg Sphere	Borg Sphere		Borg	6	0	7	6		Regenerate, Scan, Target Lock	38	1	1	1	1
4/13/2014 14:18:51	U.S.S. Voyager	Intrepid Class	Unique	Federation	4	2	4	5	Instead of making a normal attack with your Primary Weapon, you may fire in any direction at Range 1-2 with 4 attack dice. If you do so, place an Auxiliary Power Token beside your ship.	Battle Stations, Evasive, Scan, Target Lock	30	0	3	1	1
4/13/2014 14:18:51	Federation Starship	Intrepid Class		Federation	4	2	4	4		Battle Stations, Evasive, Scan, Target Lock	28	0	2	1	1
4/9/2014 11:44:59	Nistrim Raider	Kazon Raider	Unique	Kazon	2	2	3	3	When attacking an enemy ship with a Scan token next to it with your Primary Weapon, roll +2 attack dice.	Battle Stations, Evasive, Target Lock	20	0	2	1	1
4/9/2014 11:58:30	Kazon Raider	Kazon Raider		Kazon	2	2	3	2		Battle Stations, Evasive, Target Lock	18	0	1	1	1
4/9/2014 11:47:54	Bioship Alpha	Species 8472 Bioship	Unique	Species 8472	6	2	5	6	When you attack with your Primary Weapon, if you inflict at least 3 damage, place an Auxiliary Power Token beside the target ship.	Evasive, Regenerate, Scan, Target Lock	38	0	0	3	2
4/9/2014 11:47:54	Species 8472 Bioship	Species 8472 Bioship		Species 8472	6	2	5	5		Evasive, Regenerate, Scan, Target Lock	36	0	0	2	2
SHIPTEXT


convert_terms(ship)

new_ships = File.open("new_ships.xml", "w")

shipLines = ship.split "\n"
externalId = 5000
FACTION_LOOKUP = {
  "Fed" => "Federation",
  "Kli" => "Klingon",
  "Rom" => "Romulan",
  "Dom" => "Dominion",
}
shipLines.each do |l|
    parts = l.split "\t"
    title = parts[1]
    shipClass = parts[2]
    unique = parts[3] == "Unique" ? "Y" : "N"
    faction = parts[4]
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
    setId = case faction
    when "Species 8472"
      "71281"
    when "Federation"
      "71280"
    when "Borg"
      "71283"
    when "Kazon"
      "71282"
    end
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

