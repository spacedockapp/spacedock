require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
10/3/2015 14:23:42	72015 - IKS Rotarran	Unique	The Day Is Ours!	Klingon	During the Roll Attack Dice step, you may discard this card to add 1 [CRIT] result to your roll.  This card may only be purchased for a Klingon Captain assigned to a Klingon ship.	Talent	4	Yes
10/3/2015 14:24:32	72015 - IKS Rotarran	Unique	Altert Status One	Klingon	ACTION: Discard this card to place a [BATTLE STATIONS] Token beside your ship.  You cannot perform a [BATTLE STATIONS] Action as a free Action this round.	Talent	3	
10/3/2015 14:25:38	72015 - IKS Rotarran	Unique	Supreme Commander	Klingon	ACTION: Discard this card to target 1 friendly ship within Range 1-3.  The target ship immediately performs a free Action from its Action Bar.  If the target ship is a Klingon ship, it may perform any Action as a free Action.	Talent	5	
10/3/2015 14:26:39	72015 - IKS Rotarran	Unique	Leskit	Klingon	After you reveal a red maneuver, before you move, you may discard this card to treat the maneuver as a green maneuver.  If your ship is cloaked when you do this, you may immediately perform a [SENSOR ECHO] Action as a free Action.	Crew	3	
10/3/2015 14:27:37	72015 - IKS Rotarran	Unique	Tavana	Klingon	ACTION: Disable this card to repair 1 Shield Token.  In addition, if your ship is cloaked, you may repair 1 damage to your Hull.  You roll -2 attack dice on all of your attacks this round.	Crew	5	
10/3/2015 14:28:30	72015 - IKS Rotarran	Unique	Kornan	Klingon	ACTION: Discard this card to acquire a target lock on a ship within Range 1-3 of your ship and then perform an Action from your Action Bar  (not [TARGET LOCK]) as a free Action.	Crew	5	
10/3/2015 14:34:49	72015 - IKS Rotarran	Unique	Worf	Klingon	Increase your Captain's Skill by +1 (+3 for a Klingon Captain).  This ability cannot be used on this card.  If your Captain is disabled, discard, or affected by a critical damage card, treat this card as your Captain Card with a Skill of 5.  If your Captain becomes non-disabled or unaffected by the critical damage card, that Captain Card is restored.	Crew	2	
10/3/2015 14:43:51	72015 - IKS Rotarran	Unique	Jadzia Dax	Federation	You do not pay a faction penalty when assigning this card to a Klingon ship.  You may disable this card and spend your [SCAN] Token to convert 1 of your [BATTLE STATIONS] results into a [HIT] or an [EVADE] result.	Crew	5	Yes
10/6/2015 13:46:59	72016 - RIS Talvath	Unique	Secret Research	Romulan	Add the [SCAN] Action to your Action Bar.  If this card is discarded, you no longer have the [SCAN] Action on your Action Bar.  During the Activation Phase, you may discard this card to perform a [SCAN] Action as a free Action.  This card costs +5 SP if purchased for any ship other than a Romulan Science Vessel.	Talent	5	Yes
10/6/2015 13:48:04	72016 - RIS Talvath	Non-unique	Test Cylinder	Romulan	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at any Range.  Disable this card and 1 [CREW] Upgrade of your choice on the target ship.  This Upgrade may only be purchased for a Romulan Science Vessel.	Tech	3	Yes
10/6/2015 13:49:30	72016 - RIS Talvath	Unique	Temporal Displacement	Romulan	When defending, during the Compare Results step, you may discard this card to cancel all of the attacking ship's [HIT] and [CRIT] results.  All cards that were used during the attack are returned to the state that they were in prior to the attack.  The attacking ship cannot perform any more attacks during the round this ability is used.  This card may only be purchased for a Romulan Science Vessel.	Tech	5	Yes
10/6/2015 13:51:15	72016 - RIS Talvath	Non-unique	Warp Core Ejection System	Romulan	ACTION: Discard this card to repair 1 damage to your Hull and flip any "Warp Core Breach" critical damage cards assigned to your ship face down.  For the rest of the game, you cannot perform any maneuvers with a speed greater than 1 and you cannot receive a "Warp Core Breach" critical damage card.  If you do, immediately flip the card face down and treat it as normal damage.  No ship may be assigned with more than one "Warp Core Ejection System" Upgrade.	Tech	4	Yes
10/6/2015 13:52:58	72016 - RIS Talvath	Unique	Advanced Scanning	Romulan	Add the [SCAN] Action to your Action Bar.  If this card is discarded, you no longer have the [SCAN] Action on your Action Bar.  Whenever you perform the [SCAN] Action, you may place 1 additional [SCAN] Token beside your ship.  If you do so, place an Auxiliary Power Token beside your ship.  This card costs +5 SP for any ship other than a Romulan Science Vessel.	Tech	5	Yes
10/6/2015 13:54:11	72016 - RIS Talvath	Non-unique	Signal Amplifier	Romulan	You may discard this card and spend 1 [SCAN] Token to add +2 attack dice or +2 defense dice.  This Upgrade costs +5 Squadron Points for any ship other than a Romulan Science Vessel and no ship may be equipped with more than 1 "Signal Amplifier" Upgrade.	Tech	5	Yes
10/6/2015 13:55:48	72016 - RIS Talvath	Non-unique	Graviton Field Generator	Romulan	ACTION: Disable this card and up to 2 of your Active Shields to immediately perform an additional [FORWARD] maneuver with a speed equal to the number of shields you disabled with this Action.  OR  ACTION: If you performed a green maneuver this round, discard this card to place 2 Shield Tokens beside your ship.  When suffering damage this round, remove these Shield Tokens first.	Tech	5	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
10/3/2015 14:18:44	72015 - IKS Rotarran	Non-unique	Klingon	1	Klingon		0	0		
10/3/2015 14:20:08	72015 - IKS Rotarran	Unique	Martok	7	Klingon	All of your Klingon Upgrades cost -1SP.  ACTION: When attacking this round, during the Roll Attack Dice step, you may roll 2 less attack dice to add 1 [HIT] result to your roll.  If you only have Klingon cards assigned to your ship, roll 1 less attack die, instead of 2.	1	4	Yes	
10/6/2015 13:43:35	72016 - RIS Talvath	Non-unique	Romulan	1	Romulan		0	0		
10/6/2015 13:45:01	72016 - RIS Talvath	Unique	Telek R'Mor	3	Romulan	Each time you defend, if you have at least 1 [SCAN] Token beside your ship, roll +1 defense die.  You may field the "Secret Research" [ELITE TALENT] Upgrade.	0	2	Yes	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
10/3/2015 14:22:17	72015 - IKS Rotarran	Non-unique	Photon Torpedoes	Klingon	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
10/6/2015 13:58:22	72016 - RIS Talvath	Unique	Alidar Jarok	Romulan	FLEET ACTION: Target a ship within Range 1 and remove 1 Token ([EVADE], [SCAN], [BATTLE STATIONS], or [TARGET LOCK]) from beside that ship.  If you remove a [TARGET LOCK] Token with this ability, also remove the corresponding [TARGET LOCK] Token.	2	1	4	6	ACTION: Target a ship within Range 1 and remove 1 Token ([EVADE], [SCAN], [BATTLE STATIONS], or [TARGET LOCK]) from beside that ship.  If you remove a [TARGET LOCK] Token with this ability, also remove the corresponding [TARGET LOCK] Token.	1	4	
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
