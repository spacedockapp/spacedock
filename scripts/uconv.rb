require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
12/7/2015 13:45:01	72020 - Robinson	Unique	Infiltration	Federation	ACTION: Discard this card to perform this Action.  If your ship is within Range 1-2 of at least 1 enemy ship, but its not within Range 1-2 of any friendly ships, your ship cannot be attacked or attack this round.	Talent	5	
12/7/2015 13:45:59	72020 - Robinson	Unique	Miles O'Brien	Federation	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Discard this card to inflict 1 damage to the target ship's Hull.	Crew	5	
12/7/2015 13:46:49	72020 - Robinson	Unique	Jadzia Dax	Federation	Yu may disable this card after performing a red maneuver to place an [EVADE] Token beside your ship.	Crew	4	
12/7/2015 13:47:28	72020 - Robinson	Unique	Julian Bashir	Federation	At any time, you may discard this card to re-roll any 1 die.	Crew	4	
12/7/2015 13:48:43	72020 - Robinson	Unique	Nog	Federation	During the Combat Phase, you may disable this card to spend a [SCAN] Token that is beside your ship as though it were an [EVADE] or a [BATTLE STATIONS] Token.	Crew	4	
12/7/2015 13:49:46	72020 - Robinson	Unique	Elim Garak	Federation	At the beginning of the Combat Phase, you may disable this card to add +2 to your Captain Skill Number until the End Phase.  OR  During the Combat Phase, you may discard this card to select up to 3 of your attack or defense dice and re-roll them.	Crew	3	
12/17/2015 13:18:39	72021 - Denorios	Unique	Emissary	Bajoran	At the start of the Activation Phase, you may discard this card to remove all Disabled Upgrade Tokens from all Bajoran Upgrades deployed to all friendly ships within Range 1-3.	Talent	5	
12/17/2015 13:19:41	72021 - Denorios	Unique	Legendary Hero	Bajoran	You may discard this card at the start of the Combat Phase to gain +2 attack dice and +2 defense dice for that round.  This Upgrade may only be purchased for a Bajoran Captain assigned to a Bajoran ship.	Talent	5	Yes
12/17/2015 13:20:51	72021 - Denorios	Unique	D'Jarras	Bajoran	ACTION: Discard this card to target a friendly ship within Range 1-3.  Perform the Action listed on one of that ship's [CREW] Upgrades.  If the [CREW] Upgrade is Bajoran, treat this Action as a free Action.  This Upgrade may only be purchased for a Bajoran Captain assigned to a Bajoran ship.	Talent	5	Yes
12/17/2015 13:22:21	72021 - Denorios	Non-unique	Tachyon Eddies	Bajoran	When you reveal your chosen maneuver, you may disable this card to add up to +3 to that maneuver's speed.  Inflict one damage to your ship if you add +2 to your speed, or inflict 2 damage to your ship if you add +3 to your speed.  This Upgrade may only be purchased for a Bajoran lightship and no ship may be equipped with more than 1 "Tachyon Eddies" Upgrade.	Tech	3	Yes
12/17/2015 13:23:35	72021 - Denorios	Non-unique	Mainsails	Bajoran	At the start of the game, place 2 Shield Tokens on this card.  When your ship suffers damage, remove these tokens first.  You cannot use these tokens to activate any other card abilities.  This Upgrade may only be purchased for a Bajoran lightship and no ship may be equipped with more than 1 "Mainsails" Upgrade.	Tech	4	Yes
12/17/2015 13:24:20	72021 - Denorios	Non-unique	Solar Sail Powered	Bajoran	After you move, you may disable this card to treat any maneuver as a green maneuver.  This Upgrade may only be purchased for a Bajoran lightship.	Tech	3	Yes
12/19/2015 22:55:08	72360 - Weapon Zero	Unique	Degra	Xindi	All of your Xindi [WEAPON] Upgrades cost -1 SP.  When attacking, during the Declare Target step, if your ship does not already have another ship target locked, you may discard this card to acquire a target lock on a ship within Range 1-3 of your ship.	Crew	4	
12/19/2015 22:58:10	72360 - Weapon Zero	Unique	Arming Sequence	Xindi	ACTION: Place 1 Mission Token on this card.  During the Activation Phase of each subsequent round, place 1 additional Mission Token on this card (max 3).  While there are Mission Tokens on this card, your ship cannot perform any Actions and may only execute maneuvers with a speed of 1.  When attacking with a "Destructive Blast" [WEAPON] Upgrade or your Primary Weapon, during the Roll Attack Dice step, you may discard this card to gain a number of attack dice equal to the number of Mission Tokens on this card.  If you do so, discard this card.  This Upgrade may only be purchased for a Xindi Weapon.	Talent	8	Yes
12/19/2015 22:59:46	72360 - Weapon Zero	Unique	Subspace Vortex	Xindi	ACTION: Discard this card to remove your ship from the play area and discard all Tokens that are beside your ship except for Auxiliary Power Tokens.  Immediately place your ship back anywhere in the play area, but not within Range 1-3 of any enemy ship.  You cannot attack during the round you use this Action.  This Upgrade may only be purchased for a Xindi ship.	Tech	6	Yes
12/19/2015 23:01:14	72360 - Weapon Zero	Unique	Self-Destruct	Xindi	ACTION: Target all ships within Range 1 of your ship and destroy your ship.  Each target ship suffers 1 damage and must discard a Token ([EVADE], [SCAN], [BATTLE STATIONS] or [TARGET LOCK]) that is beside it.  This Upgrade may only be purchased for a Xindi Weapon.	Tech	5	Yes
12/25/2015 10:29:06	72315p - IRW T'Met	Unique	Thei	Romulan	During the Activation Phase, after you move, if you have the [CLOAK] Action on your Action Bar, you may discard this card to perform a [CLOAK] Action as a free Action.	Crew	1	
12/25/2015 10:30:32	72315p - IRW T'Met	Unique	Intercept	Romulan	During the Activation Phase, if an opposing ship ends its move within your forward firing arc, before that ship performs its Action, you may discard this card to immediately perform an attack with 3 attack dice against that ship.  The defending ship may roll defense dice against this attack, but the attack dice cannot be modified in any way.	Talent	5	
12/25/2015 10:31:45	72315p - IRW T'Met	Non-unique	Self Repair Technology	Romulan	After your ship performs a green maneuver, you may disable this card to repair 1 damage to your ship's Hull.  This Upgrade may only be purchased for a Romulan ship and no ship may be equipped with more than 1 "Self Repair Technology" Upgrade.	Tech	4	Yes
1/3/2016 15:43:32	72023 - USS Valiant	Unique	Red Squad	Federation	At the start of the game, place a number of Tokens ([EVADE], [SCAN] or [BATTLE STATIONS]) on this card equal to the number of Federation [CREW] Upgrades assigned to your ship (4 max).  During the Activation Phase, before performing your Action, you may remove 1 Token from on top of this card and place it beside your ship.  This Upgrade may only be purchased for a Federation Captain assigned to a Federation ship.	Talent	5	Yes
1/3/2016 15:46:06	72023 - USS Valiant	Unique	Riley Aldrin Shepard	Federation	ACTION: Disable this card to perform an additional green maneuver with a speed of 1.  Your ship cannot be target locked this round.  If there is already a target lock on your ship, remove it.	Crew	5	
1/3/2016 15:47:00	72023 - USS Valiant	Unique	Karen Ferris	Federation	When targeting an opposing ship with a Photon or Quantum Torpedoes secondary weapon you may disable this card instead of spending a Target Lock.	Crew	4	
1/3/2016 15:47:46	72023 - USS Valiant	Unique	Dorian Collins	Federation	If your ship suffers damage to its Hull, you may immediately disable this card to repair 1 Shield.	Crew	2	
1/3/2016 15:48:41	72023 - USS Valiant	Unique	Nog	Federation	ACTION: Disable this card to repair 1 damage to your Hull or Shields.  OR  If you execute a Red Maneuver, you may disable this card after skipping your Perform Action Step to remove 1 Auxiliary Power Token from beside your ship.	Crew	5	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
12/7/2015 13:42:04	72020 - Robinson	Non-unique	Federation	1	Federation		0	0		
12/7/2015 13:43:44	72020 - Robinson	Unique	Benjamin Sisko	8	Federation	Each time your ship suffers 1 or more damage to its Hull, you may roll 1 attack die.  A [HIT] or a [CRIT] damages the attacking ship as normal.  If the result is a [BATTLE STATIONS] result, place a [BATTLE STATIONS] Token beside your ship.  If you choose to roll this die, place an Auxiliary Power Token beside your ship.	1	5		
12/17/2015 13:11:47	72021 - Denorios	Non-unique	Bajoran	1	Bajoran		0	0		
12/17/2015 13:12:20	72021 - Denorios	Unique	Akorem Laan	2	Bajoran	Akorem Laan can field up to 2 Bajoran [ELITE TALENT] Upgrades.	0	1	Yes	
12/19/2015 22:47:17	72360 - Weapon Zero	Non-unique	Xindi	1	Xindi		0	0		
12/19/2015 22:48:50	72360 - Weapon Zero	Unique	Dolim	8	Xindi	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Discard 1 [CREW] Upgrade on the target ship.  Your ship has a Captain Skill of 1 until the End Phase this round.	1	5		
12/25/2015 10:26:56	72315p - IRW T'Met	Non-unique	Romulan	1	Romulan		0	0		
12/25/2015 10:28:03	72315p - IRW T'Met	Unique	Tebok	3	Romulan	During the Gather Forces step, if there is at least one other Romulan ship in your starting fleet, Tebok  may field 1 Romulan [TALENT] Upgrade at a cost of -1 SP.	0	2	Yes	
1/3/2016 15:35:56	72023 - USS Valiant	Non-unique	Federation	1	Federation		0	0		
1/3/2016 15:37:08	72023 - USS Valiant	Unique	Tim Watters	4	Federation	Add 1 [CREW] Upgrade slot to your Upgrade Bar.  ACTION: Remove all Disabled Upgrade Tokens from all of your [CREW] Upgrades.	1	3	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
12/19/2015 23:03:21	72360 - Weapon Zero	Unique	Destructive Blast	Xindi	5	*	ATTACK: Discard this card to perform this attack.  This attack targets all ships in a straight line up to Range 3 from your ship.  Perform one attack against each ship in the line.  Each attack beyond the first is a cumulative -1 attack die (i.e., -1 attack die against the 2nd ship, -2 attack dice against the 3rd ship, etc).  This Upgrade may only be purchased for a Xindi Weapon.	6	Yes
12/19/2015 23:04:17	72360 - Weapon Zero	Non-unique	Rotating Emitters	Xindi	4	1	ATTACK: Disable this card to perform this attack.  You may fire this weapon in any direction.  This Upgrade may only be purchased for a Xindi Weapon.	4	Yes
12/25/2015 10:25:10	72315p - IRW T'Met	Non-unique	Charging Weapons	Romulan			When attacking with your Primary Weapon, you may disable this card to re-roll one of your blank results.  No ship may be equipped with more than one "Charging Weapons" Upgrade.	1	Yes
1/3/2016 15:41:19	72023 - USS Valiant	Non-unique	Photon Torpedoes	Federation	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
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
