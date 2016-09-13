require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
8/31/2016 23:50:19	72350 - USS Enterprise-B	Non-unique	Resonance Burst	Federation	When attacking, during the Declare Target step, you may discard this card to target a ship in your forward firing arc and within Range 1 of your ship.  The target ship must discard 1 Token ([EVADE], [BATTLE STATIONS], [SCAN], or [TARGET LOCK]) that is beside it of its choice.  If there is a [CLOAK] Token beside the target ship, flip it over to its red side.  No ship may be equipped with more than one "Resonance Burst" Upgrade.	Tech	5	Yes
8/31/2016 23:51:51	72350 - USS Enterprise-B	Non-unique	Deflector Control	Federation	ACTION: Repair 1 Shield Token.  OR  Discard this card to flip up to 3 of your disabled Shield Tokens over to their Active sides.  You cannot use this Action if your ship is Cloaked.  No ship may be equipped with more than one "Deflector Control" Upgrade.	Tech	5	Yes
8/31/2016 23:53:00	72350 - USS Enterprise-B	Non-unique	Full Reverse	Federation	During the Activation Phase, if you reveal a [REVERSE] Maneuver, you may disable this card to add 1 to the speed of that maneuver.  No ship may be equipped with more than one "Full Reverse" Upgrade.	Tech	2	Yes
8/31/2016 23:54:07	72350 - USS Enterprise-B	Non-unique	Holo-Communicator	Federation	During the Activation Phase, you may disable this card to target a friendly ship within Range 1-2.  If you do so, you may perform the Action listed on that ship's Captain Card.  No ship may be equipped with more than one "Holo-Communicator" Upgrade.	Tech	5	Yes
8/31/2016 23:54:58	72350 - USS Enterprise-B	Unique	Demora Sulu	Federation	If your ship is hit, after the Deal Damage phase, you may discard this card to immediately execute a maneuver from your Maneuver Dial with a speed of 3 or less.	Crew	4	
9/1/2016 11:20:12	72322p - Kohlar's Battle Cruiser	Unique	Kuvah'Magh	Klingon	When attacking with your Primary Weapon, during the Roll Attack Dice step, you may discard this card to gain +1 attack die for that attack for every Klingon [CREW] Upgrade deployed to your ship (max +3).  Then suffer 1 critical damage to your Hull.	Talent	5	
9/1/2016 11:21:22	72322p - Kohlar's Battle Cruiser	Unique	Morak	Klingon	ACTION: If your ship is not Cloaked, disable this card to repair 1 of your Shield Tokens.  OR  ACTION: Discard this card to flip up to 3 of your Disabled Shields over to their Active sides.  If you do this while your ship is Cloaked, flip your [CLOAK] Token to its red side.	Crew	5	
9/1/2016 11:22:18	72322p - Kohlar's Battle Cruiser	Unique	Ch'Rega	Klingon	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Disable this card and any 2 [CREW] Upgrades of your choice on the target ship.	Crew	2	
9/1/2016 11:23:07	72322p - Kohlar's Battle Cruiser	Unique	T'Greth	Klingon	ACTION: Place a [BATTLE STATIONS] Token beside your ship.  Then place an Auxiliary Power Token beside your ship.  You cannot perform a [BATTLE STATIONS] Action this round.	Crew	4	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
8/31/2016 23:44:35	72350 - USS Enterprise-B	Non-unique	Federation	1	Federation		0	0		
8/31/2016 23:46:39	72350 - USS Enterprise-B	Unique	John Harriman	2	Federation	During the Activation Phase, you may perform an [EVADE] Action as a free Action.  If you do so, place Auxilary Power Token beside your ship.	0	1		
9/1/2016 11:17:24	72322p - Kohlar's Battle Cruiser	Non-unique	Klingon	1	Klingon		0	0		
9/1/2016 11:18:43	72322p - Kohlar's Battle Cruiser	Unique	Kohlar	3	Klingon	Your Captain Skill number increases by +2 for each damage card assigned to your ship (max +4).  If the damage to your ship is repaired, your Skill Number decreases accordingly.  You may field the "Kuvah'Magh" [ELITE TALENT] Upgrade at a cost of -2.	1	2	Yes	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
8/31/2016 23:48:03	72350 - USS Enterprise-B	Non-unique	Improved Phasers	Federation	4	1-3	ATTACK: Place 2 Time Tokens on this card to perform this attack.  Treat this as an attack with your Primary Weapon.	3	
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
