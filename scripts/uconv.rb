require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
4/23/2015 12:32:08	71800 - ISS Avenger	Mirror Universe Unique	Sabotage	Mirror Universe	ACTION: Discard this card to target a ship at Range 1-3.  Target ship must disable 2 Active Shields, if possible.  If the target ship has no Active Shields or if this Action causes the target ship to have no Active Shields, place an Auxiliary Power Token beside the target ship.	Talent	4	
4/23/2015 12:33:47	71800 - ISS Avenger	Non-unique	Orion Tactical Officer	Mirror Universe	If you damage an opponent's Hull with a [CRIT], you may immediately discard this card to search the Damage Deck for a "Weapons Malfunction" or a "Munitions Failure" card instead of drawing a random Damage Card.  Re-shuffle the Damage Deck when you are done.  No ship may be equipped with more than one "Orion Tactical Officer" Upgrade.	Crew	2	Yes
4/23/2015 12:35:21	71800 - ISS Avenger	Non-unique	Andorian Helmsman	Mirror Universe	During the Combat Phase, after you complete your attack, you may discard this card to immediately perform a 1 or 2 Maneuver (straight or bank).  If you do so, place an Auxiliary Power Token beside your ship.  No ship may be equipped with more than one "Andorian Helmsman" Upgrade.	Crew	2	Yes
4/23/2015 12:36:52	71800 - ISS Avenger	Non-unique	Emergency Bulkheads	Mirror Universe	ACTION: Disable this card to flip all critical damage cards assigned to your ship face down.  If your ship is not cloaked and you have no Active Shields, each time you defend this round, roll +1 defense die.	Tech	4	
4/23/2015 12:38:45	71800 - ISS Avenger	Non-unique	Enhanced Hull Plating	Mirror Universe	During the Roll Defense Dice step of the Combat Phase, if your ship is not Cloaked and you have no Active Shields, you may add up to 2 [EVADE] results to your defense roll.  If you do so, place 1 Auxiliary Power Token beside your ship for each [EVADE] result you added with this Upgrade.  This Upgrade may only be purchased for a Mirror Universe ship with a Hull value of 4 or less.  You cannot deploy more than 1 "Enhanced Hull Plating" Upgrade to any ship.	Tech	4	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
4/23/2015 12:30:22	71800 - ISS Avenger	Mirror Universe Unique	Soval	4	Mirror Universe	You do not pay a faction penalty when deploying any Upgrades to your ship.	1	3		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
4/23/2015 12:40:26	71800 - ISS Avenger	Non-unique	Photonic Torpedoes	Mirror Universe	4	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may fire this weapon from your forward or rear firing arcs.	2	
4/23/2015 12:41:12	71800 - ISS Avenger	Non-unique	Plasma Cannons	Mirror Universe	3	1-3	ATTACK: Disable this card to perform this attack.  You may fire this weapon from your forward or rear firing arcs.	2	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
4/23/2015 12:46:44	71800 - ISS Avenger	Mirror Universe Unique	Black	Mirror Universe	FLEET ACTION: Perform a [SENSOR ECHO] Action with a 1 [STRAIGHT] Maneuver Template, even if your ship is not cloaked or does not have the [SENSOR ECHO] icon on its Action Bar.  Each time you defend this round, during the Modify Defense Dice step, you may re-roll one of your blank results.  Place an Auxiliary Power Token beside your ship.	1	1	3	4	ACTION: Perform a [SENSOR ECHO] Action with a 1 [STRAIGHT] Maneuver Template, even if your ship is not cloaked or does not have the [SENSOR ECHO] icon on its Action Bar.  Each time you defend this round, during the Modify Defense Dice step, you may re-roll one of your blank results.  Place an Auxiliary Power Token beside your ship.	1	3	
4/23/2015 12:48:10	71800 - ISS Avenger	Mirror Universe Unique	Gardner	Mirror Universe	FLEET ACTION: When attacking with your Primary Weapon, during the Roll Attack Dice step, gain +1 attack die this round.  Each time you defend this round, during the Roll Defense Dice step, roll -1 defense die.  You cannot perform free Actions this round.	0	0	2	3	ACTION: When attacking with your Primary Weapon, during the Roll Attack Dice step, gain +1 attack die this round.  Each time you defend this round, during the Roll Defense Dice step, roll -1 defense die.  You cannot perform free Actions this round.	0	2	
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
