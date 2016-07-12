require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
5/26/2016 14:15:46	72006 - Cube 384/Sphere 936	Unique	I Am the Borg	Borg	ACTION: Discard this card to perform this Action.  All friendly ships within Range 1-2 of your ship gain +1 attack die this round when attacking.  This Upgrade may only be assigned to the Borg Queen.	Talent	3	Yes
5/26/2016 14:17:08	72006 - Cube 384/Sphere 936	Unique	Temporal Vortex	Borg	When defending, during the Compare Results step, you may discard this card and spend 3 of your Drone Tokens to force the attacking ship to redo its attack.  All of the dice (attack and defense) are rolled again.  All cards and tokens that were used in the original attack remain used and cannot be used in the second attack.  This Upgrade may only be purchased for a Borg ship.	Tech	5	Yes
5/26/2016 14:19:58	72006 - Cube 384/Sphere 936	Unique	Borg Support Vehicle Dock	Borg	This Upgrade may only be purchased for a Borg Cube.  At the start of the game, place a Borg Support Vehicle Token (BSVT) on one ship in your fleet.  ACTION: If all of your ship's shields have been destroyed, you may discard this card and spend 1 Drone Token to make your support ship Active.  Place an Auxiliary Power Token beside your ship.  Your ship cannot attack this round.	Borg	0	Yes
6/15/2016 17:10:38	72319g - USS Enterprise-A	Unique	Leonard McCoy	Federation	During the Activation Phase, after you move, you may discard this card to perform the Action listed on your ship's Captain Card as a free Action.	Crew	4	
6/15/2016 17:11:41	72319g - USS Enterprise-A	Unique	Valeris	Federation	After your ship executes a green maneuver, you may perform an [EVADE] Action as a free Action.	Crew	3	
6/15/2016 17:12:36	72319g - USS Enterprise-A	Non-unique	Isolation Door	Federation	ACTION: Discard this card to flip over all critical damage assigned to your ship and then repair 1 damage to your ship's Hull.  No ship may be equipped with more than one "Isolation Door" Upgrade.	Tech	3	Yes
6/17/2016 11:11:02	72319p - HMS Bounty	Unique	Montgomery Scott	Federation	Add 1 Upgrade slot to your Upgrade Bar ([TECH] or [WEAPON]).  At any time, you may disable this card to remove an Auxiliary Power Token from beside your ship.	Crew	4	Yes
6/17/2016 11:11:59	72319p - HMS Bounty	Unique	Pavel Chekov	Federation	At the end of the Activation Phase, you may disable this card an place an Auxiliary Power Token beside your ship to flip up to 2 of your disabled Shield Tokens (red) back to their Active sides (blue).	Crew	4	
6/17/2016 11:13:08	72319p - HMS Bounty	Unique	Nyota Uhura	Federation	At the start of the Combat Phase, you may discard this card to target all opposing ships within Range 1 of your ship.  Each target ship must either discard a Token ([EVADE], [SCAN], or [BATTLE STATIONS]) that is beside it or place an Auxiliary Power Token beside it.	Crew	5	
6/17/2016 11:14:07	72319p - HMS Bounty	Unique	Hikaru Sulu	Federation	If you execute a red maneuver, you may disable this card instead of placing an Auxiliary Power Token beside your ship.	Crew	3	
6/22/2016 23:35:33	72320p - USS Cairo	Non-unique	Delta Shift	Federation	This Upgrade may be assigned to any ship without requiring an Upgrade slot.  When one of your [CREW] Upgrades is supposed to be disabled or discarded, you may discard this card instead.  No ship may be equipped with more than one "Delta Shift" Upgrade.	?	5	Yes
6/22/2016 23:36:18	72320p - USS Cairo	Non-unique	Deuterium Tank	Federation	You may disable this card just before you move to treat a red maneuver as a white maneuver.	Tech	3	
6/22/2016 23:37:09	72320p - USS Cairo	Unique	Task Force	Federation	ACTION: Choose a faction.  All friendly ships within Range 1-2 of your ship gain +1 attack die and roll +1 defense die against ships of that faction for this round.	Talent	5	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
5/26/2016 14:13:00	72006 - Cube 384/Sphere 936	Unique	Borg Queen	6	Borg	At the start of the game, place 6 Drone Tokens on this card.  ACTION: Target a ship at Range 1 and spend 2 of your Drone Tokens.  Disable 1 [CREW] Upgrade on the target ship (your choice) and steal it even if it exceeds your ship's restrictions.	1	4		
5/26/2016 14:13:21	72006 - Cube 384/Sphere 936	Non-unique	Drone	1	Borg	At the start of the game, place 1 Drone Token on this card.	0	0		
5/26/2016 14:14:32	72006 - Cube 384/Sphere 936	Non-unique	Tactical Drone	4	Borg	At the start of the game, place 4 Drone Tokens on this card.  ACTION: Spend 2 of your Drone Tokens to target a ship at Range 1-2.  Discard 1 [EVADE], 1 [SCAN], or 1 [BATTLE STATIONS] Token from beside that ship.  Place a [SCAN] Token beside your ship.	0	3		
6/15/2016 17:07:52	72319g - USS Enterprise-A	Non-unique	Federation	1	Federation		0	0		
6/15/2016 17:09:24	72319g - USS Enterprise-A	Unique	James T. Kirk	9	Federation	ACTION: Place a [BATTLE STATIONS] Token beside your ship.  When attacking this round, during the Modify Attack Dice step,  you may spend this Token to re-roll up to 2 of your attack dice OR when defending this round, during the Modify Defense Dice step,  you may spend this Token to re-roll up to 2 of your defense dice.  You may still perform the [BATTLE STATIONS] Action as a free Action this round, if possible.	1	6		
6/17/2016 11:08:25	72319p - HMS Bounty	Non-unique	Federation	1	Federation		0	0		
6/17/2016 11:09:32	72319p - HMS Bounty	Unique	James T. Kirk	8	Federation	All of your Federation [CREW] Upgrades cost -1 SP.  Whenever one of your [CREW] Upgrades is supposed to be disabled, you may place 3 Time Tokens on that Upgrade instead.	1	5	Yes	
6/22/2016 23:25:41	72320p - USS Cairo	Non-unique	Federation	1	Federation		0	0		
6/22/2016 23:27:29	72320p - USS Cairo	Unique	Edward Jellico	6	Federation	At any time, you may disable 1 of your [TECH] or [WEAPON] Upgrades to place 1 [EVADE], [SCAN], or [BATTLE STATIONS] Token beside your ship.  You may only use this ability once per round.	1	4		
7/10/2016 20:51:56	72321p - IRW Rateg	Unique	Tal	4	Romulan	If this card is assigned to a Romulan ship, when attacking at Range 1 with your Primary Weapon, during the Roll Attack Dice step, gain +1 attack die.	1	3		
7/10/2016 20:52:35	72321p - IRW Rateg	Non-unique	Romulan	1	Romulan		0	0		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
6/15/2016 16:52:28	72319g - USS Enterprise-A	Non-unique	Torpedo Bay	Federation			Add 1 [WEAPON] Upgrade slot to your Upgrade Bar.  This Upgrade must be filled with a Photon Torpedoes Upgrade.  When placing Time Tokens on one of your Photon Torpedoes Upgrades, if there are no Time Tokens on this card, you may place them on this card instead.	2	Yes
6/22/2016 23:34:09	72320p - USS Cairo	Non-unique	High Yield Photon Torpedoes	Federation	6	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform tis attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.	6	
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
