require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
6/30/2014 8:38:15	Unique	The Needs of the Many...	Federation	ACTION: Discard this card and one of your [CREW] Upgrades with an SP cost of 3 or higher to repair up to 3 of your Shields.	Talent	4																			
6/30/2014 8:38:46	Unique	Leonard McCoy	Federation	ACTION: Remove 2 Disabled Upgrade Tokens from your [CREW] Upgrades.	Crew	2																			
6/30/2014 8:39:38	Unique	Saavik	Federation	You may disable this card at any time to replace 1 [SCAN] or [BATTLE STATIONS] Token that is beside your ship with 1 [EVADE] Token.	Crew	3																			
6/30/2014 8:40:07	Unique	Ilia	Federation	You do not lose your "Perform Actions" step when you overlap another ship's base.	Crew	4																			
6/30/2014 8:41:39	Unique	Hikaru Sulu	Federation	ACTION: If your ship is not Cloaked and you performed a Green Maneuver this round, perform a [SENSOR ECHO] Action.  You may use this Action even if your ship does not have the [SENSOR ECHO] Action on its Action Bar.  You may only use the 1 [STRAIGHT] Maneuver Template for this Action.	Crew	3																			
6/30/2014 8:43:23	Unique	Self-Destruct Sequence	Federation	ACTION: You cannot attack this round.  At the end of the next Activation Phase, after all ships have moved, destroy your ship and roll a number of attack dice equal to your Hull value to damage every ship within Range 1 of your ship.  These ships do not roll defense dice against this damage.  You cannot use the "Cheat Death" [ELITE TALENT] Upgrade in conjunction with this Action.  This Upgrade may only be purchased for a Federation ship.	Talent	5																			
6/30/2014 8:44:39	Unique	Montgomery Scott	Federation	At any time, you may disable this card to prevent 1 Auxiliary Power Token from being placed beside your ship.  OR  ACTION: Discard this card to immediately repair up to 2 damage to your ship's Hull.	Crew	5																			
6/30/2014 8:45:32	Unique	Pavel Chekov	Federation	When attacking with your Primary Weapon, during the Modify Attack Dice step of the Combat Phase, you may disable this card to re-roll all of your blank results.  You must keep the results of the second roll.	Crew	3																			
6/30/2014 8:46:10	Unique	Nyota Uhura	Federation	At the start of the Activation Phase, you may disable this card to add +2 to your Captain's Skill Number until the End Phase.	Crew	3																			
6/30/2014 8:54:57	Unique	Goval	Borg, Independent	Discard this card at any time to prevent 1 of your other [CREW] Upgrades from being discarded or disabled.  If this Upgrade is deployed to a ship with a Borg Captain, you must spend 1 Drone Token to use this ability.	Crew	1																			
6/30/2014 8:56:33	Unique	Bosus	Borg, Independent	If an enemy ship causes any of your [CREW] Upgrades to be discarded, place those Upgrades face down beneath this card.  ACTION: Discard this card and all the cards beneath it.  For each card that was discarded by this Action (including this card), you gain +1 attack die when attacking with your Primary Weapon this round.  If this Upgrade is deployed to a ship with a Borg Captain, you must spend 2 Drone Tokens to use this Action.	Crew	2																			
6/30/2014 8:58:12	Unique	Crosis	Borg, Independent	ACTION: Discard this card to target a ship at Range 1. Disable 1 [CREW] or 1 [TECH] Upgrade of your choice on the target ship.  Then steal 1 [CREW] Upgrade of your choice from that ship, even if the Upgrade exceeds your ship's restrictions.  If this Upgrade is deployed to a ship with a Borg Captain,  you must spend 2 Drone Tokens to perform this Action.	Crew	5																			
6/30/2014 8:58:58	Unique	Torsus	Borg, Independent	ACTION: Discard this card to increase your Captain's Skill Number by +2 until the End Phase.  If this Upgrade is deployed to a ship with a Borg Captain, you must spend 1 Drone Token to perform this Action.	Crew	2																			
6/30/2014 9:00:00	Unique	Diversionary Tactics	Independent	ACTION: Discard this card and one of your [CREW] Upgrades to target a ship that is within Range 1-2 of your ship and not in your forward firing arc.  Target ship must discard 1 of its [CREW] Upgrades (of its choice) and cannot attack your ship this round.	Talent	5																			
6/30/2014 9:01:21	Unique	Experimental Link	Borg	During the Modify Attack Dice step of the Combat Phase, you may discard this card and either spend up to 3 of your Drone Tokens OR disable up to 3 of your [CREW] Upgrades to re-roll a number of your attack dice equal to the number of Drone Tokens you spend or [CREW] Upgrades you disabled with this card.  This Upgrade may only be purchased for a Borg Captain.	Talent	5																			
6/30/2014 9:02:38		Subspace Distortion	Borg	ACTION: Discard this card to perform this Action.  Each time you defend this round, instead of rolling your normal defense dice, roll a number of defense dice equal to your starting Shield value.  During the Modify Defense Dice step of the Combat Phase, you may re-roll a number of your blank results equal to your Active Shields.  You cannot attack this round.	Tech	6																			
6/30/2014 9:04:07		Transwarp Conduit	Borg	ACTION: Discard this card to remove your ship from the play area and discard all Tokens that are beside your ship except Auxiliary Power Tokens.  During the End Phase, place your ship back in the play area.  You cannot place your ship within Range 1-3 of any enemy ship.  This Upgrade may only be purchased for a Borg ship.	Borg	6																			
6/30/2014 9:16:07	Unique	Unnecessary Bloodshed	Dominion	ACTION: Discard this card to target every friendly ship within Range 1-3 (and your ship). During the Roll Attack Dice step of the Combat Phase, each target ship chooses one of its attack dice and places it on a [HIT] result.  These dice may not be rolled or re-rolled this round.  This Upgrade may only be purchased for a Dominion Captain.	Talent	5																			
6/30/2014 9:17:18	Unique	Lamat'Ukan	Dominion	If your ship has already acquired a Target Lock on an enemy ship, during the Declare Target step of the Combat Phase, you may discard this card to remove your [TARGET LOCK] Tokens and acquire a Target Lock on a different enemy ship as a free Action.  Normal Target Lock rules apply.	Crew	2																			
6/30/2014 9:18:34	Unique	Remata'Klan	Dominion	At the end of the Activation Phase, if your ship is in the forward firing arcs of at least 2 enemy ships within Range 1-3 of your ship, you may discard this card to add +2 to your Captain's Skill Number until the End Phase.  Gain +2 attack dice for all of your attacks during the round in which you use this Upgrade.	Crew	4																			
6/30/2014 9:19:23	Unique	Amat'Igan	Dominion	Each time you defend, roll +1 defense dice.  Whenever an enemy Upgrade would cause one of your other [CREW] Upgrades to be discarded, you must discard this card instead.	Crew	3																			
6/30/2014 9:20:12		Sensor Array	Dominion	During the Modify Attack Dice step of the Combat Phase, you may spend your [SCAN] Token to force 1 enemy ship to re-roll one of its attack dice of your choice.	Tech	3
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
6/30/2014 8:34:38	Unique	Mr. Spock	6	Federation	Your ship may perform a [TARGET LOCK] or [SCAN] Action as a free Action each round.	1	4																		
6/30/2014 8:35:24	Unique	Will Decker	3	Federation	During the Modify Attack Dice step of the Combat Phase, you may destroy one of your Active Shields to add 1 additional [CRIT] result to your attack roll.	0	2																		
6/30/2014 8:52:12	Unique	Hugh	4	Independent	All of your [CREW] Upgrades cost -1 SP.  You do not pay a Faction penalty when assigning any Borg Upgrades to your ship.	0	2																		
6/30/2014 8:53:39	Unique	Lore	7	Independent	Add 1 [CREW] Upgrade slot to your Upgrade Bar.  During the Roll Attack Dice step of the Combat Phase, you may discard 1 of your [CREW] Upgrades to gain +1 attack die for that attack.  You may assign any [ELITE TALENT] Upgrade to your ship, regardless of Faction restriction, and you do not pay a Faction penalty when assigning any [ELITE TALENT] Upgrade to your ship.	1	4																		
6/30/2014 9:13:12	Unique	Keevan	4	Dominion	ACTION: Target 1 enemy ship at Range 1-2 in your forward firing arc.  Your ship cannot attack any other ship this round and must attack that ship, if possible.  During the Combat Phase, if your ship attacks with its Primary Weapon, it resolves its attack immediately before the target ship, as if it had a higher Captain Skill than that ship.  If the target ship attacks  your ship this round, it gains +4 attack dice.	0	2																		
6/30/2014 9:14:29	Unique	Weyoun	8	Dominion	At the start of the game, place 2 Mission Tokens on this card.  ACTION: Spend 1 Mission Token from this card to target a ship within Range 1-3 of your ship.  Target ship cannot attack your ship this round.  You cannot attack this round.	1	5
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
6/30/2014 8:37:20		Photon Torpedoes	Federation	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may fire this weapon from your forward or rear firing arcs.	4																		
6/30/2014 9:05:24		Photon Torpedoes	Borg	5	2-3	ATTACK (Target Lock): Spend your target lock and disable this card to perform this attack.  If the target ship is damaged by this attack, destroy 1 additional Active Shield on that ship (if possible).  If fired from a Borg ship, add +1 attack die.	6																		
6/30/2014 9:06:42		Forward Weapons Array	Borg	3	1-3	ATTACK: Discard this card to target up to 3 ships in your forward firing arc.  Make a separate attack with this weapon against each of those ships.  If you attack 1 ship with this weapon, add +3 attack dice to that attack.  If you attack 2 ships with this weapon, add +1 die to each attack.  This Upgrade costs +5 SP if purchased for any non-Borg ship.	6																		
6/30/2014 9:22:18		Volley of Torpedoes	Dominion	5	1-3	ATTACK: (Target Lock) Spend your target lock and discard this card to perform this attack.  You may disable 1 of your other Dominion Torpedo Upgrades and make one additional attack with it.  You do not need to have the 2nd ship target locked or spend a 2nd target lock to make this extra attack.  Both attacks must be made against different targets in your forward or rear firing arcs.  This Upgrade may only be purchased for a Jem'Hadar Battle Cruiser or Battleship.	6																		
6/30/2014 9:23:12		Phased Polaron Beam	Dominion	4	1	ATTACK: Disable this card to perform this attack.  All damage inflicted by this attack ignores the opposing ship's Shields.  This Upgrade costs +5 Squadron Points for any non-Jem'Hadar ship.	5																		
6/30/2014 9:24:19		Photon Torpedoes	Dominion	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  If fired from a Jem'Hadar Battle Cruiser, add +1 attack die.  You may fire this weapon from your forward or rear firing arcs.	5
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
6/30/2014 8:47:42	Unique	James T. Kirk	Federation	FLEET ACTION: Target a ship at Range 1.  Disable one Upgrade of your choice on the target ship.	2	1	5	5	ACTION: Target a ship at Range 1.  Disable one Upgrade of your choice on the target ship.	1	8															
6/30/2014 9:11:32	Unique	Gul Dukat	Dominion	FLEET ACTION: When attacking with your Primary Weapon this round, gain +1 attack die.	1	1	5	5	ACTION: When attacking with your Primary Weapon this round, gain +1 attack die.	1	8
ADMIRALSTEXT

convert_terms(upgrade)
convert_terms(captains_text)
convert_terms(weapons_text)

new_upgrades = File.open("new_upgrades.xml", "w")
new_captains = File.open("new_captains.xml", "w")
new_admirals = File.open("new_admirals.xml", "w")

upgrade_lines = upgrade.split "\n"

def no_quotes(a)
    a.gsub("\"", "")
end

def parse_set(setId)
  setId = no_quotes(setId)
  if setId =~ /\#(\d+).*/
    return $1
  end
  return setId.gsub(" ", "").gsub("\"", "")
end

upgrade_lines.each do |l|
    l = convert_line(l)
    # Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
    parts = l.split "\t"
    parts.shift
    unique = parts.shift == "Unique" ? "Y" : "N"
    title = parts.shift
    faction = parts.shift
    ability = parts.shift
    upType = parts.shift
    cost = parts.shift
    setId = set_id_from_faction(faction)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <Upgrade>
      <Title>#{title}</Title>
      <Ability>#{ability}</Ability>
      <Unique>#{unique}</Unique>
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

weapons_lines = weapons_text.split "\n"

weapons_lines.each do |l|
    l = convert_line(l)
    # Timestamp		Weapon Name	Faction	Attack	Range	Ability	Cost
    parts = l.split "\t"
    parts.shift
    unique = parts.shift == "Unique" ? "Y" : "N"
    title = parts.shift
    faction = parts.shift
    attack = parts.shift
    range = parts.shift
    ability = parts.shift
    upType = "Weapon"
    cost = parts.shift
    setId = set_id_from_faction(faction)
    externalId = make_external_id(setId, title)
    upgradeXml = <<-SHIPXML
    <Upgrade>
      <Title>#{title}</Title>
      <Ability>#{ability}</Ability>
      <Unique>#{unique}</Unique>
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

captains_lines = captains_text.split "\n"
captains_lines.each do |l|
  l = convert_line(l)
  # Timestamp		Captain Name	Skill	Faction	Ability	Talents	Cost
  parts = l.split "\t"
  parts.shift
  unique = parts.shift == "Unique" ? "Y" : "N"
  title = parts.shift
  skill = parts.shift
  faction = parts.shift
  ability = parts.shift
  upType = "Captain"
  talent = parts.shift
  cost = parts.shift
  setId = set_id_from_faction(faction)
  externalId = make_external_id(setId, title)
  upgradeXml = <<-SHIPXML
  <Captain>
    <Title>#{title}</Title>
    <Ability>#{ability}</Ability>
    <Unique>#{unique}</Unique>
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

admirals_lines = admirals_text.split "\n"
admirals_lines.each do |l|
  l = convert_line(l)
  # Timestamp		Admiral Name	Faction	Fleet Action	Skill Modifier	Talents	Cost	Captain-side Cost	Captain-side Action	Captain-side Talents	Captain-side Skill
  parts = l.split "\t"
  parts.shift
  unique = parts.shift == "Unique" ? "Y" : "N"
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
  setId = set_id_from_faction(faction)
  externalId = make_external_id(setId, title)
  upgradeXml = <<-SHIPXML
  <Admiral>
    <Title>#{title}</Title>
    <Ability>#{ability}</Ability>
    <Unique>#{unique}</Unique>
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
