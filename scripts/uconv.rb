require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
7/20/2016 16:32:02	72336 - USS Venture	Unique	Galaxy Wing Squadron	Federation	ACTION: Discard this card to target all friendly Galaxy-class ships within Range 1-2.  Target ships gain +1 attack die this round.	Talent	5	
7/20/2016 16:33:08	72336 - USS Venture	Non-unique	Computer Core	Federation	You can fill a [CREW] or [WEAPON] Upgrade slot with this Upgrade.  Add 1 [TECH] Upgrade to your Upgrade Bar.  ACTION: You may re-roll any 1 die this round.	?	5	Yes
7/20/2016 16:34:47	72336 - USS Venture	Non-unique	Maximum Warp	Federation	ACTION: If you performed a [FORWARD] Maneuver this round, you may disable this card to immediately perform an additional [FORWARD] Maneuver with a speed of 2 or less.  You cannot perform any free Actions this round.	Tech	5	
7/20/2016 16:35:50	72336 - USS Venture	Non-unique	High-Capacity Deflector Shield Grid	Federation	If you have at least 1 Active Shield, during the Compare Results step, you may discard this card to negate up to 2 damage.  No ship may be equipped with more than 1 "High-Capacity Deflector Shield Grid" Upgrade.	Tech	5	Yes
7/28/2016 7:52:01	72321p - IRW Rateg	Unique	Nanclus	Romulan	ACTION: Discard this card to target an opposing ship at Range 1-3.  The target ship gains +1 attack die this round, but cannot roll defense dice this round.	Crew	5	
7/28/2016 7:53:13	72321p - IRW Rateg	Non-unique	Control Central	Romulan	After performing your Action, you may disable this card to perform one of the Actions on your Action Bar as a free Action.  No ship may be equipped with more than one "Control Central" Upgrade.	Tech	4	Yes
7/28/2016 7:54:08	72321p - IRW Rateg	Unique	Military Secrets	Romulan	When attacking, during the Roll Defense Dice step, you may discard this card to force the defending shp to roll 1 less defense die (-2 defense dice if that ship is Cloaked).	Talent	4	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
7/10/2016 20:51:56	72321p - IRW Rateg	Unique	Tal	4	Romulan	If this card is assigned to a Romulan ship, when attacking at Range 1 with your Primary Weapon, during the Roll Attack Dice step, gain +1 attack die.	1	3		
7/10/2016 20:52:35	72321p - IRW Rateg	Non-unique	Romulan	1	Romulan		0	0		
7/20/2016 16:27:29	72336 - USS Venture	Non-unique	Federation	1	Federation		0	0		
7/20/2016 16:28:08	72336 - USS Venture	Unique	Donald Varley	4	Federation	Your ship may perform a [SCAN] Action as a free Action each round.	1	3		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
7/20/2016 16:29:39	72336 - USS Venture	Non-unique	Photon Torpedoes	Federation	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens o n this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
7/20/2016 16:30:51	72336 - USS Venture	Non-unique	Additional Phaser Array	Federation			After you make an attack with your Primary Weapon, you may disable this card to make an additional attack with your Primary Weapon at -2 attack dice.  No ship may be equipped with more than 1 "Additional Phaser Arrays" Upgrade.	5	Yes
7/28/2016 7:50:48	72321p - IRW Rateg	Non-unique	Main Batteries	Romulan	3	1-3	Add 1 [WEAPON] Upgrade icon to your Upgrade Bar.  ATTACK: Place 2 Time Tokens on this card to perform this attack.  Treat this attack as if it were an attack made with a Primary Weapon.  No ship may be equipped with more than one "Main Batteries" Upgrade.	3	Yes
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
