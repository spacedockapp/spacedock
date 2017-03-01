require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
12/15/2016 15:05:54	72325p - IKS Toral	Unique	Lursa	Klingon	You may perform a [CLOAK] or [SENSOR ECHO] Action as a free Action (if your ship has the appropriate Action on its Action Bar).  If B'Etor is the Captain of your ship, you may fill one of your [CREW] Upgrade slots with this card and gain +4 to your Captain Skill.	Crew	3	Yes
12/15/2016 15:08:15	72325p - IKS Toral	Unique	B'Etor	Klingon	A friendly ship within Range 1-2 of your ship may use the Action or ability on your [ELITE TALENT] Upgrade as if it were assigned to that ship.  If Lursa is the Captain of your ship, you may fill one of your [CREW] Upgrade slots with this card and gain +4 to your Captain Skill.	Crew	3	Yes
12/15/2016 15:10:14	72325p - IKS Toral	Unique	Enemy of the Empire	Klingon	When attacking, during the Roll Attack Dice step, you may discard this card to gain +1 attack die.  If the defending ship is a Klingon ship or a ship with a Klingon Captain or Upgrade assigned to it, disable this card instead of discarding it.	Talent	5	
12/15/2016 15:12:01	72325p - IKS Toral	Unique	Interrogation	Klingon	When attacking, during the Roll Attack Dice step, you may discard this card to gain a number of attack dice equal to 1 plus the number of Upgrades on the defending ship (max +3).  This Upgrade may only be fielded by a Klingon Captain assigned to a Klingon ship.	Talent	5	Yes
12/15/2016 15:13:53	72325p - IKS Toral	Unique	Kulge	Klingon	ACTION: Discard this card to disable your Captain Card and place a [BATTLE STATIONS] Token beside your ship.  While your Captain Card is disabled, your Captain Skill is "0" and you may perform the [BATTLE STATIONS] Action as if it was on your Action Bar.	Crew	5	
12/15/2016 15:16:20	72325p - IKS Toral	Non-unique	Aft Shields	Klingon	If you are not Cloaked and defending against an attack from a ship that is not in your forward firing arc, during the Compare Results step, you may discard this card to cancel up to 2 of the attacking ship's [HIT] or [CRIT] results.  If you do so, place an Auxiliary Power Token beside your ship.  No ship may be equipped with more than one "Aft Shields" Upgrade.	Tech	4	Yes
12/15/2016 15:18:40	72325g - Sela's Warbird	Unique	Klingon-Romulan Alliance	Romulan	If your ship is within Range 1-2 of a friendly Klingon or Romulan ship, during the Modify Defense dice step, you may discard this card to re-roll any number of your defense dice.  This card may only be fielded by a Klingon or Romulan Captain assigned to a Klingon or Romulan ship.	Talent	4	Yes
12/15/2016 15:20:03	72325g - Sela's Warbird	Unique	Reverse Course	Romulan	During the Activation Phase, you may disregard your chosen maneuver and execute a Full Astern [REVERSE] Maneuver with a speed of 1 or 2 instead.	Talent	5	
12/15/2016 15:21:04	72325g - Sela's Warbird	Unique	Tokath	Romulan	ACTION: Discard this card to remove 2 Disabled Upgrade Tokens from your other Upgrades.	Crew	2	
12/15/2016 15:23:00	72325g - Sela's Warbird	Non-unique	Tachyon Pulse	Romulan	When defending, during the Roll Defense Dice step, you may disable this card to roll +1 defense die (+2 defense dice if the attacking ship has a [SCAN] Token beside it).  No ship may be equipped with more than one "Taychon Pulse" Upgrade.	Tech	4	Yes
12/23/2016 14:03:11	72338 - Calindra	Unique	Retaltion	Xindi	When another ship in your fleet is destroyed, discard this card to immediately make an attack with your Primary Weapon at -1 attack die.  This attack is in addition to your normal attack for the round.  If there is no ship to target with this additional attack, place a Mission Token on this card instead of discarding it.  If you do this, on your next attack, discard this card to gain +3 attack dice for that attack.  This Upgrade may only be purchased for a Xindi Captain assigned to a Xindi ship.	Talent	5	Yes
12/23/2016 14:04:23	72338 - Calindra	Unique	Raijin	Xindi	ACTION: Discard this card to target a ship at Range 1-3.  Choose 1 Upgrade on the target ship and place 2 Time Tokens on that Upgrade.	Crew	4	
12/23/2016 14:07:43	72338 - Calindra	Non-unique	Trellium-D	Xindi	Place 2 Mission Tokens on this card.  During the Compare Results step, you may discard up to 2 of these Tokens to cancel one [HIT] or [CRIT] result for each Token discarded.  This Upgrade costs +4 SP for any non-Xindi ship and no ship may be equipped with more than one "Trellium-D" Upgrade.	Tech	4	Yes
12/23/2016 14:09:26	72338 - Calindra	Unique	Biometric Hologram	Xindi	When attacking, during the Roll Attack Dice step, you may discard this card to gain +2 attack dice.  If the attack hits, disable all [CREW] Upgrades on the defending ship.  This  Upgrade may only be purchased for a Xindi ship and no ship may be equipped with more than one "Biometric Hologram" Upgrade.	Tech	5	Yes
12/23/2016 14:10:55	72338 - Calindra	Non-unique	Subspace Vortex	Xindi	ACTION: Discard this card to execute an additional 4 [STRAIGHT], 5 [STRAIGHT], or 6 [STRAIGHT] Maneuver.  Place an Auxiliary Power Token beside your ship.  This Upgrade costs +5 SP for any non-Xindi ship.	Tech	5	Yes
1/25/2017 15:06:40	72224p - USS Enterprise-D	Non-unique	Transporter	Federation	ACTION: Disable this card to target a friendly ship within Range 1-2 and disable all remaining Shields on both ships.  Then switch a [CREW] Upgrade between the ships.  No ship may be equipped with more than one "Transporter" Upgrade.	Tech	3	Yes
1/25/2017 15:07:57	72224p - USS Enterprise-D	Unique	Dispersal Pattern Sierra	Federation	When attacking with a Photon Torpedo, during the Declare Target step, you may discard this card to target 2 or 3 different ships in your forward firing arc with the attack.  If you target 2 different ships, each attack is at -1 attack die.  If you target 3 different ships, each attack is at -2 attack dice.	Talent	5	
1/25/2017 15:09:01	72224p - USS Enterprise-D	Unique	Natasha Yar	Federation	Add 2 [WEAPON] Upgrade slots to your Upgrade Bar.  When attacking, during the Modify Attack Dice step, you may place 2 Time Tokens on this card to re-roll up to three of your attack dice.	Crew	4	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
12/15/2016 14:55:06	72325g - Sela's Warbird	Unique	Movar	5	Romulan	During the Gather Forces step, you may switch one of your [CREW], [TECH], or [WEAPON] Upgrade slots on your ship for a [CREW], [TECH], [WEAPON], or [ELITE TALENT] Upgrade slot.	0	3	Yes	
12/15/2016 15:05:12	72325p - IKS Toral	Unique	Lursa	4	Klingon	You may perform a [CLOAK] or [SENSOR ECHO] Action as a free Action (if your ship has the appropriate Action on its Action Bar).  If B'Etor is the Captain of your ship, you may fill one of your [CREW] Upgrade slots with this card and gain +4 to your Captain Skill.	1	3	Yes	
12/15/2016 15:07:26	72325p - IKS Toral	Unique	B'Etor	4	Klingon	A friendly ship within Range 1-2 of your ship may use the Action or ability on your [ELITE TALENT] Upgrade as if it were assigned to that ship.  If Lursa is the Captain of your ship, you may fill one of your [CREW] Upgrade slots with this card and gain +4 to your Captain Skill.	1	3	Yes	
12/15/2016 15:07:42	72325p - IKS Toral	Non-unique	Klingon	1	Klingon		0	0		
12/23/2016 13:59:27	72338 - Calindra	Non-unique	Xindi	1	Xindi		0	0		
12/23/2016 14:00:18	72338 - Calindra	Unique	Aquatic Councilor	2	Xindi	When defending, during the Modify Defense Dice step, you may convert 1 of your [BATTLE STATIONS] results into an [EVADE] result.	0	1		
1/25/2017 15:01:45	72224p - USS Enterprise-D	Non-unique	Federation	1	Federation		0	0		
1/25/2017 15:02:37	72224p - USS Enterprise-D	Unique	Jean-Luc Picard	8	Federation	Your ship costs -2 SP and each Upgrade assigned to your ship costs -1 SP (max -5 SP total).	1	5	Yes	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
12/23/2016 14:05:42	72338 - Calindra	Non-unique	Xindi Torpedoes	Xindi	4	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  If fired from a Xindi Aquatic Cruiser, add +1 attack die.	3	
1/25/2017 15:05:12	72224p - USS Enterprise-D	Non-unique	Aft Phaser Emitters	Federation	*	1-3	ATTACK: You may fire this weapon from your rear firing arc.  The Attack Value is equal to the ship's Primary Weapon Value -1.  This Upgrade may only be purchased for a Federation ship with a Hull Value of 4 or greater and the SP is equal to the ship's Primary Weapon Value.	1	Yes
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
12/15/2016 14:34:33	72325g - Sela's Warbird	Unique	Sela	Romulan	FLEET ACTION: When defending this round, the attacking ship cannot benefit from or spend a [SCAN] Token that is beside it, nor can that ship spend a [BATTLE STATIONS] Token that is beside it against your ship.	1	1	4	7	ACTION: When defending this round, the attacking ship cannot benefit from or spend a [SCAN] Token that is beside it, nor can that ship spend a [BATTLE STATIONS] Token that is beside it against your ship.	1	4	
12/23/2016 13:58:35	72338 - Calindra	Unique	Kiaphet Amman'sor	Xindi	FLEET ACTION: When defending this round, roll +1 defense die.  In addition, if this card is assigned to a Xindi ship, when attacking this round, gain +1 attack die.	1	1	3	4	ACTION: When defending this round, roll +1 defense die.  In addition, if this card is assigned to a Xindi ship, when attacking this round, gain +1 attack die.	1	3	
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
