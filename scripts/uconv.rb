require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
9/13/2015 15:08:40	72221d - USS Lakota	Unique	Defy Orders	Federation	At the end of the Activation Phase, after all ships have moved, if you have an enemy ship in your forward firing arc, you may discard this card to immediately perform an additional green or white maneuver.  You cannot attack during the round you use this ability.	Talent	4	
9/13/2015 15:09:44	72221d - USS Lakota	Non-unique	Micro Power Relays	Federation	ACTION: Repair 1 non-critical damage to your Hull.  OR  ACTION: Flip over all critical damage cards assigned to your ship.	Tech	3	
9/13/2015 15:10:28	72221d - USS Lakota	Unique	Tuvok	Federation	At any time, you may discard this card to perform a [SCAN] Action as a free Action.	Crew	3	
9/13/2015 20:11:24	72221e - IKS Toh'Kaht	Mirror Universe Unique	Hon-Tihl	Mirror Universe	When attacking with your Primary Weapon, during the Roll Attack Dice step, you may discard this card to gain +2 attack dice for that attack.  If you targeted an Attack Squadron with that attack, after resolving the attack, you may immediately make a second attack against the same Attack Squadron using only 2 attack dice; the number of dice for the second attack cannot be increased in any way.  You cannot roll any defense dice during the round you use this ability.	Crew	5	
9/13/2015 20:12:36	72221e - IKS Toh'Kaht	Mirror Universe Unique	Covert Mission	Mirror Universe	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Discard this card to steal 1 [WEAPON] Upgrade on that ship with a cost of 5 or less even if it exceeds your ship's restrictions.	Talent	5	
9/13/2015 20:19:06	72221e - IKS Toh'Kaht	Non-unique	Reactor Core	Mirror Universe	During the Activation Phase, after you reveal your maneuver, before you move, you may disable this card to increase or decrease your speed by 1.  Your new maneuver must be one that is on your maneuver dial and is treated as a red maneuver.  No ship may be equipped with more than 1 "Reactor Core" Upgrade.	Tech	2	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
9/13/2015 15:03:02	72221d - USS Lakota	Non-unique	Federation	1	Federation		0	0		
9/13/2015 15:04:14	72221d - USS Lakota	Unique	Erika Benteen	4	Federation	ACTION: Disable this card and all of your [WEAPON] Upgrades to target a ship at Range 1-3.  Your ship cannot attack the target ship and that ship cannot attack your ship this round.  You must disable at least 1 [WEAPON] Upgrade to use this Action.	1	3		
9/13/2015 20:07:42	72221e - IKS Toh'Kaht	Non-unique	Mirror Universe	1	Mirror Universe		0	0		
9/13/2015 20:08:32	72221e - IKS Toh'Kaht	Mirror Universe Unique	Kaybok	3	Mirror Universe	When attacking, during the Modify Attack Dice step, you may re-roll a number of your attack dice equal to the number of [TECH] and [WEAPON] Upgrades deployed to the defending ship.	1	2		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
9/13/2015 15:12:40	72221d - USS Lakota	Non-unique	Upgraded Phasers	Federation			When attacking with your Primary Weapon, gain +1 attack die.  Once per round, if you hit an Attack Squadron with your Primary Weapon you may immediately make a second attack against that same target.  This Upgrade costs +5 SP for any non-Federation ship and may only be deployed to a ship with a Primary Weapon value of 3 or less.  No ship may be equipped with more than 1 "Upgraded Phasers" Upgrade.	3	Yes
9/13/2015 20:15:21	72221e - IKS Toh'Kaht	Non-unique	Thalmerite Explosive	Mirror Universe	6	1-2	ATTACK: Discard this card to perform this attack.  If the defending ship is not cloaked and has no Active Shields and you have at least 1 uncanceled [CRIT] result, draw 2 Damage Cards (instead of 1) and choose which one to place beside the enemy's Ship Card; discard the unused Damage Cards.  If this attack is fired at Range 1 and hits, your ship suffers 1 damage.	5	
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
