require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
9/30/2016 14:10:40	72323p - IKS Bortas	Unique	Worf	Klingon	When attacking a ship with no Active Shields, you may disable this card to gain +1 attack die.  Your ship cannot roll any defense dice during the round in which you use this ability.	Crew	3	
9/30/2016 14:11:24	72323p - IKS Bortas	Unique	Aim and Fire!	Klingon	When attacking with your Primary Weapon, you may discard this card to target a ship at Range 1-2.  The target ship cannot re-roll any of its defense dice against that attack.	Talent	5	
9/30/2016 14:12:32	72323p - IKS Bortas	Unique	Cry of the Warrior	Klingon	When attacking, during the Roll Attack Dice step, you may discard this card to gain  +1 attack die for each opposing ship that has your ship in its forward firing arc (max +3).  The next time your ship rolls defense dice, roll -1 defense dice for each additional attack die you gained with this ability.	Talent	5	
9/30/2016 14:13:15	72323p - IKS Bortas	Non-unique	Emergency Override	Klingon	ACTION: If you executed a green maneuver this round, disable this card to repair 1 of your Shields.	Tech	2	
10/20/2016 12:53:18	72341 - Orassin	Unique	Thalen	Xindi	Add 1 [WEAPON] Upgrade slot to your Upgrade bar.  If the additional [WEAPON] Upgrade is a Xindi [WEAPON] Upgrade, its cost is -2 SP.  When firing a secondary weapon, you may disable this card to gain +1 attack die (max 6).	Talent	5	Yes
10/20/2016 12:54:45	72341 - Orassin	Unique	Xindi Council	Xindi	Place 1 Mission Token on this card for each damage your ship suffers to it's Hull or Shields (max 4).  When attacking or defending, you may discard this card to re-roll a number of your attack or defense dice up to the number of Mission Tokens on this card.  This card may only be fielded by a Xindi Captain assigned to a Xindi ship.	Talent	4	Yes
10/20/2016 13:00:51	72341 - Orassin	Non-unique	Insectoid Raiding Party	Xindi	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Discard this card to discard any Upgrade with a cost of 5 SP or less on the target ship.  This Upgrade costs +5 SP if purchased for any ship other than a Xindi ship and no ship may be equipped with more than one "Insectoid Raiding Party" Upgrade.	Crew	3	Yes
10/20/2016 13:02:37	72341 - Orassin	Non-unique	Hatchery	Xindi	Add 1 [CREW] Upgrade slot to your Upgrade Bar.  At the start of the game, during the Gather Forces step, place a Xindi [CREW] Upgrade face down beneath this card.  When one of your rother [CREW] Upgrades is discarded, discard this card and flip the card beneath this card face up.  That card is now deployed to your ship and may be used normally.  This Upgrade may only be purchased for a Xindi ship and no ship may be equipped with more than one "Hatchery" Upgrade.	Tech	2	Yes
10/27/2016 15:05:22	72324p - IKS Hegh'ta	Non-unique	Change Course	Klingon	This card may fill a [CREW], [ELITE TALENT], [TECH] or [WEAPON] Upgrade slot.  During the Åctivation Phase, when you reveal your maneuver, you may discard this card to change your maneuver to any maneuver on your Maneuver Card.  No ship may be equipped with more than one "Change Course" Upgrade.	?	4	Yes
10/27/2016 15:06:34	72324p - IKS Hegh'ta	Unique	On My Command	Klingon	During the Combat Phase, when it is your turn to attack, you may discard this card to delay your attack until after all other ships have completed their attacks.  If you do so, roll +2 attack dice for your first attack during the round you use this ability.	Talent	5	
10/27/2016 15:08:28	72324p - IKS Hegh'ta	Unique	Toral	Klingon	During the Modify Defense Dice step, you may discard this card to re-roll up to 2 of your defense dice.  If this card is deployed to a Klingon ship, you may disable it instead of discarding it.	Crew	4	
10/27/2016 15:10:24	72324p - IKS Hegh'ta	Non-unique	Auxiliary Power to Shields	Klingon	When defending, during the Deal Damage step, you may discard this card to immediately repair up to 2 of your Shields that were destoyed with that attack.  Place 1 Auxiliary Power Token beside your ship for each Shield Token you repair with this ability.  No ship may be equipped with more than one "Auxiliary Power to Shields" Upgrade.	Tech	4	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
9/30/2016 14:02:12	72323p - IKS Bortas	Non-unique	Klingon	1	Klingon		0	0		
9/30/2016 14:03:10	72323p - IKS Bortas	Unique	Gowron	5	Klingon	If this card is assigned to a Klingon ship and all of your Shields have been destroyed, you may gain +1 attack die on all of your attacks.  If any of your Shield Tokens are repaired, you lose this bonus attack die.	1	3		
10/20/2016 12:40:16	72341 - Orassin	Non-unique	Xindi	1	Xindi		0	0		
10/20/2016 12:41:24	72341 - Orassin	Unique	Insectoid Councilor	7	Xindi	ACTION: Each time your ship attacks this roound, during the Modify Defense Dice step, you may convert one of your opponent's [EVADE] results into a blank result.  Inflict one damage to your ship's Shields or Hull.	1	4		
10/27/2016 14:58:22	72324p - IKS Hegh'ta	Non-unique	Klingon	1	Klingon		0	0		
10/27/2016 14:59:26	72324p - IKS Hegh'ta	Unique	Kurn	6	Klingon	ACTION: If your ship is within Range 1 of an Obstacle, roll 2 attack dice.  Every ship within Range 1 fo the Obstacle suffers damage as normal for each [HIT] or [CRIT] result.  Ships do not roll defense dice against this.	1	4	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
10/20/2016 12:38:05	72341 - Orassin	Non-unique	Pulse-Firing Particle Cannon	Xindi	3	1-3	ATTACK: Disable this card to perform this attack.  You may only fire t his weapon from your forward firing arc.  If this attack hits, you may immediately make a second attack with this weapon against the same target at -1 attack die.  The target ship rolls 1 less defense die against the second attack.  This Upgrade costs +5 SP if purchased for a non-Xindi ship.	4	Yes
10/20/2016 12:38:57	72341 - Orassin	Non-unique	Xindi Torpedoes	Xindi	4	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may only fire this weapon from your forward firing arc.	2	
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
