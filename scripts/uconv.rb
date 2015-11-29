require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
11/13/2015 11:43:02	72005p - Xindus	Unique	Damron	Xindi	When attacking with your Primary Weapon, if your attack hits the target ship, you may spend your [TARGET LOCK] Token to discard 1 [CREW] Upgrade on target ship.	Crew	4	
11/13/2015 11:44:02	72005p - Xindus	Non-unique	Sensor Encoders	Xindi	If your ship is destroyed, all friendly ships within Range 1-3 of your ship roll +1 defense die the next time they defend.	Tech	3	
11/13/2015 11:44:53	72005p - Xindus	Unique	Dominant Species	Xindi	When attacking, during the Modify Defense Dice step, you may discard this card to force the defending ship to re-roll up to 2 of its defense dice.	Talent	5	
11/13/2015 11:50:27	72005g - Temporal Cold War Cards	Unique	The Benefactor	Mirror Universe	At the start of the game, place 3 Mission Tokens on this card.  When you are required to place Time Tokens on one of your Upgrades, you may discard any number of Mission Tokens from this card to place 1 less Time Token for each Mission Token discarded.  When there are no more Mission Tokens on this card, discard it.	Talent	5	
11/13/2015 11:52:00	72005g - Temporal Cold War Cards	Unique	Temporal Conduit	Mirror Universe	ACTION: Discard this card to redeploy one of your previously discarded Upgrade cards with a cost of 4 SP or less to your ship.  Place 3 Time Tokens on that Upgrade.  This Upgrade costs +5 SP for any non-Mirror Universe ship.	Tech	5	Yes
11/13/2015 11:53:40	72005g - Temporal Cold War Cards	Unique	Temporal Observatory	Mirror Universe	You may fill a [CREW], [TECH] or [WEAPON] Upgrade slot with this Upgrade.  ACTION: Place 3 Time Tokens on this card.  During the Planning Phase, after all ships have chosen their maneuvers, you may peek at a number of opposing maneuver dials equal to the number of Time Tokens on this card.  You may then change your chosen maneuver.  Discard this card after the last Time Token is removed.	?	6	Yes
11/13/2015 11:54:47	72005g - Temporal Cold War Cards	Unique	Daniels	Mirror Universe	Whenever an opposing ship is required to place Time Tokens on one of its Upgrades, you may discard this card to force that ship to place 1 additional Time Token on that Upgrade.  OR  During the Combat Phase, you may discard this card to choose any number of your dice and re-roll them.	Crew	5	
11/20/2015 10:22:04	72022 - Dreadnaught	Non-unique	Maintenance Crew	Dominion	This Upgrade does not require an Upgrade slot.  Add 1 [CREW] Upgrade slot to your Upgrade Bar.  During the Planning Phase, you may discard this card and 1 of your [CREW] Upgrades to repair up to 2 damage to your ship.  No ship may be equipped with more than one "Maintenance Crew" Upgrade.	?	6	Yes
11/20/2015 10:22:50	72022 - Dreadnaught	Non-unique	Kinetic Detonator	Dominion	ACTION: Discard this card and 1 of your [WEAPON] Upgrades to inflict 1 damage to all ships within Range 1 (including this ship).	Tech	4	
11/20/2015 10:24:26	72022 - Dreadnaught	Non-unique	Counter Measures	Dominion	When defending, during the Roll Defense Dice step, you may discard this card to roll +2 defense dice.  Immediately after that attack is completed, you may then perform a 2 dice attack against the attacking ship.  This Upgrade costs +5 SP for any ship other than a Cardassian ATR-4017 and no ship may be equipped with more than one "Counter Measures" Upgrade.	Tech	5	Yes
11/20/2015 10:25:38	72022 - Dreadnaught	Non-unique	Evasive Attack Route	Dominion	When defending, during the Modify Defense Dice step, you may disable this card and discard one of your [WEAPON] Upgrades to place 2 [EVADE] Tokens beside your ship.  This Upgrade may only be purchased for a Cardassian ATR-4107.	Tech	5	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
11/13/2015 11:40:34	72005p - Xindus	Non-unique	Xindi	1	Xindi		0	0		
11/13/2015 11:41:48	72005p - Xindus	Unique	Kolo	5	Xindi	When a friendly ship within Range 1 of your ship is defending, during the Declare Target step, your ship may become the target of the attack instead of the friendly ship.  Treat the attack as though your ship were the same Range as the friendly ship.	1	3		
11/13/2015 11:48:36	72005g - Temporal Cold War Cards	Unique	Vosk	7	Mirror Universe	Vosk does not pay a faction penalty when fielding an [ELITE TALENT] Upgrade.  Once per game, when an opposing Upgrade causes one of your Upgrades to be discarded, you may place 3 Time Tokens on that card instead.	1	4	Yes	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
11/13/2015 11:46:11	72005p - Xindus	Non-unique	Photon Torpedoes	Xindi	4	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  If fired from a Xindi Reptilian warship, add +1 attack die.	3	
11/20/2015 10:15:21	72022 - Dreadnaught	Unique	Anti-Matter Warhead	Dominion	7	3	ATTACK: (Target Lock) Spend your target lock and discard this card to perform this attack.  If this attack hits, place an Auxiliary Power Token beside all ships within Range 1 of the defending ship.  You may only fire this weapon from your forward firing arc.	7	
11/20/2015 10:17:05	72022 - Dreadnaught	Non-unique	Quantum Torpedoes	Dominion	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  If the target ship is hit, add 1 [HIT] result to your total damage.  If this weapon is fired from a Cardassian ATR-4107, add 1 additional [HIT] result to your total damage.  You may fire this weapon from your forward or rear firing arcs.	6	
11/20/2015 10:18:29	72022 - Dreadnaught	Non-unique	Thoron Shock Emitter	Dominion	5	1-3	ATTACK: (Target Lock) Spend your target lock and discard this card to perform this attack.  You may select any number of your attack dice and re-roll them.  This Upgrade may only be purchased for a Cardassian ATR-4107 ship.	5	Yes
11/20/2015 10:19:34	72022 - Dreadnaught	Non-unique	Plasma Wave	Dominion	3	1	ATTACK: Discard this card to perform this attack.  You my fire this weapon at every ship within Range 1 of your ship.  This Upgrade may only be purchased for a Cardassian ATR-4107 ship.	2	Yes
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
