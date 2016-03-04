require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
2/13/2016 0:15:08	72327 - IKS Amar	Non-unique	Klingon Helmsman	Klingon	ACTION: Discard this card to immediately perform an additional 1 [COME ABOUT] or 2 [COME ABOUT] Maneuver.  Treat this as a red maneuver.  This card costs +5 SP for any non-Klingon ship and cannot be deployed to a ship that does not have a [COME ABOUT] Maneuver on its Maneuver dial.	Crew	3	Yes
2/13/2016 0:16:26	72327 - IKS Amar	Non-unique	Klingon Navigator	Klingon	During the Activation Phase, before you move, you may discard this card to disregard your chosen maneuver and perform any maneuver on your Maneuver dial with a speed of 3 or less.  Treat this maneuver as a red maneuver.  No ship may be equipped with more than one "Klingon Navigator" Upgrade.	Crew	2	Yes
2/13/2016 0:17:33	72327 - IKS Amar	Non-unique	Klingon Tactical Officer	Klingon	When attacking with your Primary Weapon, during the Modify Attack Dice step, you may disable this card to spend your [EVADE] Token to convert 1 of your [BATTLE STATIONS] results into a [HIT] result.	Crew	3	
2/17/2016 14:59:14	72328 - IRW Jazkal	Non-unique	Reman Bodyguards	Romulan	ACTION: Discard this card to target a ship at Range 1.  When attacking that ship with your Primary Weapon this round, gain +1 attack die and force the defending ship to roll -1 defense die.  No ship may be equipped with more than 1 "Reman Bodyguards" Upgrade.	Crew	5	Yes
2/17/2016 15:00:24	72328 - IRW Jazkal	Unique	Destabilized Relations	Romulan	When attacking a ship at Range 3, if there is another opposing ship within Range 1-2 of the target ship, the defending ship rolls -2 defense dice against your attack.	Talent	5	
2/17/2016 15:01:47	72328 - IRW Jazkal	Unique	Nijil	Romulan	Add 1 [TECH] Upgrade to your Upgrade Bar.  That Upgrade costs -1 SP (min 1) and must be a Romulan [TECH] Upgrade.  ACTION: When defending this round, during the Roll Defense Dice step, disable this card and one of your [TECH] Upgrades to roll +1 defense die.	Crew	5	Yes
2/17/2016 15:04:03	72328 - IRW Jazkal	Non-unique	Prototype Cloaking Device	Romulan	ACTION: Disable this card to perform the [CLOAK] Action as a free Action, even if you have no Active Shields.  Roll 1 attack die.  On a [BATTLE STATIONS] result, your Hull sustains 1 Damage.  While your ship is Cloaked, you may perform the [SENSOR ECHO] Action.  This Upgrade costs +5 SP for any non-Romulan ship and no ship may be equipped with more than 1 "Prototype Cloaking Device" Upgrade.	Tech	4	Yes
2/24/2016 14:03:14	72316p - USS Constellation	Unique	Standby Battle Stations	Federation	During the Combat Phase, you may discard this card to replace 1 Token that is beside your ship ([EVADE] or [SCAN]) with a [BATTLE STATIONS] Token.  This card may only be purchased for a ship that has the [BATTLE STATIONS] icon on its Action Bar.	Talent	4	Yes
2/24/2016 14:04:11	72316p - USS Constellation	Non-unique	Damage Control Party	Federation	ACTION: Discard this card to repair 1 damage to your ship's Hull or Shields.  OR  ACTION: Disable this card to flip one Critical Damage Card that is assigned to your ship face down.	Crew	5	
2/24/2016 14:06:59	72316p - USS Constellation	Non-unique	Automated Distress Beacon	Federation	You may fill a [CREW], [TECH] or [WEAPON] Upgrade slot with this card.  No ship may be equipped with more than 1 "Automated Distress Beacon" Upgrade.  ACTION: Discard this card to target a ship that is not within Range 1-3 of your ship.  The target ship immediately performs an additional maneuver with a speed of 2 (straight, bank or turn).	?	3	Yes
2/24/2016 14:08:10	72316p - USS Constellation	Non-unique	Auxiliary Control Room	Federation	You may fill a [TECH] or [WEAPON] Upgrade slot with this card.  No ship may be equipped with more than 1 "Auxiliary Control Room" Upgrade.  You may disable this card to perform an Action while there is an Auxiliary Power Token beside your ship.	?	5	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
2/13/2016 0:09:49	72327 - IKS Amar	Non-unique	Klingon	1	Klingon		0	0		
2/13/2016 0:10:36	72327 - IKS Amar	Unique	Barak	3	Klingon	When attacking with Photon Torpedoes, you may discard the Photon Torpedoes Upgrade to gain +1 attack die for that attack.	0	2		
2/17/2016 14:54:51	72328 - IRW Jazkal	Non-unique	Romulan	1	Romulan		0	0		
2/17/2016 14:55:42	72328 - IRW Jazkal	Unique	Vrax	3	Romulan	You may deploy the "Reman Bodyguards" Upgrade to your ship at a cost of -2 SP, even if it exceeds your ship's restrictions.	1	2	Yes	
2/24/2016 14:00:22	72316p - USS Constellation	Non-unique	Federation	1	Federation		0	0		
2/24/2016 14:01:34	72316p - USS Constellation	Unique	Matt Decker	3	Federation	If this card is assigned to a Federation ship, during the Roll Attack Dice step, you may disable this card to gain +1 attack die for that attack.  If you ship is destroyed, you may immediately target a friendly ship within Range 1-2 of your ship.  If you do so, discard the Captain Card from the target ship.  This card becomes the new Captain Card for that ship.	1	2		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
2/13/2016 0:12:20	72327 - IKS Amar	Non-unique	Photon Torpedoes	Klingon	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
2/13/2016 0:13:17	72327 - IKS Amar	Non-unique	Stand By Torpedoes	Klingon			You may disable t his card instead of spending your Target Lock when attacking with Photon Torpedoes.  No Ship may be equipped with more than one "Stand By Torpedoes" Upgrade.	3	Yes
2/17/2016 14:57:26	72328 - IRW Jazkal	Non-unique	Disruptor Banks	Romulan	3	1-3	ATTACK: Place 3 Time Tokens on this card to perform this attack from your forward firing arc.  OR  When defending, during the Roll Attack Dice step, you may discard this card to force your opponent to roll -2 attack dice.  No ship may be equipped with more than one "Disruptor Banks" Upgrade.	4	Yes
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
