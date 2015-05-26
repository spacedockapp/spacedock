require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
4/28/2015 16:41:55	71799 - Kyana Prime	Mirror Universe Unique	Causality Paradox	Independent, Mirror Universe	ACTION: Discard this card to target a ship at Range 1-3. Discard 1 Upgrade of your choice on the target ship.  Then remove 1 Disabled Upgrade Token from 1 of your Upgrades, if possible.  This Upgrade may only be purchased for Annorax or any other Krenim Captain assigned to a Krenim weapon ship.	Talent	5	Yes
4/28/2015 16:43:20	71799 - Kyana Prime	Mirror Universe Unique	Temporal Wave Front	Independent, Mirror Universe	ACTION: Discard this card to target every ship in your forward firing arc within Range 1-3.  Each target ship must roll 3 defense dice.  For every blank result a ship rolls, that ship must disable one of its cards at random (Captain, Admiral or Upgrade card).  This Upgrade by only be purchased for a Krenim weapon ship.	Tech	6	Yes
4/28/2015 16:44:40	71799 - Kyana Prime	Non-unique	Temporal Core	Independent, Mirror Universe	ACTION: Disable this card to perform this Action.  When defending this round, all ships roll -2 attack dice against your ship until the End Phase.  This Action cannot reduce an attack below 1 attack die.  You cannot perform any free Actions this round.  This Upgrade may only be purchased for a Krenim weapon ship.	Tech	6	
4/28/2015 16:45:56	71799 - Kyana Prime	Non-unique	Spatial Distortion	Independent, Mirror Universe	ACTION: Discard this card to remove your ship from the play area and discard all Tokens that are beside your ship except for Auxiliary Power Tokens.  During the End Phase, place your ship back in the play area.  You cannot place your ship within Range 1-3 of any enemy ship.  This Upgrade may only be purchased for Krenim weapon ship.	Tech	6	Yes
4/28/2015 16:48:01	71998 - USS Hood	Unique	Tachyon Detection Grid	Federation	ACTION: Discard this card to target your ship and up to 2 friendly ships within Range 1 of your ship.  All cloaked enemy ships within Range 1 of the target ships cannot perform the [SENSOR ECHO] Action this round and immediately flip their [CLOAK] Tokens over to their red sides.  In addition, all enemy ships within Range 1 of the target ships roll -1 defense die each time they defend this round.  This Upgrade may only be purchased for a Federation ship.	Tech	6	Yes
4/28/2015 16:54:04	71998 - USS Hood	Unique	William T. Riker	Federation	Each time you defend, roll +1 defense die and you may convert 1 of your [BATTLE STATIONS] results into an [EVADE] result.  If your Captain Card is disabled, each time you defend, roll +2 defense dice and you may convert up to 2 of your [BATTLE STATIONS] results into [EVADE] results.	Crew	3	
4/28/2015 16:55:36	71998 - USS Hood	Non-unique	Systems Upgrade	Federation	You may fill any slot on your Upgrade Bar with this Upgrade.  Add 1 [TECH] icon to your Upgrade Bar.  Your starting Shield Value is at +1.  This Upgrade may only be purchased for a Federation ship and no ship may be equipped with more than one "Systems Upgrade" card.	Tech	2	Yes
5/6/2015 23:00:24	71801 - USS Pegasus	Non-unique	Specialized Shields	Federation	When defending, while your ship still has Active Shields, during the Modify Defense Dice step, you may re-roll 1 of your blank results.  When suffering damage from an obstacle or a minefield, subtract 1 damage from the total damage.  This Upgrade may only be purchased for a Federation ship with a Hull value of 3 or less.	Tech	4	Yes
5/6/2015 23:02:24	71801 - USS Pegasus	Unique	Phasing Cloaking Device	Federation	Add the [CLOAK] and [SENSOR ECHO] icons to your Action Bar.  Each time your ship performs the [CLOAK] Action, roll 1 attack die.  If you roll a [HIT] result, suffer 1 damage to your Hull.  While cloaked, your ship: 1) may only perform green maneuvers, 2) does not lose its actions when overlapping another ship's base or an obstacle and 3) suffers no damage when overlapping obstacles.  This Upgrade costs +5 SP for any ship other than a Federation Oberth Class.	Tech	5	Yes
5/6/2015 23:03:32	71801 - USS Pegasus	Non-unique	Escape Pod	Federation	When your ship is destroyed, before removing it from the play area, place 1 Escape Pod Token in the play area within Range 1 of your ship and then choose your Captain and/or up to 2 of your [CREW] Upgrades and place them under this card.  Do not discard these cards with the ship.	Tech	1	
5/6/2015 23:08:16	71801 - USS Pegasus	Unique	Andy Simonson	Federation	After completing your ship's move, before declaring your Action for this round, you may discard this card to target a ship within Range 1-3 of your ship and look at that ship's chosen Maneuver.	Crew	2	
5/6/2015 23:09:04	71801 - USS Pegasus	Unique	Phil Wallace	Federation	Before you move, after revealing your Maneuver Dial, you may disable this card to reduce your ship's Speed by 1 (min 1).	Crew	2	
5/6/2015 23:10:32	71801 - USS Pegasus	Unique	Dawn Velazquez	Federation	ACTION: Discard your Captain Card to immediately perform an additional maneuver from your maneuver dial with a speed of 3 or less.  You cannot attack this round.  This card then becomes your Captain with a Skill of 3.  You cannot perform this action if Dawn Velazquez is your captain.  This card may only be purchased for a Federation ship with a Hull Value of 3 or less.	Crew	4	Yes
5/6/2015 23:11:05	71801 - USS Pegasus	Unique	Eric Motz	Federation	Add 1 [TECH] Upgrade slot to your Upgrade Bar.	Crew	2	
5/6/2015 23:12:22	71801 - USS Pegasus	Unique	William T. Riker	Federation	Your Captain's Skill Number is +3.  If your Captain is disabled or if you have no Captain, your ship's Skill Number is a 5.  If you receive a "Communications Failure" or "Injured Captain" critical damage card, immediately flip if face down.	Crew	4	
5/24/2015 17:20:41	71803 - Ratosha	Unique	Provisional Government	Bajoran	ACTION: Discard this card to target a ship at Range 1-3.  You cannot attack that ship and that ship cannot attack your ship this round.	Talent	5	
5/24/2015 17:21:55	71803 - Ratosha	Non-unique	Assault Vessel Upgrade	Bajoran	You may fill any slot on your Upgrade Bar with this Upgrade.  Your Primary Weapon and Shield values are at +1.  This Upgrade may only be purchased for a Bajoran Scout Ship and no ship may be equipped with more than 1 Assault Vessel Upgrade.	?	4	Yes
5/24/2015 17:23:02	71803 - Ratosha	Non-unique	Bajoran Militia	Bajoran	ACTION: During the Combat Phase, add a number of attack dice equal to the number of Bajoran Militia Upgrades assigned to your ship (max +3) until the End Phase.  This Upgrade may only be purchased for a Bajoran ship.	Crew	3	Yes
5/24/2015 17:24:05	71803 - Ratosha	Unique	More Than Meets the Eye	Bajoran	You may discard this card to place a [SCAN] Token beside your ship, even if there is already one there.  You cannot perform a [SCAN] Action as a free Action during the round you use this ability.	Talent	1	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
4/28/2015 16:35:45	71799 - Kyana Prime	Mirror Universe Unique	Annorax	8	Independent, Mirror Universe	Add 1 [TECH] Upgrade slot to your Upgrade Bar.  If Annorax is assigned to a Krenim weapon ship, any time you roll dice, for any reason, you may disable 1 of your Upgrades to choose one of those dice and re-roll it.	1	5		
4/28/2015 16:37:28	71799 - Kyana Prime	Mirror Universe Unique	Obrist	4	Independent, Mirror Universe	At the start of the game, place 1 Mission Token on this card.  ACTION: If you performed a Green Maneuver this round, discard the Mission Token from this card and 1 of your [WEAPON] Upgrade to target a ship at Range 1-2.  You cannot attack or be attacked by that ship this round.  You cannot perform any free Actions this round.	0	3		
4/28/2015 16:37:55	71799 - Kyana Prime	Non-unique	Krenim	1	Independent, Mirror Universe		0	0		
4/28/2015 16:38:14	71998 - USS Hood	Non-unique	Federation	1	Federation		0	0		
4/28/2015 16:39:49	71998 - USS Hood	Unique	Robert DeSoto	4	Federation	Each time you defend, you may re-roll a number of your defense dice equal to the number of [CREW] Upgrades assigned to your ship (max 3 dice).	0	3		
5/6/2015 23:04:34	71801 - USS Pegasus	Unique	Ronald Moore	2	Federation	If your ship has a Hull Value of 3 or less, during the Activation Phase, you may disable this card to place a [BATTLE STATIONS] Token beside your ship.	0	1		
5/6/2015 23:05:00	71801 - USS Pegasus	Non-unique	Federation	1	Federation		0	0		
5/24/2015 17:17:32	71803 - Ratosha	Unique	Day Kannu	4	Bajoran	When attacking with your Primary Weapon, during the Roll Attack Dice step, you may set one of your attack dice on the result of your choice.  If you do so, place an Auxiliary Power Token beside your ship.  This die cannot be rolled or re-rolld during the round you use this ability.	0	3		
5/24/2015 17:17:53	71803 - Ratosha	Non-unique	Bajoran	1	Bajoran		0	0		
5/24/2015 17:19:09	71803 - Ratosha	Unique	Krim	6	Bajoran	Add 1 [CREW] Upgrade slot to your Upgrade Bar.  When defending, during the Modify Defense Dice step, you may re-roll 1 of your defense dice for every damage card assigned to your ship (max 3 dice).	1	4	Yes	
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
4/28/2015 16:57:42	71799 - Kyana Prime	Non-unique	Chroniton Torpedoes	Independent, Mirror Universe	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  All damage inflicted by this attack ignores the opposing ship's Shields.  You may fire this weapon from your forward or rear firing arcs.  This Upgrade costs +5 SP for any ship other than a Krenim weapon ship.	6	Yes
4/28/2015 16:59:14	71799 - Kyana Prime	Non-unique	Temporal Incursion	Independent, Mirror Universe	8	3	ATTACK: (Target Lock) Spend your target lock and discard this card to perform this attack.  In addition to normal damage, for every uncancelled [CRIT] result, discard 1 Upgrade at random on the target ship.  Then for every uncancelled [HIT] result, disable 1 Upgrade at random on the target ship.  This Upgrade may only be purchased for a Krenim weapon ship.	9	Yes
4/28/2015 17:00:17	71998 - USS Hood	Non-unique	Type 8 Phaser Array	Federation			When attacking with your Primary Weapon, gain +1 attack die.  This Upgrade may only be purchased for a ship with a Primary Weapon Value of 3 or less.  No ship may be equipped with more than one "Type 8 Phaser Array" Upgrade.	2	Yes
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
5/6/2015 22:57:57	71801 - USS Pegasus	Unique	Erik Pressman	Federation	FLEET ACTION: Disable 1 of your [TECH] Upgrade to gain +1 attack die with your Primary Weapon this round.  OR  FLEET ACTION: Discard 1 of your [TECH] Upgrades to gain +2 attack dice with your Primary Weapon this round.	-1	0	2	3	ACTION: Disable 1 of your [TECH] Upgrade to gain +1 attack die with your Primary Weapon this round.  OR   ACTION: Discard 1 of your [TECH] Upgrades to gain +2 attack dice with your Primary Weapon this round.	0	2	
5/24/2015 17:15:41	71803 - Ratoshoa	Unique	Jaro Essa	Bajoran	FLEET ACTION: Discard 1 of your Bajoran [CREW] Upgrades to perform this Action.  Each time you defend this round, during the Roll Defense Dice step, roll 2 additional dice.  This card may only be purchased for a Bajoran ship.	1	1	1	2	ACTION: Discard 1 of your Bajoran [CREW] Upgrades to perform this Action.  Each time you defend this round, during the Roll Defense Dice step, roll 2 additional dice.  This card may only be purchased for a Bajoran ship.	1	1	Yes
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
