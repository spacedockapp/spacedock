require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
10/26/2015 14:26:20	72017 - USS Hathaway	Non-unique	Navigational Station	Federation	After you perform a green maneuver, you may disable this card to immediately perform an [EVADE] Action as a free Action.  No ship may be equipped with more than one "Navigational Station" Upgrade.	Tech	4	Yes
10/26/2015 14:27:45	72017 - USS Hathaway	Non-unique	Warp Jump	Federation	At the start of the Combat Phase, before any attacks have been made, you may discard this card to remove your ship from the play area.  At the end of the Combat Phase, after all other ships have attacked, place your ship anywhere in the play area, but not within Range 1-3 of any other ship.  All Tokens that were beside your ship are removed.  You cannot attack during the round in which you use this ability.	Tech	5	
10/26/2015 14:28:45	72017 - USS Hathaway	Unique	Improvise	Federation	During the Combat Phase, when attacking or defending, you may disable this card and any number of your other Upgrades to re-roll a number of your attack or defense dice equal to the number of Upgrades you disabled with this ability (not including this card).	Talent	5	
10/26/2015 14:30:14	72017 - USS Hathaway	Unique	Wesley Crusher	Federation	At the start of the game, place up to 3 Federation [TECH] Upgrades, each 4 SP or less, face down under this card.  During the Activation Phase, you may discard this card to flip one of those Upgrades face up and deploy it to your ship, even if it exceeds your ship's restrictions.  If you do so, remove the other 2 face down Upgrades from the game and place an Auxiliary Power Token beside your ship.	Crew	5	Yes
10/26/2015 14:31:40	72017 - USS Hathaway	Unique	Worf	Federation	When defending, you may disable this card.  If you do so, the attacking ship rolls 1 fewer attack die and cannot spend [BATTLE STATIONS] or [TARGET LOCK] Tokens to modify its attack roll and your ship may roll it's full defense dice in spite of the presence of any [SCAN] Tokens beside the attacking ship.	Crew	5	
10/26/2015 14:32:36	72017 - USS Hathaway	Unique	Geordi La Forge	Federation	All of your [TECH] Upgrades cost -1 SP.  When defending, during the Roll Defense Dice step, you may disable this card to roll 1 additional defense die for each [TECH] Upgrade deployed to your ship (+2 max).	Crew	5	Yes
10/29/2015 14:11:40	72018 - Halik Raider	Unique	Lorrum	Kazon	When attacking with your Primary Weapon, during the Roll Attack Dice step, instead of rolling your normal number of attack dice, you may discard this card to roll a number of attack dice equal to the SP cost of one Upgrade on the target ship (max 4 dice).	Crew	4	
10/29/2015 14:12:49	72018 - Halik Raider	Non-unique	Kazon Guard	Kazon	During the Activation Phase, you may discard this card to place an [EVADE] Token beside your ship, even if there is already one there.  If you do so, place an Auxiliary Power Token beside your ship.  No ship may be equipped with more than one "Kazon Guard" Upgrade.	Crew	4	Yes
10/29/2015 14:14:43	72018 - Halik Raider	Non-unique	Unremarkable Species	Kazon	This Upgrade does not require an Upgrade slot and may not be deployed to a Borg ship.  While this Upgrade is equipped to your ship, your Kazon Upgrades cannot be targeted by the Borg Assimilation Tubules Upgrade.  In addition, when defending against a Borg ship, during the Roll Defense Dice step, roll +2 defense dice.  This Upgrade costs +5 SP if purchased for a non-Kazon ship and no ship may be equipped with more than 1 "Unremarkable Species" Upgrade.	?	5	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
10/26/2015 14:22:23	72017 - USS Hathaway	Non-unique	Federation	1	Federation		0	0		
10/26/2015 14:23:14	72017 - USS Hathaway	Unique	William T. Riker	7	Federation	When attacking a ship with a larger Hull value than your ship, you gain +1 attack die.  When defending against a ship with a larger Hull value than your ship, you roll +1 defense die.	1	4		
10/29/2015 14:09:12	72018 - Halik Raider	Non-unique	Kazon	1	Kazon		0	0		
10/29/2015 14:10:09	72018 - Halik Raider	Unique	Surat	5	Kazon	ACTION: Place a [SCAN] Token beside your ship.  If you do not have a [TECH] Upgrade deployed to your ship, place the Auxiliary Power Token beside your ship as well.	0	3		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
10/26/2015 14:24:50	72017 - USS Hathaway	Non-unique	Photon Torpedoes	Federation	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
10/29/2015 14:16:14	72018 - Halik Raider	Non-unique	Variable Yield Charges	Kazon			When attacking with one of your "Photonic Charges" Upgrades, during the Roll Attack Dice step, you may disable this card to gain +1 attack die for that attack.  If you do so, place an Auxiliary Power Token beside your ship.	2	
10/29/2015 14:17:24	72018 - Halik Raider	Non-unique	Photonic Charges	Kazon	3	1-2	ATTACK: Place 3 Time Tokens on this card to perform this attack.  Place an Auxiliary Power Token beside the target ship if there is at least 1 uncancelled [HIT] or [CRIT] result.	3	
10/29/2015 14:18:31	72018 - Halik Raider	Non-unique	Aft Torpedo Launcher	Kazon	4	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may only fire this weapon at a ship that is not in your forward firing arc.	3	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
ADMIRALSTEXT

officers_text = <<-OFFICERSTEXT
OFFICERSTEXT

convert_terms(upgrade)
convert_terms(captains_text)
convert_terms(weapons_text)
convert_terms(admirals_text)
convert_terms(officers_text)

new_upgrades = File.open("new_upgrades.xml", "w")
new_captains = File.open("new_captains.xml", "w")
new_admirals = File.open("new_admirals.xml", "w")
new_officers = File.open("new_officers.xml", "w")

upgrade_lines = parse_data(upgrade)

def no_quotes(a)
  a
end

def parse_set(setId)
  setId = no_quotes(setId)
  if setId =~ /\#(\d+).*/
    return $1
  end
  return setId.gsub(" ", "").gsub("\"", "")
end

upgrade_lines.each do |raw_parts|
    parts = raw_parts.collect { |one_part| convert_line(one_part) }
    parts.shift
    expansion = parts.shift
    uniqueText = parts.shift
    title = parts.shift
    faction = parts.shift
    ability = parts.shift
    upType = parts.shift
    cost = parts.shift
    special = parts.shift
    unique = uniqueText == "Unique" ? "Y" : "N"
    mirrorUniverseUnique = uniqueText == "Mirror Universe Unique" ? "Y" : "N"
    setId = set_id_from_expansion(expansion)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <Upgrade>
      <Title>#{title}</Title>
      <Ability>#{ability}</Ability>
      <Unique>#{unique}</Unique>
      <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
      <Skill></Skill>
      <Talent></Talent>
      <Attack></Attack>
      <Range></Range>
      <Type>#{upType}</Type>
      <Faction>#{faction}</Faction>
      <Cost>#{cost}</Cost>
      <Id>#{externalId}</Id>
      <Set>#{setId}</Set>
      <Special>#{special}</Special>
    </Upgrade>
    SHIPXML
    new_upgrades.puts upgradeXml
end

weapons_lines = parse_data(weapons_text)

weapons_lines.each do |raw_parts|
    parts = raw_parts.collect { |one_part| convert_line(one_part) }
    parts.shift
    expansion = parts.shift
    uniqueText = parts.shift
    title = parts.shift
    faction = parts.shift
    attack = parts.shift
    range = parts.shift
    ability = parts.shift
    upType = "Weapon"
    cost = parts.shift
    special = parts.shift
    unique = uniqueText == "Unique" ? "Y" : "N"
    mirrorUniverseUnique = uniqueText == "Mirror Universe Unique" ? "Y" : "N"
    setId = set_id_from_expansion(expansion)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <Upgrade>
      <Title>#{title}</Title>
      <Ability>#{ability}</Ability>
      <Unique>#{unique}</Unique>
      <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
      <Skill></Skill>
      <Talent></Talent>
      <Attack>#{attack}</Attack>
      <Range>#{range}</Range>
      <Type>#{upType}</Type>
      <Faction>#{faction}</Faction>
      <Cost>#{cost}</Cost>
      <Id>#{externalId}</Id>
      <Set>#{setId}</Set>
      <Special>#{special}</Special>
    </Upgrade>
    SHIPXML
    new_upgrades.puts upgradeXml
end

captains_lines = parse_data(captains_text)

captains_lines.each do |raw_parts|
  parts = raw_parts.collect { |one_part| convert_line(one_part) }
  parts.shift
  expansion = parts.shift
  uniqueText = parts.shift
  title = parts.shift
  skill = parts.shift
  faction = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  cost = parts.shift
  special = parts.shift
  unique = uniqueText == "Unique" ? "Y" : "N"
  mirrorUniverseUnique = uniqueText == "Mirror Universe Unique" ? "Y" : "N"
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
  upgradeXml = <<-SHIPXML
  <Captain>
    <Title>#{title}</Title>
    <Ability>#{ability}</Ability>
    <Unique>#{unique}</Unique>
    <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
    <Skill>#{skill}</Skill>
    <Talent>#{talent}</Talent>
    <Attack></Attack>
    <Range></Range>
    <Type>#{upType}</Type>
    <Faction>#{faction}</Faction>
    <Cost>#{cost}</Cost>
    <Id>#{externalId}</Id>
    <Set>#{setId}</Set>
    <Special>#{special}</Special>
  </Captain>
  SHIPXML
  new_captains.puts upgradeXml
end

admirals_lines = parse_data(admirals_text)
admirals_lines.each do |raw_parts|
  parts = raw_parts.collect { |one_part| convert_line(one_part) }
  parts.shift
  expansion = parts.shift
  uniqueText = parts.shift
  unique = uniqueText == "Unique" ? "Y" : "N"
  mirrorUniverseUnique = uniqueText == "Mirror Universe Unique" ? "Y" : "N"
  title = parts.shift
  faction = parts.shift
  admiralAbility = parts.shift
  skillModifier = parts.shift
  admiralTalent = parts.shift
  admiralCost = parts.shift
  skill = parts.shift
  ability = parts.shift
  upType = "Admiral"
  talent = parts.shift
  cost = parts.shift
  special = parts.shift
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
  externalId2 = make_external_id(setId, title + " cap")
  upgradeXml = <<-SHIPXML
  <Admiral>
    <Title>#{title}</Title>
    <Ability>#{ability}</Ability>
    <Unique>#{unique}</Unique>
    <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
    <Skill>#{skill}</Skill>
    <Talent>#{talent}</Talent>
    <Attack></Attack>
    <Range></Range>
    <Type>#{upType}</Type>
    <Faction>#{faction}</Faction>
    <Cost>#{cost}</Cost>
    <Id>#{externalId}</Id>
    <Set>#{setId}</Set>
    <Special>#{special}</Special>
    <AdmiralAbility>#{admiralAbility}</AdmiralAbility>
    <AdmiralCost>#{admiralCost}</AdmiralCost>
    <AdmiralTalent>#{admiralTalent}</AdmiralTalent>
    <SkillModifier>#{skillModifier}</SkillModifier>
  </Admiral>
  SHIPXML
  new_admirals.puts upgradeXml
  upgradeXml = <<-SHIPXML
  <Captain>
    <Title>#{title}</Title>
    <Ability>#{ability}</Ability>
    <Unique>#{unique}</Unique>
    <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
    <Skill>#{skill}</Skill>
    <Talent>#{talent}</Talent>
    <Attack></Attack>
    <Range></Range>
    <Type>Captain</Type>
    <Faction>#{faction}</Faction>
    <Cost>#{cost}</Cost>
    <Id>#{externalId2}</Id>
    <Set>#{setId}</Set>
    <Special>#{special}</Special>
    <AdmiralAbility>#{admiralAbility}</AdmiralAbility>
    <AdmiralCost>#{admiralCost}</AdmiralCost>
    <AdmiralTalent>#{admiralTalent}</AdmiralTalent>
    <SkillModifier>#{skillModifier}</SkillModifier>
  </Captain>
  SHIPXML
  new_captains.puts upgradeXml

end


officers_lines = parse_data(officers_text)
officers_lines.each do |raw_parts|
  parts = raw_parts.collect { |one_part| convert_line(one_part) }
  parts.shift
  expansion = "CollectiveOP3"
  unique = "Y"
  title = parts.shift
  faction = "Independent"
  officerAbility = parts.shift
  cost = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  skill = parts.shift
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
  upgradeXml = <<-SHIPXML
  <Officer>
    <Title>#{title}</Title>
    <Ability>#{officerAbility}</Ability>
    <Unique>#{unique}</Unique>
    <Attack></Attack>
    <Range></Range>
    <Type>Officer</Type>
    <Faction>#{faction}</Faction>
    <Cost>#{cost}</Cost>
    <Id>#{externalId}</Id>
    <Set>#{setId}</Set>
    <Special></Special>
  </Officer>
  SHIPXML
  new_officers.puts upgradeXml
end
