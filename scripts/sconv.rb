require "enumerator"
require "nokogiri"
require "pathname"

script_path = Pathname.new(File.dirname(__FILE__))
root_path = script_path.parent()
src_path =  root_path.join("src")
xml_path = src_path.join("Data.xml").to_s
xml_text = File.read(xml_path)
doc = Nokogiri::XML(xml_text)

ships = doc.xpath("//Data//Ships/Ship/Id").collect do |node|
  node.content
end

v = ships.sort.last.to_i 
v+= 1


#	Name	Ship Type	Faction	Weapon	Agility	Hull	Shield	Ship Ability	Evasive Maneuvers	Target Lock	Scan	Battlestations	Cloak	Sensor Echo	Other	Tech	Weapon	Crew	Other	Cost	Set

ship = <<-SHIPTEXT
*	U.S.S. Excelsior	Excelsior	Fed	3	1	5	4	After you move, if no enemy ships are within Range 1 of your ship, you may perform a (scan) action as a free action.	1	1	1	1				1	1	3		26	#71272
	Federation Starship	Excelsior	Fed	2	1	5	3		1	1	1	1				1	1	2		24	#71272
*	R.I.S. Vo	Romulan Scout Vessel	Rom	1	3	2	2	After you move, you may perform an (evade) action as a free action. If you do so, you cannot attack during this round.	1		1		1	1		1		1		16	#71274
	Romulan Starship	Romulan Scout Vessel	Rom	1	3	2	1		1		1		1	1		1				14	#71274
*	U.S.S. Sutherland	Nebula	Fed	4	1	4	4	When you initiate an attack at range 3, you may choose any number of your attack dice and re-roll them once.	1	1	1	1				1	2	2		26	OP 4 Prize
	Federation Starship	Nebula	Fed	4	1	4	4		1	1	1	1				1	1	2		24	OP 4 Prize
SHIPTEXT

new_ships = File.open("new_ships.xml", "w")

shipLines = ship.split "\n"
new_ships.puts %Q(<Ships>)
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
    externalId = v
    v+=1
    setId = parts[21].gsub "#", ""
    setId = setId.gsub " ", ""
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
new_ships.puts %Q(</Ships>)

