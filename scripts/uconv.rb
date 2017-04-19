require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
3/1/2017 15:02:02	72225p - USS Defiant NCC-1764	Mirror Universe Unique	Charles Tucker III	Mirror Universe	ACTION: Disable this card to remove up to 2 Disabled Upgrade Tokens or up to 4 Time Tokens from any of your [TECH] or [WEAPON] Upgrades.	Crew	4	
3/1/2017 15:02:59	72225p - USS Defiant NCC-1764	Mirror Universe Unique	T'Pol	Mirror Universe	ACTION: Discard this card to target a ship within Range 1-3.  Disable 1 [CREW] Upgrade and/or 1 [TECH] or [WEAPON] Upgrade on the target ship.	Crew	4	
3/1/2017 15:04:10	72225p - USS Defiant NCC-1764	Non-unique	Assault Team	Mirror Universe	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Discard this card to place 2 Time Tokens on all Upgrades on the target ship that do not already have Time Tokens on them.	Crew	5	
3/3/2017 10:51:41	72335 - Muratas	Non-unique	Reptilian Analysis Team	Xindi	Add 1 [TECH] Upgrade to your Upgrade Bar.  When you are supposed to disable a [TECH] Upgrade, you may disable this card instead and place 3 Time Tokens on the [TECH] Upgrade (2 Time Tokens if it is a Xindi [TECH] Upgrade).  This Upgrade may only be purchased for a Xindi ship and no ship may be equipped with more than one "Reptilian Analysis Team" Upgrade.	Crew	5	Yes
3/3/2017 10:53:11	72335 - Muratas	Non-unique	Thermal Chamber	Xindi	ACTION: Remove all Disabled Upgrade Tokens from all of your Xindi [CREW] Upgrades and add +4 to your Captain Skill number for this round.  This Upgrade may only be purchased for a Xindi-Reptilian warship.	Tech	3	Yes
3/3/2017 10:54:36	72335 - Muratas	Non-unique	Sensor Encoders	Xindi	When defending, you may disable this card to re-roll 1 of your defense dice.  If a friendly ship is destroyed, you may discard this card.  If you do so, your ship gains +1 Agility for the rest of the game.  This Upgrade may only be purchased for a Xindi-Reptilian warship and no ship may be equipped with more than one "Sensor Encoders" Upgrade.	Tech	3	Yes
3/3/2017 10:55:32	72335 - Muratas	Unique	Patience is for the Dead	Xindi	At the start of the Combat Phase, before any ships have attacked, you may discard this card to attack before all other ships.  You cannot roll any defense dice during the round you use this ability.	Talent	5	
3/29/2017 15:45:02	72226p - Delta Flyer II	Unique	B'Elanna Torres	Federation	If your ship ends its move overlapping another ship's base, you may discard this card to perform an Action from your ship's Action Bar.	Crew	3	
3/29/2017 15:46:34	72226p - Delta Flyer II	Non-unique	Impulse Thrusters	Federation	ACTION: If your ship executed a [FORWARD] maneuver with a speed of 3 or less this round, disable this card to immediately execute an additional 1 [FORWARD] maneuver.  No ship may be equipped with more than one "Impulse Thrusters" Upgrade.	Tech	4	Yes
3/29/2017 15:47:19	72226p - Delta Flyer II	Unique	Quick Thinking	Federation	ACTION: Discard this card to immediately perform a [SENSOR ECHO] Action, even if your ship is not cloaked.	Talent	5	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
3/1/2017 14:59:56	72225p - USS Defiant NCC-1764	Non-unique	Mirror Universe	1	Mirror Universe		0	0		
3/1/2017 15:00:59	72225p - USS Defiant NCC-1764	Mirror Universe Unique	Jonathan Archer	6	Mirror Universe	When attacking, during the Compare Results step, you may place an Auxilliary Power Token beside your ship to convert 1 of your [CRIT] results into 2 [HIT] results.	1	4		
3/3/2017 10:43:38	72335 - Muratas	Non-unique	Xindi	1	Xindi		0	0		
3/3/2017 10:44:52	72335 - Muratas	Unique	Dolim	8	Xindi	During the Gather Forces step, you may treat any of the [CREW] or [TECH] Upgrade slots on your Upgrade Bar as [WEAPON]  Upgrade slots.  All of your [WEAPON] Upgrades cost -1 SP (-5 max).	1	5	Yes	
3/3/2017 10:46:15	72335 - Muratas	Unique	Degra	4	Xindi	When attacking with a Secondary [WEAPON] Upgrade, gain +1 attack die (+2 attack dice if the attack is made with a Xindi [WEAPON] Upgrade).	0	3		
3/29/2017 15:36:38	72226p - Delta Flyer II	Non-unique	Federation	1	Federation		0	0		
3/29/2017 15:37:56	72226p - Delta Flyer II	Unique	Tom Paris	4	Federation	If this card is assigned to a ship with a Hull value of 2 or less, whenever your ship executes a red maneuver, treat it as a white maneuver instead.  If this card is assigned to a shuttlecraft, you cannot perform a "Docking" Action on the round you use this ability.	1	3		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
3/1/2017 15:05:56	72225p - USS Defiant NCC-1764	Non-unique	Aft Photon Torpedoes	Federation	4	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into a [CRIT] result.  You may only target a ship that is not in your forward firing arc with this attack.	4	
3/3/2017 10:48:37	72335 - Muratas	Non-unique	Particle Beam Weapon	Xindi		1-3	ATTACK: The Attack Value of this weapon is equal to the ship's Primary Weapon Value +1.  This Upgrade may only be purchased for a Xindi ship and the S P cost is equal to the ship's Primary Weapon Value.	1	Yes
3/3/2017 10:49:42	72335 - Muratas	Non-unique	Xindi Torpedoes	Xindi	4	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  If fired from a Xindi-Reptilian warship, add +1 attack die.	3	
3/29/2017 15:44:03	72226p - Delta Flyer II	Non-unique	Pulse Phased Weapons	Federation	3	1	ATTACK: Place 3 Time Tokens on this card to perform this attack.  Make 2 separate attacks with this weapon.  These attacks are defended against separately and may be used against different ships.  You may only fire this weapon from your forward firing arc and may not increase the number of dice rolled in your attack.	5	
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
