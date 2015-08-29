require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
8/25/2015 17:04:14	72012 - Bioship Beta	Unique	Telepathy	Species 8472	You may discard this card immediately before you move in order to change your Maneuver for that round.	Talent	4	
8/25/2015 17:05:58	72012 - Bioship Beta	Non-unique	Biological Technology	Species 8472	Place 1 Mission Token on this card at the start of each Planning Phase.  When attacking, you may spend up to 2 of these tokens to add an equal number of attack dice.  When defending, you may spend up to 2 of these tokens to add an equal number of defense dice.  This Upgrade may only be purchased for a Species 8472 ship and no ship may be equipped with more than 1 "Biological Technology" Upgrade.	Tech	5	Yes
8/25/2015 17:07:47	72012 - Bioship Beta	Non-unique	Biogenic Field	Species 8472	When defending, you roll +1 defense die (+3 vs a Borg ship).  In addition, when an enemy card ability affects one of your cards, roll 1 attack die (3 dice against a Borg card ability).  If your roll a [BATTLE STATIONS] result, the card effect is cancelled.  This Upgrade may only be purchased for a Species 8472 ship and no ship may be equipped with more than 1 "Biogenic Field" Upgrade.	Tech	6	
8/25/2015 17:09:05	72012 - Bioship Beta	Non-unique	Electrodynamic Fluid	Species 8472	ACTION: Discard this card to immediately perform a 2nd maneuver from your Maneuver Dial with a speed of 3 or less.  OR  ACTION: Disable this card to perform a [SENSOR ECHO] Action even if your ship is not cloaked.  This Upgrade may only be purchased for a Species 8472 ship.	Tech	5	Yes
8/25/2015 17:10:38	72012 - Bioship Beta	Non-unique	Fluidic Space	Species 8472	Instead of making a normal move, you may discard this card to remove your ship from the play area and immediately place it back anywhere in the play area, but not within Range 1-2 of any other ship.  You cannot attack or perform any Actions on the round you use this ability.  This Upgrade costs +5 SP if purchased for a non-Species 8472 ship and no ship may be equipped with more than 1 "Fluidic Space" Upgrade.	Tech	6	Yes
8/28/2015 9:47:15	72013 - Quark's Treasure	Unique	Grand Nagus	Ferengi	ACTION: Discard this card to target every friendly Ferengi ship within Range 1-3.  Each target ship may immediately perform an additional green maneuver.	Talent	5	
8/28/2015 9:49:09	72013 - Quark's Treasure	Unique	Odo	Independent	During the Planning Phase, you may target a ship within Range 1-3 and choose 1 [CREW] Upgrade on the target ship.  If you do so, treat this card as an exact copy of the chosen Upgrade until the end of the End Phase in which you use this ability.  If the chosen Upgrade's Action or ability requires it to be disabled or discarded, you must disable or discard this card to use it.	Crew	5	
8/28/2015 9:49:53	72013 - Quark's Treasure	Unique	Nog	Ferengi	When defending, during the Roll Attack Dice step, you may discard this card to force the attacking ship to roll -2 attack dice for that attack.	Crew	3	
8/28/2015 9:50:42	72013 - Quark's Treasure	Unique	Rom	Ferengi	ACTION: Repair 1 Shield Token.  If this card is assigned to a Ferengi ship, you may repair up to 2 Shield Tokens instead of 1.	Crew	3	
8/28/2015 9:52:55	72013 - Quark's Treasure	Non-unique	Cargo Hold	Ferengi	Add 2 Upgrade slots ([CREW] or [TECH]) to your Upgrade Bar.  These Upgrades cannot have a cost greater than 4 SP.  This Upgrade may only be purchased for a Ferengi ship and no ship may be equipped with more than 1 "Cargo Hold" Upgrade.	Tech	1	
8/28/2015 9:54:24	72013 - Quark's Treasure	Non-unique	Inversion Wave	Ferengi	Instead of making a normal move, you may discard this card to place your ship anywhere in the play area within Range 1-3 of your current position.  Remove all Tokens (except Critical Hit Tokens) from beside your ship and place an Auxiliary Power Token beside your ship.  You cannot attack on the round you use this ability.  No ship may be equipped with more than 1 "Inversion Wave" Upgrade.	Tech	4	Yes
8/28/2015 9:56:30	72013 - Quark's Treasure	Unique	Smugglers	Ferengi	ACTION: Target a ship at Range 1-3. Discard this card to steal 1 [TECH] or [WEAPON] Upgrade from the target ship, even if it exceeds your ship's restrictions.  If the Smugglers Upgrade is assigned to a Ferengi Shuttle, the stolen Upgrade is flipped face down and cannot be used by your ship.  The shuttle may exchange the stolen Upgrade with a docking ship.  The docking ship may then flip the stolen Upgrade face up and use it.  This Upgrade may only be purchased for a Ferengi Captain assigned to a Ferengi ship.	Talent	5	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
8/25/2015 17:00:06	72012 - Bioship Beta	Unique	Bioship Beta Pilot	8	Species 8472	When attacking, during the Modify Attack Dice step, you may re-roll 1 of your blank results.  If your ship was just destroyed and another friendly ship is within Range 1-2 of your ship, you may replace that ship's Captain Card with this card.  If this Captain fielded an [ELITE TALENT] Upgrade, you may assign that Upgrade to the new ship as well, if possible.	1	6		
8/25/2015 17:01:50	72012 - Bioship Beta	Non-unique	Species 8472	1	Species 8472		0	0		
8/28/2015 9:43:23	72013 - Quark's Treasure	Non-unique	Ferengi	1	Ferengi		0	0		
8/28/2015 9:44:33	72013 - Quark's Treasure	Unique	Quark	3	Ferengi	ACTION: Discard all of your Upgrades to target a ship at Range 1-2.  Target ship cannot attack your ship this round.  You must discard at least 1 Upgrade to use this Action.  You cannot attack or perform any free Actions this round.	1	2		
8/28/2015 9:46:07	72013 - Quark's Treasure	Unique	Brunt	4	Ferengi	ACTION: When defending this round, during the Modify Attack Dice step, you may force 1 opposing ship to re-roll 1 of its attack dice (your choice).  You may field the Grand Nagus [ELITE TALENT] Upgrade.  If you use the Action listed on it, you must discard this card as well.	0	3	Yes	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
8/25/2015 17:12:48	72012 - Bioship Beta	Non-unique	Biological Weapon	Species 8472	5	2-3	ATTACK: Discard this card to perform this attack.  If this attack hits, in addition to normal damage, discard 1 [CREW] Upgrade of your choice on the defending ship for each [BATTLE STATIONS] result (max 2).  This Upgrade may only be purchased for a Species 8472 Bioship.	6	Yes
8/25/2015 17:13:46	72012 - Bioship Beta	Non-unique	Energy Blast	Species 8472	8	2-3	ATTACK: (Target Lock) Spend your target lock and discard this card to perform this attack.  This Upgrade may only be purchased for a Species 8472 Bioship.	8	Yes
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
8/28/2015 9:38:49	72013 - Quark's Treasure	Unique	Zek	Ferengi	FLEET ACTION: Target a ship at Range 1.  Disable 1 of your Upgrades and 1 Upgrade (your choice) on the target ship.  This card may only be purchased for a Ferengi ship.	0	1	1	2	ACTION: Target a ship at Range 1.  Disable 1 of your Upgrades and 1 Upgrade (your choice) on the target ship.  This card may only be purchased for a Ferengi ship.	1	1	Yes
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
