require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
11/4/2014 18:49:10	71512 - Assimilated Vessel 80279	Non-unique	Vinculum	Borg	ACTION: Disable this card to repair 1 damage to your Hull or Shields.  OR  ACTION: Disable this card to target your ship and every friendly Borg ship within Range 1-2 of your ship.  Add 1 Drone Token to every target ship's Captain Card.  No ship can exceed its Captain's starting number of Drone Tokens.	Borg	5	
11/4/2014 18:50:20	71512 - Assimilated Vessel 80279	Non-unique	Data Node	Borg	At the start of the game, place 3 Mission Tokens on this card.  Each time you defend, during the Roll Attack Dice step, you may discard 1 Mission Token from this card to force your opponent to roll -1 attack die.  No ship may be equipped with more than 1 "Data Node" [TECH] Upgrade.	Tech	3	Yes
11/4/2014 18:52:08	71512 - Assimilated Vessel 80279	Unique	Warrior Spirit	Klingon	When attacking, at the end of the Deal Damage step, you may discard this card to roll 2 attack dice.  Each [HIT] or [CRIT] result damage the defending ship as normal.  For each blank or [BATTLE STATIONS] result, your ship suffers 1 normal damage to its Hull.  This roll cannot be modified and the defending ship does not roll defense dice against this damage.  This Upgrade may only be purchased for a Klingon Captain.	Talent	4	Yes
11/4/2014 18:53:06	71513a - Tactical Cube 001	Non-unique	Borg Tractor Beam	Borg	ACTION: Target a ship at Range 1.  Place one white Borg Tractor Beam Token beside that ship and the corresponding green Borg Tractor Beam Token (the one that matches the white token's letter) beside your ship.	Borg	7	
11/4/2014 18:54:05	71513a - Tactical Cube 001	Unique	Command Interface	Borg	After you roll a die, for any reason, you may discard this card to re-roll that die once.  This Upgrade costs +5 SP if purchased for any non-borg ship.	Talent	5	Yes
11/4/2014 18:55:28	71513a - Tactical Cube 001	Non-unique	Borg Maturation Chamber	Borg	ACTION: Discard this card to add a number of Drone Tokens to your Captain Card until you reach your Captain's starting number of Drone Tokens.  You cannot exceed your Captain's starting number of Drone Tokens.	Borg	6	
11/4/2014 18:57:23	71513a - Tactical Cube 001	Non-unique	Interplexing Beacon	Borg	When attacking a ship at Range 3, during the Modify Attack Dice step, you may disable this card and spend up to 2 Drone Tokens to re-roll a number of your attack dice equal to the number of Drone Tokens you spent with this card.  No ship may be equipped with more than one "Interplexing Beacon" Upgrade.	Borg	3	Yes
11/4/2014 18:59:02	71513a - Tactical Cube 001	Unique	Data	Borg	ACTION: Target a ship at Range 1-2 and spend 1 Drone Token to disable the Captain Card on that ship.  Then place a [SCAN] Token beside your ship as a free Action.	Crew	4	
11/4/2014 19:07:17	71529 - I.S.S. Defiant	Non-unique	Multi-Targeting Phaser Banks	Mirror Universe	When you perform a [TARGET LOCK] Action, you may disable this card to acquire a 2nd target lock on a different enemy ship within Range 1-3 of your ship.  While you have this Upgrade on your ship, you may have up to 2 different enemy ships target locked at the same time.	Tech	5	
11/4/2014 19:44:41	71532 - Chang's Bird of Prey	Unique	Azetbur	Klingon	ACTION: Discard this card to target a ship at Range 1-3.  Disable your Captain Card and the Captain Card on the target ship.  Neither of your ships may attack each other this round.	Crew	5	
11/4/2014 19:46:58	71532 - Chang's Bird of Prey	Unique	Prototype Cloaking Device	Klingon	When attacking while Cloaked, you may disable this card before rolling any dice to keep your [CLOAK] Token from flipping to its red side.  If you do this, during the Modify Attack Dice step of the Combat Phase, you may place an Auxiliary Power Token beside your ship to choose any number of your attack dice and re-roll them.  This Upgrade may only be purchased for a Klingon Bird-of-Prey class ship.	Tech	6	
11/4/2014 19:50:10	71532 - Chang's Bird of Prey	Unique	The Game's Afoot	Klingon	If you initiate an attack, while Cloaked, against a ship that does not have your ship in its forward or rear firing arcs, during the Roll Attack Dice step of the Combat Phase, you may discard this card to gain +1 attack die against that ship for that attack.  If you do this, after you complete your attack, you may immediately perform a [SENSOR ECHO] Action as a free Action.	Talent	4	
11/4/2014 19:51:26	71532 - Chang's Bird of Prey	Unique	Cry Havoc	Klingon	ACTION: If you are Cloaked, discard this card to remove your [CLOAK] Token and flip all of your Shields back to their Active sides.  You are no longer considered to be Cloaked.  During the Roll Attack Dice step of the Combat Phase, gain +2 attack dice this round.  You cannot roll defense dice this round.  This Upgrade may only be purchased for a Klingon Captain.	Talent	5	Yes
11/4/2014 19:52:43	71529 - I.S.S. Defiant	Mirror Universe Unique	Jennifer Sisko	Mirror Universe	Add 1 [TECH] Upgrade slot to your Upgrade Bar.  At the start of the game, after Setup, target 1 enemy ship anywhere in the play area and disable up to 2 Upgrades of your choice on that ship.	Crew	3	Yes
11/4/2014 19:53:47	71529 - I.S.S. Defiant	Mirror Universe Unique	Ezri Tigan	Mirror Universe	ACTION: Discard this card to target a ship at Range 1-3.  Steal 1 [TECH] Upgrade from the target ship with an SP cost of 5 or less, even if it exceeds your ship's restrictions.  Place a Disabled Upgrade Token on the stolen Upgrade.	Crew	4	
11/4/2014 19:54:41	71529 - I.S.S. Defiant	Mirror Universe Unique	Rom	Mirror Universe	ACTION: Discard this card to target a ship at Range 1-3.  Disable up to 2 [TECH] Upgrades of your choice on the target ship.  This ability may be used against a ship that is Cloaked.	Crew	2	
11/4/2014 19:56:14	71529 - I.S.S. Defiant	Unique	Rebellion	Mirror Universe	If you are defending against a ship that has a greater Hull Value than your ship's Hull Value, during the Roll Attack Dice step of the Combat Phase, you may discard this card to force that ship to roll -2 attack dice for that attack.  After that ship's attack is completed, you may immediately make 1 free attack against that ship with your Primary Weapon, if possible.	Talent	5	
11/4/2014 19:57:18	71529 - I.S.S. Defiant	Unique	Strafing Run	Mirror Universe	ACTION: If you performed a Maneuver with a number of 3 or greater this round, target an enemy ship within Range 1-3 that is not in your firing arc.  Discard this card to immediately make 1 free attack against that ship with 4 attack dice.  Treat this attack as if it was fired with a Primary Weapon.	Talent	5	
11/4/2014 19:58:22	71529 - I.S.S. Defiant	Mirror Universe Unique	Julian Bashir	Mirror Universe	ACTION: Discard this card to target a ship at Range 1-3.  If that ship attacks this round, it must attack your ship and cannot attack any other ship.  If it does attack your ship, during the Roll Attack Dice step of the Combat Phase, that ship rolls -2 attack dice.	Crew	2	
11/4/2014 19:58:52	71529 - I.S.S. Defiant	Mirror Universe Unique	Jadzia Dax	Mirror Universe	When your ship suffers damage to its Hull, you may discard this card to reduce the damage by 1.	Crew	2	
11/4/2014 20:00:00	71533 - Scimitar	Non-unique	Reman Boarding Party	Romulan	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Discard this card and disable all Upgrades on the target ship.	Crew	4	
11/4/2014 20:01:19	71533 - Scimitar	Unique	Target Weapons Systems	Romulan	If you damage an opponent's Hull with a [CRIT], you may immediately discard this card to search the Damage Deck for a "Munitions Failure" or a "Weapons Malfunction" card instead of drawing a random Damage Card.  Re-shuffle the Damage Deck when you are done.	Talent	3	
11/4/2014 20:02:23	71533 - Scimitar	Unique	Attack Pattern Shinzon Theta	Romulan	During the Deal Damage step of the Combat Phase, if you hit your opponent's ship, you may discard this card to add 1 additional damage to that ship's Shields (if possible) for every uncancelled [CRIT] result.	Talent	5	
11/4/2014 20:03:09	71533 - Scimitar	Unique	Full Stop	Romulan	During the Activation Phase, after you reveal your chosen Maneuver, you may discard this card to ignore that Maneuver and not move.  You may still take an Action during the Perform Actions step.	Talent	3	
11/4/2014 20:04:55	71533 - Scimitar	Non-unique	Secondary Shields	Romulan	At the start of the game, place 3 Shield Tokens on this card.  During each End Phase, if you have fewer total Shields (Active and/or Disabled) than your starting Shield Value, remove 1 Shield from this card and add it to your ship.  If you ship is Cloaked, you may choose to add the extra Shield as a Disabled Shield.  This Upgrade may only be purchased for a Reman Warbird.	Tech	6	Yes
11/4/2014 20:06:04	71533 - Scimitar	Non-unique	Improved Cloaking Device	Romulan	If you have the [CLOAK] icon on your Action Bar, you may perform a [CLOAK] Action even if you have no Active Shields and/or if there is an Auxiliary Power Token beside your ship.  This Upgrade costs +5 SP for any ship other than a Reman Warbird.	Tech	5	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
11/4/2014 17:51:41	71529 - I.S.S. Defiant	Mirror Universe Unique	Miles O'Brien	5	Mirror Universe	Add 1 [TECH] Upgrade to your Upgrade Bar.  ACTION: Repair 1 Damage to your Hull or Shields.	1	3	Yes
11/4/2014 17:52:51	71529 - I.S.S. Defiant	Mirror Universe Unique	Benjamin Sisko	4	Mirror Universe	During the Roll Attack Dice step of the Combat Phase, you may discard up to 2 of your Upgrades ([CREW], [TECH] or [WEAPON]).  If you do so, gain +1 attack die to that attack for each Upgrade you discarded with this card.	1	2	
11/4/2014 17:53:51	71529 - I.S.S. Defiant	Non-unique	Mirror Universe	1	Mirror Universe		0	0	
11/4/2014 17:55:37	71533 - Scimitar	Unique	Viceroy	5	Romulan	At the start of the game, place 2 Mission Tokens on this card.  During the Planning Phase, after all other ships have chosen their Maneuvers, you may discard 1 of the Mission Tokens from this card to target a ship at Range 1, look at that ship's Maneuver dial, and then select your Maneuver.  The target ship cannot change its chosen Maneuver after you look at it.	0	3	
11/4/2014 17:57:27	71533 - Scimitar	Unique	Shinzon	9	Romulan	During the Gather Forces step of Setup, instead of purchasing an [ELITE TALENT] Upgrade as normal for Shinzon, you may spend 4 SP to place up to 4 Romulan [ELITE TALENT] Upgrades face down beside this card.  These cards remain face down until you decide to use one of them.  When you do so, select the one you want to use and turn it face up for the rest of the game.  Then discard the other 3.	1	6	Yes
11/4/2014 17:59:34	71532 - Chang's Bird of Prey	Unique	Chang	7	Klingon	During the Activation Phase, if your ship is Cloaked, before you move you may perform an additional [SENSOR ECHO] Action (with a 1 [STRAIGHT] Maneuver Template) as a free Action.  If you do so, you may still perform a normal [SENSOR ECHO] Action after you move, during the Perform Actions step.	1	4	
11/4/2014 17:59:48	71532 - Chang's Bird of Prey	Non-unique	Klingon	1	Klingon		0	0	
11/4/2014 18:01:14	71532 - Chang's Bird of Prey	Unique	Kerla	3	Klingon	Each time you defend, during the Roll Defense Dice step of the Combat Phase, you may choose to roll 2 less defense dice to add 1 [EVADE] result to your roll.	0	2	
11/4/2014 18:02:32	71513a - Tactical Cube 001	Unique	Borg Queen	9	Borg	At the start of the game, place 9 Drone Tokens on this card.  Add 1 [BORG] Upgrade slot to your Upgrade Bar.  ACTION: Target a ship at Range 1 and spend 6 Drone Tokens.  Disable 2 Upgrades of your choice on the target ship.	1	6	Yes
11/4/2014 18:02:58	71513a - Tactical Cube 001	Non-unique	Drone	1	Borg	At the start of the game, place 1 Drone Token on this card.	0	0	
11/4/2014 18:04:05	71512 - Assimilated Vessel 80279	Unique	Korok	6	Klingon	When you initiate an attack against a ship at Range 1, at the start of the Deal Damage step of the Combat Phase, disable 1 Active Shield on the target ship (if possible).	1	4	
11/4/2014 18:05:02	71512 - Assimilated Vessel 80279	Unique	Korok	6	Borg	At the start of the game, place 6 Drone Tokens on this card.  When you inflict damage to an opponent's Hull, during the Deal Damage step, you may spend 1 Drone Token to convert 1 Normal Damage into 1 Critical Damage.	0	4	
11/4/2014 22:55:01	71533 - Scimitar	Non-unique	Romulan	1	Romulan		0	0	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
11/4/2014 18:36:47	71529 - I.S.S. Defiant	Non-unique	Quantum Torpedoes	Mirror Universe	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  If the target ship is hit, add 1 [HIT] result to your total damage.  You may fire this weapon from your forward or rear firing arcs.	6	
11/4/2014 18:37:30	71529 - I.S.S. Defiant	Non-unique	Aft  Phaser Emitter	Mirror Universe	3	1-3	ATTACK: Disable this card to perform this attack.  You may only fire this weapon from your rear firing arc.	1	
11/4/2014 18:38:49	71532 - Chang's Bird of Prey	Non-unique	Photon Torpedoes	Klingon	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into a [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
11/4/2014 18:41:15	71533 - Scimitar	Unique	Thalaron Weapon	Romulan	10	2-3	ATTACK: Discard this card to perform this attack.  Instead of inflicting normal damage, for each uncancelled [HIT] or [CRIT] result, discard the Captain Card or 1 [CREW] Upgrade (opponent's choice) on the target ship.  If the Captain and all of the [CREW] Upgrades on the target ship are destroyed, any additional uncancelled [HIT] or [CRIT] results damage the ship as normal (max 5 damage).  This Upgrade may only be purchased for a Reman Warbird.	10	Yes
11/4/2014 18:43:37	71513a - Tactical Cube 001	Non-unique	Cutting Beam	Borg	10	1	ATTACK: You must have the target ship held in a Borg Tractor Beam (i.e., the target ship must have a white Borg Tractor Beam Token beside its ship and you must have the corresponding green Borg Tractor Beam Token beside your ship) and disable this card to perform this attack.  This Upgrade may only be purchased for a Borg ship.	8	
11/4/2014 18:44:59	71513a - Tactical Cube 001	Non-unique	Borg Missile	Borg	4	1-2	ATTACK: Disable this card to perform this attack.  The target ship does not sustain normal damage from this attack.  Instead, place 1 Auxiliary Power Token beside the target ship AND destroy 1 of its Active Shields for each [HIT] or [CRIT] result.  The target ship does not roll defense dice against this attack.  This Upgrade may only be purchased for a Borg ship.	6	
11/4/2014 18:46:34	71512 - Assimilated Vessel 80279	Non-unique	Photon Torpedoes	Klingon	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may change one of your [BATTLE STATIONS] results to a [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
11/4/2014 20:07:38	71533 - Scimitar	Non-unique	Photon Torpedoes	Romulan	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  If fired from a Reman Warbird, gain +2 attack dice.  You may fire this weapon from your forward or rear firing arcs.	6	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
11/4/2014 20:18:04	71532 - Chang's Bird of Prey	Unique	Gorkon	Klingon	FLEET ACTION: Roll 3 defense dice. For each [EVADE] result, place 1 [EVADE] Token beside your ship. You cannot perform an [EVADE] Action as a free Action this round.	1	0	3	4	ACTION: Roll 3 defense dice. For each [EVADE] result, place 1 [EVADE] Token beside your ship. You cannot perform an [EVADE] Action as a free Action this round.	0	3	
11/4/2014 20:19:02	71533 - Scimitar	Unique	Hiren	Romulan	FLEET ACTION: Disable 1 of your [CREW] Upgrades to gain +1 attack die this round.	1	0	1	2	ACTION: Disable 1 of your [CREW] Upgrades to gain +1 attack die this round.	0	1	
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
