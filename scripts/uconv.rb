require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
6/23/2015 19:38:39	71805 - USS Dauntless	Unique	Auto-Navigation	Independent	Add 1 [TECH] Upgrade to your Upgrade Bar.  While this card is assigned to your ship, you do not need to have a Captain Card assigned to your ship and your ship has a Skill Number of 2.  When you reveal your chosen maneuver, you may disable this card to change that maneuver to any Green Maneuver on your ship's dial.	Tech	2	Yes
6/23/2015 19:40:05	71805 - USS Dauntless	Unique	Quantum Slipstream Drive	Independent	If you reveal a maneuver with a speed of 5 or greater, before performing the maneuver, you may discard this card to remove your ship from the play area and discard all tokens from beside your ship except for Auxiliary Power Tokens.  Then, immediately place it back in the play area, but not within Range 1-3 of any other ship.  You cannot attack during the round you use this ability.	Tech	6	
6/23/2015 19:41:21	71805 - USS Dauntless	Non-unique	Power Distribution Grid	Independent	During the Activation Phase, before you move, you may discard this card to disregard your chosen Maneuver and perform one of the [RIGHT TURN] or [LEFT TURN] Maneuvers on your Maneuver dial instead.  Treat this as a red maneuver.	Tech	2	
6/23/2015 19:42:13	71805 - USS Dauntless	Unique	Emergency Shutdown	Independent	During the Activation Phase, before you move, you may discard this card to disregard your chosen Maneuver and not move.  If you do so, you lose your Perform Action step for that round.	Talent	3	
6/23/2015 19:43:42	71805 - USS Dauntless	Unique	Lure	Independent	During the Planning Phase, after all ships have chosen their maneuvers, you may discard this card to target an enemy ship that is not within Range 1-3 of your ship.  If you do this, change that ship's chosen Maneuver.  The target ship cannot look at or change their dial after you reset it.  If the new maneuver would cause the ship to exit the play area or overlap another ship, the target ship may disregard the maneuver and not move that turn.	Tech	5	
6/23/2015 19:44:50	71805 - USS Dauntless	Non-unique	Force Field	Independent	If an enemy ship causes one of your Upgrades to be disabled or discard, you may disable this card to roll 1 defense die.  If you roll an [EVADE] result, the targeted Upgrade is not disabled or discard.  This Upgrade costs +5 SP for any other ship other than a Dauntless class ship.	Tech	3	Yes
6/23/2015 19:45:58	71805 - USS Dauntless	Non-unique	Navigational Deflector	Independent	When taking damage this round, you may discard this card to cancel 1 [HIT] result.  If the damage is from a minefield or an obstacle, disable this card instead of discarding it.  You may roll defense dice against obstacles or minefields.  No ship may be equipped with more t han one Navigational Deflector Upgrade.	Tech	4	Yes
6/23/2015 19:46:56	71805 - USS Dauntless	Non-unique	Particle Synthesis	Independent	ACTION: Disable this card and discard one of your [TECH] Upgrades to repair either 1 damage to your Hull or up to 2 of your Shield Tokens.  This Upgrade may only be purchased for a Dauntless-class ship.	Tech	5	Yes
6/23/2015 19:49:13	72000p - IRW Terix	Mirror Universe Unique	Deception	Mirror Universe	At the start of the Combat Phase, before any ships have attacked, if there is not a [BATTLE STATIONS] Token beside your ship, you may discard this card to play 1 [BATTLE STATIONS] Token beside your ship.  In addition, if your ship is Cloaked, you may place 1 [EVADE] Token beside your ship (even if there is one there already).	Talent	5	
6/23/2015 19:50:26	72000p - IRW Terix	Mirror Universe Unique	Taibak	Mirror Universe	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Discard this card to steal 1 [CREW] Upgrade on the target ship, even if it exceeds your ship's restrictions.	Crew	4	
6/23/2015 19:52:11	72000p - IRW Terix	Non-unique	Long Range Scanners	Mirror Universe	ACTION: Perform a [SCAN] Action and then place an Auxiliary Power Token beside your ship.  During the End Phase if there is a [SCAN] Token beside your ship, you may discard this card to leave that token beside your ship instead of removing it.  This Upgrade costs +3 points for any ship other than a D'deridex-class ship.	Tech	3	Yes
6/24/2015 17:06:56	72000b - Q Continuum Cards	Unique	Quinn	Q Continuum	When your ship is defending, during the Compare Results step, you may discard this card to cancel 1 [HIT] or [CRIT] result.	Crew	2	
6/24/2015 17:08:15	72000b - Q Continuum Cards	Unique	Think Fast	Q Continuum	During the Roll Attack Dice step, when attacking with a Primary Weapon, you may discard this card and disable 1 of your other Upgrades to gain +1 attack die for that attack.  OR  During the Roll Defense Dice step, you may discard this card and disable 1 of your other Upgrades to roll +1 defense die.	Talent	1	
6/24/2015 17:10:02	72000b - Q Continuum Cards	Unique	Q2	Q Continuum	This Upgrade counts as either a [CREW], an [ELITE TALENT], a [TECH], or a [WEAPON] Upgrade (your choice).  Whenever a friendly ship within Range 1 of your ship receives damage, you may discard this card to transfer all of that damage to your ship.	?	5	Yes
6/27/2015 18:50:06	71806 - Kreechta	Non-unique	Tactical Officer	Ferengi	At the end of the Activation Phase, if you are in the forward firing arc of enemy ship, you may discard this card to immediately perform a 3 [FORWARD] or 4 [FORWARD] Maneuver.  You cannot attack on the round you use this ability.  No ship may be equipped with more than 1 Tactical Officer Upgrade.	Crew	4	Yes
6/27/2015 18:51:18	71806 - Kreechta	Unique	Acquisition	Ferengi	ACTION: Discard this card to target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Steal 1 non-Borg [TECH] or [WEAPON] Upgrade of your choice on the target ship, even if the Upgrade exceeds your ship's restrictions.  This Upgrade may only be purchased for a Ferengi ship with a Ferengi Captain.	Talent	4	Yes
6/27/2015 18:52:03	71806 - Kreechta	Unique	Marauder	Ferengi	After you move, you may disable this card to perform a [BATTLE STATIONS] Action as a free Action.  This Upgrade may only be purchased for a Ferengi ship with a Ferengi Captain.	Talent	2	Yes
6/27/2015 18:52:55	71806 - Kreechta	Non-unique	EM Pulse	Ferengi	ACTION: Disable this card to target a ship at Range 1-2 that is not in your forward firing arc.  Place an Auxiliary Power Token beside the target ship.  The target ship rolls 2 less attack dice this round.	Tech	4	
6/27/2015 18:53:54	71806 - Kreechta	Non-unique	Maximum Shields	Ferengi	ACTION: Discard this card to place 2 additional Shield Tokens beside your ship.  When taking damage this round, remove these Tokens first.  You cannot attack this round.  If either or both of these Tokens are unused, discard them during the End Phase.	Tech	4	
6/27/2015 18:54:51	71806 - Kreechta	Non-unique	Ferengi Probe	Ferengi	If there is a [SCAN] Token beside your ship, you may disable this card to double your Range Combat Bonuses.  This Upgrade may only be purchased for a Ferengi ship and no ship may be equipped with more than 1 Ferengi Probe Upgrade.	Tech	4	Yes
6/29/2015 19:29:28	71807 - USS Pasteur	Mirror Universe Unique	Nell Chilton	Mirror Universe	When defending, during the Deal Damage step, after your ship suffers at least 1 damage to its Hull, you may discard this card to immediately perform an additional Green Maneuver.	Crew	3	
6/29/2015 19:30:25	71807 - USS Pasteur	Mirror Universe Unique	Alyssa Ogawa	Mirror Universe	ACTION: Remove 1 Disabled Upgrade Token from 1 of your [TECH] or [CREW] Upgrades and then perform a [SCAN] or [EVADE] Action as a free Action.	Crew	2	
6/29/2015 19:31:33	71807 - USS Pasteur	Non-unique	Impulse Drive	Mirror Universe	During the Activation Phase, if you reveal a 1, 2 or 3 Maneuver (Straight or Bank), before you move you may disable this card.  If you do so, and the maneuver is a white maneuver, treat it as a green maneuver.  If the maneuver is a red maneuver treat it as a white maneuver.	Tech	3	
6/29/2015 19:32:46	71807 - USS Pasteur	Non-unique	Inverse Tachyon Pulse	Mirror Universe	When you initiate an attack while there is a [SCAN] Token beside your ship, you may disable this card.  If you do so, the defending ship rolls -1 defense dice against that attack.  No ship may be equipped with more than 1 Inverse Tachyon Pulse Upgrade.	Tech	2	Yes
6/29/2015 19:33:38	71807 - USS Pasteur	Mirror Universe Unique	Yellow Alert	Mirror Universe	At the start of the Combat Phase, before any attacks are made, you may discard this card.  If you do so, place either 1 [EVADE] or 1 [BATTLE STATIONS] Token beside your ship (even if there is already one there).	Talent	2	
6/29/2015 19:34:39	71807 - USS Pasteur	Mirror Universe Unique	Starfleet Intelligence	Mirror Universe	When defending, during the Modify Defense Dice step, you may discard this card to re-roll any number of your defense dice.  OR  When attacking, during the Modify Attack Dice step, you may discard this card to re-roll any number of your attack dice.	Talent	3	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
6/23/2015 19:37:02	71805 - USS Dauntless	Unique	Arturis	3	Independent	Arturis's Captain Skill is +5 if he is assigned to a Dauntless class ship.  ACTION: Target a ship at Range 2-3.  Disable either the Captain Card or up to 2 [CREW] Upgrades on the target ship (your choice).  Place an Auxiliary Power Token beside your ship.	1	5		
6/23/2015 19:55:36	72000p - IRW Terix	Mirror Universe Unique	Tomalak	4	Mirror Universe	When attacking with your Primary Weapon, if there is a [SCAN] Token beside your ship, during the Modify Attack Dice step, you may re-roll all of your blank results once.	1	3		
6/24/2015 17:11:16	72000b - Q Continuum Cards	Unique	Q (Female)	10	Q Continuum	ACTION: Place 1 additional Shield Token beside your ship. When taking damage this round, remove this Shield Token first. If all of your Shields are destroyed by a single attack this round and your ship suffers any damage to it's Hull from that attack, the damage is increased by +1 normal damage. If the Shield Token is unused remove it during the End Phase.	1	7		
6/27/2015 18:44:01	71806 - Kreechta	Non-unique	Ferengi	1	Ferengi		0	0		
6/27/2015 18:44:55	71806 - Kreechta	Unique	Tarr	3	Ferengi	At the start of the Combat Phase, if your ship is in the forward firing arc of an enemy ship and you do not have a [BATTLE STATIONS] Token beside your ship, you may place a [BATTLE STATIONS] Token beside your ship.	0	2		
6/27/2015 18:45:33	71806 - Kreechta	Unique	Bractor	4	Ferengi	When attacking a ship that has an Auxiliary Power Token beside it, gain +1 attack die.	1	3		
6/29/2015 19:26:34	71807 - USS Pasteur	Non-unique	Mirror Universe	1	Mirror Universe		0	0		
6/29/2015 19:27:35	71807 - USS Pasteur	Mirror Universe Unique	Beverly Crusher	5	Mirror Universe	If you performed a Green Maneuver this round, each time you defend this round, you may convert 1 of your [BATTLE STATIONS] results into an [EVADE] result.	1	3		
6/29/2015 19:28:11	71807 - USS Pasteur	Mirror Universe Unique	Worf	6	Mirror Universe	ACTION: Roll +1 attack die and +1 defense die this round.  Place an Auxiliary Power Token beside your ship.	1	4		
7/1/2015 22:17:23	72000p - IRW Terix	Non-unique	Mirror Universe	1	Mirror Universe		0	0		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
6/23/2015 19:54:20	72000p - IRW Terix	Non-unique	Additional Phaser Array	Mirror Universe			When attacking with your Primary Weapon at a ship in your forward firing arc, gain +1 attack die.  This Upgrade may only be purchased for a D'deridex-class ship and no ship may be equipped with more than 1 Additional Phaser Array Upgrade.	2	Yes
6/27/2015 18:47:15	71806 - Kreechta	Non-unique	Photon Torpedoes	Ferengi	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into a [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
6/27/2015 18:48:22	71806 - Kreechta	Non-unique	Missile Launchers	Ferengi	2	1-2	ATTACK: Disable this card to perform this attack.  Make 2 attacks against ship(s) in your forward firing arc.  Roll separate attack dice for each of these attacks.  Any [CRIT] results that would damage an opponent's Shields inflict critical damage to that ship's Hull instead.	3	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
6/24/2015 17:05:53	72000b - Q Continuum Cards	Unique	Q	Q Continuum	FLEET ACTION: Rotate your ship 180-degrees. Place a number of Auxiliary Power tokens beside your ship equal to the speed of the maneuver you revealed this round.	-1	1	1	2	ACTION: Rotate your ship 180-degrees. Place a number of Auxiliary Power tokens beside your ship equal to the speed of the maneuver you revealed this round.	1	1	
6/29/2015 19:25:59	71807 - USS Pasteur	Mirror Universe Unique	William T. Riker	Mirror Universe	FLEET ACTION: Place a [SCAN] Token beside your ship.  You may then perform 1 Action from your Upgrade Bar as a free Action.  You cannot perform the [SCAN] Action as a free Action this round.	1	1	4	7	ACTION: Place a [SCAN] Token beside your ship.  You may then perform 1 Action from your Upgrade Bar as a free Action.  You cannot perform the [SCAN] Action as a free Action this round.	1	4	
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
