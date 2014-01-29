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

#	Title	Ability	Skill	Talent	Attack	Range	Type	Faction	Cost	Qty	Set	errata	Role
upgrade = <<-UPGRADETEXT
*	Thot Pran	When Attacking with an Energy Dissipator, you may re-roll 1 of your blank results one time.	7	1			Captain	Dom	5	1	"OP 5 Prize"
*	Invaluable Advice	Before rolling your attack or defense dice, you may discard this card to place a [battle stations] Token beside your ship.					Talent	Dom	2	1	"OP 5 Prize"
	Breen Guards	Action: If your ship is not Cloaked, disable all your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields. Disable Breen Guards and discard one [crew] Upgrade of your choice on the target ship. 					Crew	Dom	5	1	"OP 5 Prize"
	Energy Dissipator	Attack: Disable this card to perform this attack. If this attack hits, the target suffers no damage, receives 1 Energy Dampening Token, and you may immediately attack the same ship again with another weapon. This upgrade cost +5 Squadron Points for any non-Breen ship. 					Weapon	Dom	5	1	"OP 5 Prize"
	Cold Storage Unit	Add 2 additional [weapon] icons to your ship's Upgrade Bar.					Crew	Dom	4	1	"OP 5 Prize"
*	Rudolph Ransom	When defending, if there is an [evade] token beside your ship, roll +2 defense dice.	4				Captain	Fed	2	1	"#71276 Equinox"
*	Maxwell Burke	Action: Discard this card to gain +2 attack dice this round.	2				Captain	Fed	1	1	"#71276 Equinox"
*	Marla Gilmore	Action: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Disable this card and 1 [tech] of your choice on the target ship.  You may then use that Upgrade's Action (if any) as a free action this round.					Crew	Fed	2	1	"#71276 Equinox"
*	Noah Lessing	Action: Disable this card and any 1 of your [tech] Upgrades to target a ship at Range 1-2. Disable 1 of the target ship's Active Shields.					Crew	Fed	2	1	"#71276 Equinox"
	Photon Torpedoes	Attack: (Target Lock) Spend your target lock and disable this card to perform this attack. You may convert 1 [BATTLESTATIONS] result into 1 [CRITICAL] result. You may fire this weapon from your forward or rear firing arcs. 			5	2-3	Weapon	Fed	5	1	"#71276 Equinox"
*	Emergency Medical Hologram	"This Upgrade counts as either a [crew] Upgrade or a [tech] Upgrade (your choice). When you use a [tech] Upgrade that requires you to disable it, you may disable this card instead of that [tech] Upgrade."					Tech	Fed	2	1	"#71276 Equinox"
	Navigational Deflector	"When taking damage, you may discard this card to cancel 1 [hit] result. If the damage is from a minefield or an obstacle, disable this card instead of discarding it. If you disable this card, you may roll defense dice against obstacles or minefields."					Tech	Fed	5	1	"#71276 Equinox"
*	Somraw Commander	Each time you attack at Range 3, if you do not have an Auxiliary Power Token beside your ship, you may add +1 attack die. If you add the attack die, place an Auxiliary Power Token beside your ship.	5	1			Captain	Kli	3	1	"#71448 Somraw"
*	Klingon Honor	"Action: Disable this card to add +1 attack die and convert 1 [hit] result into 1 [crit] result during any one attack you initiate this round. You cannot roll any defense dice this round. This Upgrade may only be purchased for a Klingon Captain."					Talent	Kli	5	1	"#71448 Somraw"
	Photon Torpedoes	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack. You may convert one (Battle Stations) result into 1 (Critical Hit) result. You may fire this weapon from your forward or rear firing arcs. 			5	2-3	Weapon	Kli	3	1	"#71448 Somraw"
*	Bu`Kah	If you performed a Green Maneuver this round, discard this card to repair up to 2 damage to your Hull.					Crew	Kli	4	1	"#71448 Somraw"
	Shockwave	"Instead of moving normally during the Activation Phase, you may discard this card and disable 1 of your Torpedoes to disregard your chosen Maneuver and perform a Red [1 reverse] Full Astern Maneuver instead. This upgrade may only be purchased for a Raptor Class ship."					Tech	Kli	2	1	"#71448 Somraw"
	Tactical Sensors	"Action: Disable this card to place a [battle stations] token and a [scan] Token beside your ship. This upgrade may only be purchased for a Raptor class ship."					Tech	Kli	4	1	"#71448 Somraw"
*	Romulan Commander	Action: During the Combat Phase this round, your ship attacks before every other ship. Place an Auxiliary Power Token beside your ship.	7	2			Captain	Rom	5	1	"#71278 Gal Gath'thong"
	Centurion	When one of your [crew] upgrades or your Captain is to be disabled or discarded, you may discard this card instead.					Crew	Rom	4	1	"#71278 Gal Gath'thong"
*	Romulan Officer	Action: Discard this card. If you initiate an attack while Cloaked this round, add +2 attack dice. You cannot roll any defense dice this round.					Crew	Rom	5	1	"#71278 Gal Gath'thong"
*	Decoy	When defending, before any dice are rolled, you may discard this card and any of your [weapon] or [tech] Upgrades to force your opponent to roll 3 less attack dice this round.					Talent	Rom	4	1	"#71278 Gal Gath'thong"
*	Double Back	After performing a [sensor echo] Action, you may discard this card to immediately perform a [reverse]1 or [reverse]2 Full Astern Maneuver.					Talent	Rom	5	1	"#71278 Gal Gath'thong"
	Plasma Torpedoes	Attack: (Target Lock) Spend your target lock and disable this card to perform this attack. You may re-roll all your blank results one time. You may fire this weapon from your forward or rear firing arcs. 			4	1-2	Weapon	Rom	3	1	"#71278 Gal Gath'thong"
	Nuclear Warhead	Action: At the end of the Activation Phase, discard this card and place a Minefield Token within Range 1 of your ship, but not within your forward firing arc and not on to of another ship. If a ship enters the minefield on a future turn, roll 3 attack dice. Any [hit] or [crit] damages the ship as normal. The affected ship does not roll any defense dice.					Weapon	Rom	3	1	"#71278 Gal Gath'thong"
*	Weyoun	Add up to 2 additional [crew] Upgrade slots to you ship's Upgrade Bar. The cost of these Upgrades is -1 SP each if they are Dominion [crew] Upgrades.	7	1			Captain	Dom	5	1	"#71279 4th Division"
*	Gelnon	Action: Target an enemy ship in your forward firing arc within Range 1 and immediately roll 2 attack dice. The target ship does not toll any defense dice against this attack and sustains damage as normal for each [hit] or [crit]. If you roll at least 1 [battle stations] result, place a [battle stations] Token beside your ship.	5				Captain	Dom	3	1	"#71279 4th Division"
*	Kudak'Etan	"Action: Target a ship at Range 1. Discard this card and disable 1 of your other [crew] Upgrades to disable all [crew] Upgrades on the target ship (even if that ships is Cloaked or has Active Shields). This Upgrade may only be purchased for a Jem'hadar ship."					Crew	Dom	4	1	"#71279 4th Division"
*	Ixtana'Rax	Action: Disable this card to flip over all Critical Damage cards assigned to your ship.					Crew	Dom	2	1	"#71279 4th Division"
*	Ikat'Ika	"When defending , you may discard this card to force one ship that attacks you this round to re-roll any number of their attack dice of your choice (once per die). This Upgrade costs +5 Squadron Points for any non-Jem'hadar ship."					Crew	Dom	5	1	"#71279 4th Division"
	Photon Torpedoes	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack. If fired from a Jem'Hadar Battleship add +2 attack dice.			5	2-3	Weapon	Dom	5	1	"#71279 4th Division"
*	Ketracel-White	Action: Discard this card to remove all Disabled Upgrade Tokens from all of your Dominion [crew] Upgrades.					Talent	Dom	2	1	"#71279 4th Division"
	Shroud	If one of your Dominion [crew] Upgrades is supposed to be discarded, discard this card instead.					Tech	Dom	1	1	"#71279 4th Division"
UPGRADETEXT

convert_terms(upgrade)

new_upgrades = File.open("new_upgrades.xml", "w")
new_captains = File.open("new_captains.xml", "w")

upgradeLines = upgrade.split "\n"
FACTION_LOOKUP = {
  "Fed" => "Federation",
  "Kli" => "Klingon",
  "Rom" => "Romulan",
  "Dom" => "Dominion",
}

def no_quotes(a)
    a.gsub("\"", "")
end

def parse_set(setId)
  setId = no_quotes(setId)
  if setId =~ /\#(\d+).*/
    return $1
  end
  return setId.gsub(" ", "").gsub("\"", "")
end

upgradeLines.each do |l|
    l = convert_line(l)
    #	Title	Ability	Skill	Talent	Attack	Range	Type	Faction	Cost	Qty	Set
    parts = l.split "\t"
    unique = parts.shift == "*" ? "Y" : "N"
    title = parts.shift
    ability = no_quotes(parts.shift)
    skill = parts.shift
    talent = parts.shift
    attack = parts.shift
    range = parts.shift
    upType = parts.shift
	element_name = "Upgrade"
	if upType == "Captain"
		element_name = "Captain"
	end
    faction = FACTION_LOOKUP[parts.shift]
    unless faction
      throw "Unknown faction #{faction}"
    end
    cost = parts.shift
    parts.shift
    setId = parse_set(parts.shift)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <#{element_name}>
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
    </#{element_name}>
    SHIPXML
    if upType == "Captain"
      new_captains.puts upgradeXml
    else
      new_upgrades.puts upgradeXml
    end
end

