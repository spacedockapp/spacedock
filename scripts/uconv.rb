require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
9/29/2014 15:01:31	71511 - Avatar of Tomed	Hive Mind	Borg	"ACTION: Disable this card and any number of your other Upgrades.  Add 1 Drone Token to your Captain Card for each card you disabled with this Action (including this card).  You cannot exceed your Captain's starting number of Drone Tokens.

You cannot deploy more than 1 ""Hive Mind"" [BORG] Upgrade to any ship."	Borg	1	Non-unique	Yes																			
9/29/2014 15:02:31	71511 - Avatar of Tomed	Vox	Borg, Romulan	"After rolling your dice for any reason, you may discard this card to re-roll one of those dice.

OR

After rolling your dice for any reason, you may disable this card and spend 2 of your Drone Tokens to re-roll one of those dice."	Crew	4	Unique																				
9/29/2014 15:03:34	71511 - Avatar of Tomed	Borg Alliance	Romulan	"Add 1 [BORG] Upgrade slot to your Upgrade Bar.

At the start of the game, place 4 Drone Tokens on your Captain card.

This Upgrade may only be purchased for a non-Borg ship with a non-Borg Captain."	Talent	5	Unique	Yes																			
9/29/2014 15:05:18	71531 - U.S.S. Enterprise-E	Advanced Shields	Federation	"ACTION: If you still have Active Shields, place 1 additional Shield Token beside your ship.  If you take damage this round, remove this Shield Token first.  If you do not take damage this round, discard the extra Shield Token during the End Phase.

No ship may be equipped with more than 1 Advanced Shields Upgrade."	Tech	5	Non-unique	Yes																			
9/29/2014 15:06:47	71531 - U.S.S. Enterprise-E	Fire At Will!	Federation	During the Combat Phase, instead of making a normal attack,  you may discard this card to make 1 attack with your Primary Weapon and 1 attack with one of your Secondary Weapons.  Each of these attacks is at -1 attack die and must be made against different enemy ships.	Talent	5	Unique																				
9/29/2014 15:07:28	71531 - U.S.S. Enterprise-E	Make It So	Federation	When performing an Action or Attack that requires you to disable one of your Upgrades, you may discard this card instead of disabling the Upgrade.	Talent	5	Unique																				
9/29/2014 15:08:18	71531 - U.S.S. Enterprise-E	Data	Federation	During the Modify Attack Dice step of the Combat Phase, you may discard this card to force an enemy ship to re-roll its entire attack roll.	Crew	3	Unique																				
9/29/2014 15:09:31	71531 - U.S.S. Enterprise-E	William T. Riker	Federation	"Add 1 [CREW] Upgrade slot to your Upgrade Bar.

After you move, you may disable this card to perform the Action on one of your [CREW], [TALENT], or [TECH] Upgrades or your Captain's Action as a free Action."		5	Unique																				
9/29/2014 15:10:55	71531 - U.S.S. Enterprise-E	Geordi La Forge	Federation	"Add 1 [TECH] Upgrade slot to your Upgrade Bar.

ACTION: Disable this card to target a ship at Range 1-3.  Target ship rolls 2 less defense dice this round (min 0) against all of your ship's attacks.  If the target ship is Cloaked, flip its [CLOAK] Token to its red side."	Crew	4	Unique	Yes																			
9/29/2014 15:11:48	71528 - Val Jean	Tuvok	Independent	During the Combat Phase, after you complete an attack that you initiated, you may disable this card to immediately perform an additional 1 Maneuver (Straight, Bank or Turn).	Crew	3	Unique																				
9/29/2014 15:12:46	71528 - Val Jean	B'Elanna Torres	Independent	Whenever you initiate an attack at Range 3, during the Roll Attack Dice step of the Combat Phase, you may disable this card to gain +1 attack die (or +2 attack dice if this Upgrade is deployed to a ship with a Hull of 3 or less).	Crew	4	Unique																				
9/29/2014 15:13:30	71530 - Queen Vessel Prime	Magnus Hansen	Borg	Whenever you are required to spend any number of Drone Tokens, you may discard this card to spend 1 less Drone Token.	Crew	1	Unique																				
9/29/2014 15:14:54	71530 - Queen Vessel Prime	Resistance Is Futile	Borg	During the Modify Attack Dice step of the Combat Phase, you may discard this card and spend up to 3 of your Drone Tokens to select a number of your attack dice equal to the number of Drone Tokens you spent with this card.  These dice cannot be cancelled during the Compare Results step of the Combat Phase.	Talent	7	Unique																				
9/29/2014 15:15:50	71530 - Queen Vessel Prime	We Are the Borg	Borg	During the Modify Defense Dice step of the Combat Phase, you may discard this card and spend up to 3 of your Drone Tokens.  Add 1 [EVADE] result to your roll for each Drone Token you spent with this card.	Talent	6	Unique																				
9/29/2014 15:18:12	71530 - Queen Vessel Prime	Transwarp Signal	Borg	"Discard this card to target a ship anywhere in the play area.  Remove 1 Token ([EVADE], [BATTLE STATIONS], [SCAN], or [TARGET LOCK]) from beside the target ship.  If you remove a [TARGET LOCK] Token with this card, remove the corresponding [TARGET LOCK] Token as well.  Place an Auxiliary Power Token beside the target ship.
This Upgrade may only be purchased for a Borg ship.
No ship can be equipped with more than 1 ""Transwarp Signal"" Borg Upgrade.  This Upgrade has no effect on a Species 8472 ship."	Borg	4	Non-unique	Yes																			
9/29/2014 15:19:20	71530 - Queen Vessel Prime	Borg Shield Matrix	Borg	"Every time your ship's Hull or Shields are damaged by an enemy ship, place 1 Borg Shield Matrix Token on this card (3 max).

No ship can be equipped with more than 1 Borg Shield Matrix Upgrade.  This Upgrade has no effect on a Species 8472 ship."	Borg	8	Non-unique	Yes																			
9/29/2014 15:31:39	71530 - Queen Vessel Prime	Borg Assimilation Tubules	Borg	ACTION: Disable this card and discard 1 Drone Token to target a ship at Range 1-2.  Steal 1 [CREW], [TECH], or [WEAPON] Upgrade from the target ship, even if it exceeds your ship's restrictions.  Place a disabled Upgrade Token on the assimilated Upgrade.  You cannot steal a Species 8472 Upgrade with this Action.	Borg	8	Non-unique																				
9/30/2014 18:20:39	71530 - Queen Vessel Prime	Power Node	Borg	Whenever you perform a Red Maneuver, you may disable this card and 2 of your Active Shields to treat the Maneuver as a White Maneuver.	Tech	3	Non-unique																				
9/30/2014 18:30:20	71531 - U.S.S. Enterprise-E	Beverly Crusher	Federation	"If one of your other [CREW] Upgrades is supposed to be disabled for any reason, you may disable this card instead.

OR

If one of your other [CREW] Upgrades is supposed to be discarded for any reason, you may discard this card instead."	Crew	3	Unique																				
9/30/2014 18:31:32	71531 - U.S.S. Enterprise-E	Deanna Troi	Federation	ACTION: Discard this card to target a ship at Range 1-2.  Disable the Captain or 1 [CREW] Upgrade on the target ship.  Place a [BATTLE STATIONS] Token beside your ship.  If the target ship is Cloaked, flip its [CLOAK] Token over to its red side.	Crew	3	Unique																				
9/30/2014 18:47:05	71528 - Val Jean	Kenneth Dalby	Independent	"ACTION: Disable this card to repair 1 damage to your Hull or Shields.

OR

ACTION: Discard this card to repair up to 2 damage to your Hull or Shields."	Crew	2	Unique																				
9/30/2014 18:47:57	71528 - Val Jean	Seska	Independent	ACTION: Discard this card and disable 1 of your other Upgrades to target a ship at Range 1-3.  Target ship cannot attack your ship this round.	Crew	5	Unique																				
9/30/2014 18:49:05	71528 - Val Jean	Evasive Pattern Omega	Independent	After all ships have moved, if you are in the forward firing arc of an enemy ship and that ship is not in your forward firing arc, you may disable this card to immediately perform a [SENSOR ECHO] Action (even if you do not have it on your Action Bar).	Talent	3	Unique																				
9/30/2014 18:50:08	71528 - Val Jean	Be Creative	Independent	You may disable this card at any time to replace 1 [EVADE], [SCAN] or [BATTLE STATIONS] Token beside your ship with 1 [EVADE], [SCAN] or [BATTLE STATIONS] Token.	Talent	5	Unique																				
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
9/29/2014 14:45:10	71531 - U.S.S. Enterprise-E	Jean-Luc Picard	8	Federation	"Add 1 [TECH], [WEAPON] or [TALENT] Upgrade to your Upgrade Bar (your choice).

At the start of the game, after Setup, choose 1 Faction.  Whenever you attack a ship of that Faction, you may roll 1 less attack die to add 1 [CRIT] result to your roll. Each time you defend against a ship of that Faction, roll +1 defense die."	1	5	Unique	Yes																		
9/29/2014 14:45:10	71531 - U.S.S. Enterprise-E	Jean-Luc Picard	8	Federation	"Add 1 [TECH], [WEAPON] or [TALENT] Upgrade to your Upgrade Bar (your choice).

At the start of the game, after Setup, choose 1 Faction.  Whenever you attack a ship of that Faction, you may roll 1 less attack die to add 1 [CRIT] result to your roll. Each time you defend against a ship of that Faction, roll +1 defense die."	1	5	Unique	Yes																		
9/29/2014 14:45:10	71531 - U.S.S. Enterprise-E	Jean-Luc Picard	8	Federation	"Add 1 [TECH], [WEAPON] or [TALENT] Upgrade to your Upgrade Bar (your choice).

At the start of the game, after Setup, choose 1 Faction.  Whenever you attack a ship of that Faction, you may roll 1 less attack die to add 1 [CRIT] result to your roll. Each time you defend against a ship of that Faction, roll +1 defense die."	1	5	Unique	Yes																		
9/29/2014 14:46:47	71511 - Avatar of Tomed	Salatrel	5	Romulan	At the start of the game, after Setup, choose 1 Faction.  For the rest of the game, during each Combat Phase, if a ship of that Faction is in your forward firing arc, treat your Captain Skill Number as if it were a 10 until the End Phase of that round.	1	3	Unique																			
9/29/2014 14:47:12	71511 - Avatar of Tomed	Drone	1	Borg	At the start of the game, place 1 Drone Token on this card.	0	0	Non-unique																			
9/29/2014 14:47:32	71530 - Queen Vessel Prime	Drone	1	Borg	At the start of the game, place 1 Drone Token on this card.	0	0	Non-unique																			
9/29/2014 14:47:44	71531 - U.S.S. Enterprise-E	Federation	1	Federation		0	0	Non-unique																			
9/29/2014 14:47:59	71528 - Val Jean	Independent	1	Independent		0	0	Non-unique																			
9/29/2014 14:49:14	71528 - Val Jean	Chakotay	6	Independent	"Add 1 [WEAPON] or [CREW] Upgrade to your Upgrade bar (your choice).

ACTION: Perform a 2nd Maneuver on your Maneuver Dial with a number of 3 or less.  Place an Auxiliary Power Token beside your ship.  If the extra Maneuver is a Red Maneuver, place a 2nd Auxiliary Power Token beside your ship."	1	4	Unique	Yes																		
9/29/2014 14:49:14	71528 - Val Jean	Chakotay	6	Independent	"Add 1 [WEAPON] or [CREW] Upgrade to your Upgrade bar (your choice).

ACTION: Perform a 2nd Maneuver on your Maneuver Dial with a number of 3 or less.  Place an Auxiliary Power Token beside your ship.  If the extra Maneuver is a Red Maneuver, place a 2nd Auxiliary Power Token beside your ship."	1	4	Unique	Yes																		
9/29/2014 14:50:10	71528 - Val Jean	Calvin Hudson	5	Independent	"Add 1 [TECH], [WEAPON] or [CREW] Upgrade to your Upgrade Bar (your choice).

If this card is assigned to an Independent ship, all of your Upgrades cost -1 SP."	0	3	Unique	Yes																		
9/29/2014 14:50:10	71528 - Val Jean	Calvin Hudson	5	Independent	"Add 1 [TECH], [WEAPON] or [CREW] Upgrade to your Upgrade Bar (your choice).

If this card is assigned to an Independent ship, all of your Upgrades cost -1 SP."	0	3	Unique	Yes																		
9/29/2014 14:50:10	71528 - Val Jean	Calvin Hudson	5	Independent	"Add 1 [TECH], [WEAPON] or [CREW] Upgrade to your Upgrade Bar (your choice).

If this card is assigned to an Independent ship, all of your Upgrades cost -1 SP."	0	3	Unique	Yes																		
9/30/2014 18:19:28	71530 - Queen Vessel Prime	Tactical Drone	5	Borg	"At the start of the game, place 5 Drone Tokens on this card.

During the Roll Defense Dice step of the Combat Phase, you may spend 1 of your Drone Tokens to force your opponent to roll 1 less defense die."	0	4	Non-unique																			
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
9/29/2014 14:52:04	71528 - Val Jean	Ramming Attack	Independent			"ATTACK: Discard this card and immediately perform a 1 [FORWARD] Maneuver.  If your ship overlaps an enemy ship, destroy your ship and roll 6 attack dice to damage the enemy ship.  The enemy ship rolls -3 defense dice against this attack (min 0).

This Upgrade may only be purchased for a ship with a Hull of 3 or less and cannot be used with the Cheat Death Upgrade."	3	Non-unique	Yes																		
9/29/2014 14:53:03	71528 - Val Jean	Photon Torpedoes	Independent	5	2-3	"ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.

You may convert one of your [BATTLE STATIONS] results into a [CRIT] result.

You may fire this weapon from your forward or rear firing arcs."	5	Non-unique																			
9/29/2014 14:54:08	71531 - U.S.S. Enterprise-E	Photon Torpedoes	Federation	5	2-3	"ATTACK: (Target Lock) Spend y our target lock and disable this card to perform this attack.

If fired from a Sovereign class ship, gain +1 attack die.

You may fire this weapon from your forward or rear firing arcs."	6	Non-unique																			
9/29/2014 14:55:30	71531 - U.S.S. Enterprise-E	Dorsal Phaser Array	Federation	*	1-2	"ATTACK: You may fire this weapon in any direction.  The Attack Value is equal to the ship's Primary Weapon Value.

This Upgrade may only be purchased for a Federation ship with a Hull Value of 4 or greater and the SP cost is equal to the ship's Primary Weapon Value +1."	1	Non-unique	Yes																		
9/29/2014 14:56:58	71511 - Avatar of Tomed	Plasma Torpedoes	Romulan	5	1-2	"ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.

You may re-roll all of your blank results one time.

You may fire this weapon from your forward or rear firing arcs."	5	Non-unique																			
9/29/2014 14:59:40	71530 - Queen Vessel Prime	Multi Kinetic Neutronic Mines	Borg			ATTACK: Discard this card and place a Minefield Token anywhere within Range 1 of your ship.  If you place this Token on a ship or if a ship enters the minefield (i.e., overlaps it), roll 4 attack dice.  Any [HIT] or [CRIT] damages every ship (including your own) within Range 1-3 of this Minefield Token as normal.  Ships within Range 1 of the Minefield Token do not roll defense dice against this attack.  All other ships roll full defense dice against this attack (+1 defense die at Range 3).  This Upgrade costs +5 SP if purchased for any non-Borg ship.	10	Unique	Yes																		
9/30/2014 18:33:14	71531 - U.S.S. Enterprise-E	Quantum Torpedoes	Federation	5	2-3	"ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.

If the target ship is hit, add 1 [HIT] result to your total damage.

You may fire this weapon from your forward or rear firing arcs."	6	Non-unique																			
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
9/29/2014 14:41:52	71530 - Queen Vessel Prime	Unique	Borg Queen	Borg	FLEET ACTION: Target a friendly ship at Range 1-2.  Choose 1 Upgrade on that ship and perform that Upgrade's Action as a free Action this round.  If that Action requires spending Drone Tokens, spend 1 less Drone Token than required.	2	1	5	7	At the start of the game or if this card replaces another Captain, remove all Drone Tokens from that Captain Card and place 7 Drone Tokens on this card.  ACTION: Target a friendly ship at Range 1-2.  Choose 1 Upgrade on that ship and perform that Upgrade's Action as a free Action this round.  If that Action requires spending Drone Tokens, spend 1 less Drone Token than required.	1	5															
9/29/2014 14:43:30	71531 -  U.S.S. Enterprise-E	Unique	Matthew Dougherty	Federation	FLEET ACTION: Disable 1 of your Upgrades to perform this Action.  Each time you defend this round, during the Roll Defense Dice step of the Combat Phase, roll +1 defense die.	1	0	3	4	ACTION: Disable 1 of your Upgrades to perform this Action.  Each time you defend this round, during the Roll Defense Dice step of the Combat Phase, roll +1 defense die.	0	3															
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
    title = parts.shift
    faction = parts.shift
    ability = parts.shift
    upType = parts.shift
    cost = parts.shift
    uniqueText = parts.shift
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
      <Special></Special>
    </Upgrade>
    SHIPXML
    new_upgrades.puts upgradeXml
end

weapons_lines = parse_data(weapons_text)

weapons_lines.each do |raw_parts|
    parts = raw_parts.collect { |one_part| convert_line(one_part) }
    parts.shift
    expansion = parts.shift
    title = parts.shift
    faction = parts.shift
    attack = parts.shift
    range = parts.shift
    ability = parts.shift
    upType = "Weapon"
    cost = parts.shift
    uniqueText = parts.shift
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
      <Special></Special>
    </Upgrade>
    SHIPXML
    new_upgrades.puts upgradeXml
end

captains_lines = parse_data(captains_text)

captains_lines.each do |raw_parts|
  parts = raw_parts.collect { |one_part| convert_line(one_part) }
  parts.shift
  expansion = parts.shift
  title = parts.shift
  skill = parts.shift
  faction = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  cost = parts.shift
  uniqueText = parts.shift
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
    <Special></Special>
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
  cost = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  skill = parts.shift
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
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
    <Special></Special>
    <AdmiralAbility>#{admiralAbility}</AdmiralAbility>
    <AdmiralCost>#{admiralCost}</AdmiralCost>
    <AdmiralTalent>#{admiralTalent}</AdmiralTalent>
    <SkillModifier>#{skillModifier}</SkillModifier>
  </Admiral>
  SHIPXML
  new_admirals.puts upgradeXml
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
