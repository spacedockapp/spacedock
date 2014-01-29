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
*	Rav Laerst	Breen Battle Cruiser	Dom	3	2	4	4	Action: Perform a [sensor echo] Action even if this ship is not Cloaked. You may only use the 1 [straight] Maneuver Template for this Action.	1	1	1					1	3	1		26	"OP 5 Prize"
	Dominion Starship	Breen Battle Cruiser	Dom	3	2	4	3		1	1	1					1	2	1		24	"OP 5 Prize"
*	U.S.S. Equinox	Nova Class	Fed	2	2	3	3	Action: Disable 1 of your Active Shields. During the End Phase this round, repair all of your damaged Shields.	1	1	1	1				1	1	2			#71276
	Federation Starship	Nova Class	Fed	2	2	3	2		1	1	1	1				1	1	1			#71276
*	I.K.S. Somraw	Raptor Class	Kli	3	1	3	2	Each time you defend, you may convert up to 2 of your [battle stations] results into [evade] results.	1	1	1					1	1	1			#71448
	Klingon Starship	Raptor Class	Kli	3	1	3	1		1	1	1					1	1				#71448
*	I.R.W. Gal Gath`thong	Bird of Prey	Rom	2	2	3	2	When initiating an attack while Cloaked, you may fire Plasma Torpedoes without needing a Target Lock.	1	1			1	1			2	2			#71278
	Romulan Starship	Bird of Prey	Rom	2	2	3	1		1	1			1	1			2	1			#71278
*	4th Division Battleship	Jem'Hadar Battleship	Dom	6	0	7	5	Each round, one other friendly Jem'Hadar ship within Range 1-2 of your ship may perform an Action on their Action Bar as a free Action.		1	1	1				1	3	2			#71279
	Dominion Starship	Jem'Hadar Battleship	Dom	6	0	7	4			1	1	1				1	2	2			#71279
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
    unique = parts[0] == "*" ? "Y" : "N"
    faction = FACTION_LOOKUP[parts[3]]
    unless faction
      throw "Fo"
    end
    attack = parts[4]
    agility = parts[5]
    hull = parts[6]
    shield = parts[7]
    ability = parts[8]
    cost = parts[20]
    evasiveManeuvers = parts[9]
    targetLock = parts[10]
    scan = parts[11]
    battleStations = parts[12]
    cloak = parts[13]
    sensorEcho = parts[14]
    tech = parts[16]
    weapon = parts[17]
    crew = parts[18]
    setId = parts[21].gsub "#", ""
    setId = setId.gsub " ", ""
    setId = setId.gsub "\"", ""
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
      <Tech>#{tech}</Tech>
      <Weapon>#{weapon}</Weapon>
      <Crew>#{crew}</Crew>
      <Id>#{externalId}</Id>
      <Set>#{setId}</Set>
    </Ship>
    SHIPXML
    new_ships.puts shipXml
    end

