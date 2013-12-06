require "enumerator"
require "nokogiri"
require "pathname"

script_path = Pathname.new(File.dirname(__FILE__))
root_path = script_path.parent()
src_path =  root_path.join("src")
xml_path = src_path.join("Data.xml").to_s
xml_text = File.read(xml_path)
doc = Nokogiri::XML(xml_text)

upgrades = doc.xpath("//Data//Upgrades/Upgrade/Id").collect do |node|
  node.content
end

v = upgrades.sort.last.to_i 
v+= 1

existingUpgrades = {}
doc.xpath("//Data//Upgrades/Upgrade").each do |upNode|
  title = upNode.xpath("Title").first.content.to_s
  setId = upNode.xpath("Set").first.content.to_s
  existingUpgrades[title] = setId
end

puts "existingUpgrades = #{existingUpgrades}"

#	Title	Ability	Skill	Talent	Attack	Range	Type	Faction	Cost	Qty	Set	errata	Role
upgrade = <<-UPGRADETEXT
*	Hikaru Sulu	Action: Disable one of your (crew) upgrades to remove an opponent's (target lock) token from your ship. Remove the corresponding token from the opponent's ship as well.	6	1			Captain	Fed	4	1	#71272 Excelsior
*	Styles	Add 1 additional (tech) icon to your ship's upgrade bar.	3				Captain	Fed	2	1	#71272 Excelsior
*	Feint	Action: Discard this upgrade to target a ship at range 2-3. If you attack that ship this round, it rolls 2 less defense dice.					Talent	Fed	4	1	#71272 Excelsior
*	Dmitri Valtane	If your ship has a (scan) token beside it when you attack, you may re-roll up to 2 of your attack dice.					Crew	Fed	3	1	#71272 Excelsior
*	Janice Rand	After your ship moves, discard Rand to allow your captain to perform the action on one of his (talent) upgrades as a free action this round.					Crew	Fed	2	1	#71272 Excelsior
*	Lojur	When your ship fires a (weapon) upgrade that requires you to disable it, you may disable Lojur instead of that (weapon) upgrade.					Crew	Fed	2	1	#71272 Excelsior
	Photon Torpedoes	Attack: (Target Lock) Spend your target lock and disable this card to perform this attack. You may convert one (Battle Stations) result into 1 (Critical Hit) result. You may fire this weapon from your forward or rear firing arcs. 			4	2-3	Weapon	Fed	3	1	#71272 Excelsior
	Positron Beam	During the planning phase, you may discard this upgrade to target a ship at range 1 of your ship. That ship immediately receive an auxiliary  power token.					Tech	Fed	2	1	#71272 Excelsior
	Transwarp Drive	During the activation phase, if your maneuver dial reveals a (straight) 4 or (straight) 5 maneuver, you may instead use a (straight) 6 maneuver.					Tech	Fed	3	1	#71272 Excelsior
*	Worf	When attacking, you may re-roll all of your blank results one time. 	5				Captain	Kli	3	1	#71273 Koraga
*	Kurn	Action: When attacking this round, gain +1 attack die. Place an Auxiliary Power Token beside your ship. 	3				Captain	Kli	2	1	#71273 Koraga
*	N'Garen	Action: When attacking this round, you may convert 1 of your [Battle Station] results into a [Critical] and all of your other [Battle Station] results into [Hit] results. 					Crew	Kli	4	1	#71273 Koraga
*	Alexander	Each time your ship is hit for at least 1 damage, place 1 [Battle Station] token on this card. During an Activation Phase, you may take 1 [Battle Station] token off this card and place it beside your ship. 					Crew	Kli	3	1	#71273 Koraga
	Photon Torpedoes	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack. You may convert one (Battle Stations) result into 1 (Critical Hit) result. You may fire this weapon from your forward or rear firing arcs. 			5	2-3	Weapon	Kli	5	1	#71273 Koraga
	Advanced Weapon System	When attacking, you may disable this card before rolling any dice to keep your [CLOAK] token from flipping to its red side. 					Tech	Kli	5	1	#71273 Koraga
	EM Pulse	Action: Disable this card to target a ship at Range 1-2. The targeted ship rolls 1 less attack die and 1 less defense die this round. 					Tech	Kli	4	1	#71273 Koraga
*	Alidar Jarok	Action: Discard your (talent) upgrade to target 1 ship at range 1-2. Neither of your ships may attack each other this round.	7	1			Captain	Rom	4	1	#71274 Vo
*	Massacre	If your ship inflicts a [Critical] agaisnt an enemy's Hull, discard this card to inflict 1 additional damage to that ship. 					Talent	Rom	3	1	#71274 Vo
*	Selok	Action: Discard Selok to target a ship at Range 1. That ship cannot attack your ship this round. 					Crew	Rom	5	1	#71274 Vo
	Ultritium Explosives	Action: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields. Discard this card and 1 of your [Crew] Upgrades to inflict 1 [Critical] against the target ship. 					Tech	Rom	2	1	#71274 Vo
*	Gul Dukat	Your ship may perform an [Evade] or a [Battle Stations] Action as a free Action each round. 	7	1			Captain	Dom	5	1	#71275 Koranak
*	Gul Evek	Each time you defend, you may re-roll all of your blank results one time. 	4				Captain	Dom	2	1	#71275 Koranak
*	Captured Intelligence	Before rolling your defense dice, if you do not have an [Evade] Token beside your ship, you may discard this card to place an [Evade] Token beside your ship. In addition, each time you defend during the round use this ability, roll 1 extra defense die. 					Talent	Dom	3	1	#71275 Koranak
*	Boheeka	If your ship has a [Battle Stations] Token beside it when you attack, you may convert 1 blank result into a [Hit] result. 					Crew	Dom	2	1	#71275 Koranak
	Dorsal Weapons Array	Attack: Disable this card to perform this attack. You may fire this weapon in any direction.			3	1-3	Weapon	Dom	3	1	#71275 Koranak
	Enhanced Weaponry	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack. If fired from a Keldon class ship add +1 attack die.			5	2-3	Weapon	Dom	5	1	#71275 Koranak
	Cloaking Device	Instead of performing a normal Action, you may disable this card to perform a [Cloak] Action. While you have a [Cloak] token beside your ship you may perform a [Sensor Echo] Action even if this card is disabled. This Upgrade costs +5 Squadron Points for any non-Keldon Class ship. 					Tech	Dom	4	1	#71275 Koranak
	Tetryon Emissions	Action: Disable this Upgrade to add +3 defense dice this round. 					Tech	Dom	3	1	#71275 Koranak
*	Data	Action: Disable one of your crew upgrades and one of your weapon upgrades to target all cloaked ship at range 1-3. They immediately flip their cloak tokens to the red side. 	4	1			Captain	Fed	2	1	"OP 4 Prize"
*	Disobey Orders	You may discard this card at any time to replace 1 [evade][scan] or [battlestations] token next to your ship with a [evade][scan] or [battlestations] token. 					Talent	Fed	3	1	"OP 4 Prize"
*	Christopher Hobson	Action: Gain +1 attack die when firing at a cloaked ship. 					Crew	Fed	4	1	"OP 4 Prize"
	Secondary Torpedo Launcher	Attack: (Target Lock) Discard this card and spend your target lock to perform this attack. If you have already fired another torpedo at an enemy ship in your forward firing arc this round, you may use this weapon to make a second attack against that ship at -1 attack die. you do not need to spend a second target lock to make the extra attack.			4	2-3	Weapon	Fed	4	1	"OP 4 Prize"
	High Energy Sensor Sweep	After you move, you may disable 1 active shield to perform a free [Scan] Action.					Tech	Fed	5	1	"OP 4 Prize"
UPGRADETEXT

upgrade.gsub! /\[evade\]/i, "[EVADE]"
upgrade.gsub! /\[cloak\]/i, "[CLOAK]"
upgrade.gsub! /\[Sensor Echo\]/i, "[SENSOR ECHO]"
upgrade.gsub! /\[scan\]/i, "[SCAN]"
upgrade.gsub! /\[critical\]/i, "[CRITICAL]"
upgrade.gsub! /\[Hit\]/i, "[HIT]"
upgrade.gsub! /\[crew\]/i, "[CREW]"
upgrade.gsub! /\[Battle *Stations*\]/i, "[BATTLESTATIONS]"
upgrade.gsub! /\(Battle *Stations*\)/i, "[BATTLESTATIONS]"
upgrade.gsub! /\(Target Lock\)/i, "[TARGET LOCK]"
upgrade.gsub! /\(Critical Hit\)/i, "[CRITICAL]"
upgrade.gsub! /\(talent\)/i, "[TALENT]"
upgrade.gsub! /\(tech\)/i, "[TECH]"
upgrade.gsub! /\(weapon\)/i, "[WEAPON]"
upgrade.gsub! /\(scan\)/i, "[SCAN]"
upgrade.gsub! /\(straight\)/i, "[STRAIGHT]"

new_upgrades = File.open("new_upgrades.xml", "w")

upgradeLines = upgrade.split "\n"
new_upgrades.puts %Q(<Upgrades>)
externalId = 5000
FACTION_LOOKUP = {
  "Fed" => "Federation",
  "Kli" => "Klingon",
  "Rom" => "Romulan",
  "Dom" => "Dominion",
}

def parse_set(setId)
  if setId =~ /#\d+/
    parts = setId.split " "
    s = parts.shift
    return s.gsub "#", ""
  end
  return setId.gsub(" ", "").gsub("\"", "")
end

upgradeLines.each do |l|
    l = l.gsub "[EVADE]", "[EVADE]"
    #	Title	Ability	Skill	Talent	Attack	Range	Type	Faction	Cost	Qty	Set
    parts = l.split "\t"
    unique = parts.shift == "*" ? "Y" : "N"
    title = parts.shift
    ability = parts.shift
    skill = parts.shift
    talent = parts.shift
    attack = parts.shift
    range = parts.shift
    upType = parts.shift
    faction = FACTION_LOOKUP[parts.shift]
    unless faction
      throw "Unknown faction #{faction}"
    end
    cost = parts.shift
    parts.shift
    setId = parse_set(parts.shift)
    externalId = v
    v+=1
    upgradeXml = <<-SHIPXML
    <Upgrade>
      <Title>#{title}</Title>
      <Ability>#{ability}</Ability>
      <Unique>#{unique}</Unique>
      <Skill>#{skill}</Skill>
      <Talent>#{talent}</Talent>
      <Attack>#{attack}</Attack>
      <Range>#{range}</Range>
      <Type>#{upType}</Type>
      <Faction>#{faction}</Faction>
      <Cost>#{cost}</Cost>
      <Id>#{externalId}</Id>
      <Set>#{setId}</Set>
      <Special></Special>
    </Upgrade>
    SHIPXML
    existingSetId = existingUpgrades[title]
    if existingSetId == setId
      puts "Title exists #{title}"
    else
      new_upgrades.puts upgradeXml
    end
end
new_upgrades.puts %Q(</Upgrades>)

