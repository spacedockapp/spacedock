require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
7/18/2015 18:59:11	72009 - IKS T'Ong	Unique	Cryogenic Stasis	Klingon	At the start of the game, place 2 non-Borg [CREW] Upgrades with a cost of 5 or less face down beneath this card.  ACTION: Flip one of those Upgrades that is beneath this card face up (your choice) and deploy it to your ship, even if it exceeds your ship's restrictions.  Then place 2 Time Tokens on that Upgrade.  Discard this card when there are no more Upgrades beneath it.	Tech	5	Yes
7/18/2015 19:00:30	72009 - IKS T'Ong	Unique	Devotion to Duty	Klingon	ACTION: When attacking with your Primary Weapon this round, during the Roll Attack Dice step, you may discard this card to gain +1 attack die for every damage card assigned to your ship (max +2).  This Upgrade may only be purchased for a Klingon Captain assigned to a Klingon ship.	Talent	4	Yes
7/18/2015 19:01:53	72009 - IKS T'Ong	Non-unique	Tactical Officer	Klingon	If your ship is not Cloaked, during the Modify Attack Dice step, you may disable this card to re-roll all of your blank results once.  This Upgrade costs +3 SP for any non-Klingon ship and no ship may be equipped with more than 1 Tactical Officer Upgrade.	Crew	2	Yes
7/18/2015 19:02:41	72009 - IKS T'Ong	Unique	K'Ehleyr	Klingon	ACTION: Discard this card to target a ship at Range 1.  Your ship cannot attack the target ship and the target ship cannot attack your ship this round.	Crew	5	
7/19/2015 16:48:08	72001 - USS Bellerophon	Unique	Section 31	Independent	At any time, you may discard this card to achieve the effect of spending either a [BATTLE STATIONS], an [EVADE], or a [TARGET LOCK] Token as if you spent the appropriate Token from beside your ship.  You may only use the [TARGET LOCK] effect for re-rolling your dice.	Talent	3	
7/19/2015 16:50:36	72001 - USS Bellerophon	Non-unique	Variable Geometry Pylons	Federation	Before you move, you may disable this card to increase your speed by 1 or decrease your speed by 1.  If you do this, treat the maneuver as a White Maneuver.  You cannot perform any Actions on the round you use this ability.  This Upgrade may only be purchased for an Intrepid-class ship and no ship may be equipped with more than 1 Variable Geometry Pylons Upgrade.	Tech	5	Yes
7/19/2015 16:55:20	72001 - USS Bellerophon	Unique	Luther Sloan	Independent	You do not pay a faction penalty when assigning this card to a Federation ship.  During the Planning Phase, after all ships have been assigned a Maneuver Dial, you may discard this card to look at up to 3 ships' Maneuver Dials.  You may then change your chosen Maneuver.	Crew	3	Yes
7/25/2015 14:20:15	72010 - IRW Vrax	Unique	Coordinated Attack	Romulan	If your ship has not already attacked this round, you may discard this card to perform an attack with your Primary Weapon at -1 attack die immediately after a friendly ship attacks, regardless of initiative order.  This Upgrade may only be purchased for a Romulan Captain on a Romulan ship.	Talent	5	Yes
7/25/2015 14:21:33	72010 - IRW Vrax	Non-unique	Bridge Officer	Romulan	When you are instructed to place Time Tokens on one of your [WEAPON] Upgrades, place 1 less Time Token than required.  This Upgrade costs +2 SP for any non-Romulan ship and no ship may be equipped with more than 1 Bridge Officer Upgrade.	Crew	3	Yes
7/25/2015 14:22:25	72010 - IRW Vrax	Unique	Tal'aura	Romulan	ACTION: Discard this card to target a ship at Range 3.  Discard 1 [CREW] Upgrade of your choice on the target ship.	Crew	5	
7/30/2015 14:53:36	72008 - USS Thunderchild	Unique	Persistence	Federation	When you attack with your Primary Weapon, during the Roll Attack Dice step, if you roll a [HIT] or [CRIT] result on each one of your dice, you may discard this card to roll +2 additional attack dice (+4 against Borg ships). Add all [HIT] or [CRIT] results from the additional dice to your total for that attack. Any Blank or [BATTLE STATIONS] results from the additional dice are not added.	Talent	5	
7/30/2015 14:54:04	72008 - USS Thunderchild	Unique	Federation Task Force	Federation	ACTION: Discard this card to target up to 2 friendly ships within Range 1-2. Your ship and the target ships may immediately perform a [TARGET LOCK] Action as a free Action, if possible.  This Upgrade may only be purchased for a Federation ship with a Federation Captain.	Talent	5	Yes
7/30/2015 14:54:30	72008 - USS Thunderchild	Unique	Intercept	Federation	If a friendly ship within Range 1 of your ship is attacked, and your s hip is also in the attacking ship's firing arc, you may discard this card to force the attacking ship to perform its attack against your ship instead of the target ship. After the attack is complete, you may perform an additional green maneuver.	Talent	5	
7/30/2015 14:55:47	72008 - USS Thunderchild	Non-unique	Rapid Reload	Federation	This Upgrade counts as a [CREW], [TECH] or [WEAPON] Upgrade (your choice).  When you are instructed to place Time Tokens on one of your [WEAPON] Upgrades, you may disable this card to place only 1 Time Token instead of the required amount.	?	2	
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
7/18/2015 18:51:48	72009 - IKS T'Ong	Non-unique	Klingon	1	Klingon		0	0		
7/18/2015 18:52:59	72009 - IKS T'Ong	Unique	K'Temoc	5	Klingon	All of your Klingon Upgrades cost -1 SP.  The faction penalty is doubled for any non-Klingon Upgrades assigned to your ship.  K'Temoc may only field Klingon [ELITE TALENT] Upgrades.	1	3	Yes	
7/18/2015 18:53:59	72009 - IKS T'Ong	Unique	Morag	3	Klingon	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields.  Disable 1 Upgrade of your choice on the target ship and place an Auxiliary Power Token beside your ship.	0	2		
7/19/2015 17:12:54	72001 - USS Bellerophon	Non-unique	Federation	1	Federation		0	0		
7/25/2015 14:14:55	72010 - IRW Vrax	Non-unique	Romulan	1	Romulan		0	0		
7/25/2015 14:16:04	72010 - IRW Vrax	Unique	Suran	6	Romulan	ACTION: When attacking this round, during the Roll Attack Dice step, if you are within range 1 of a friendly ship, set 1 of your attack dice on the result of your choice.  This die cannot be rolled or re-rolled.	1	4		
7/30/2015 14:51:29	72008 - USS Thunderchild	Non-unique	Federation	1	Federation		0	0		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
7/18/2015 18:55:18	72009 - IKS T'Ong	Non-unique	Photon Torpedoes	Klingon	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
7/18/2015 18:57:01	72009 - IKS T'Ong	Non-unique	Concussive Charges	Klingon	4	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  For every uncanceled [HIT] or [CRIT] result, the target ship loses 1 token of your choice that has been placed beside it in the play area.  You may fire this weapon from your forward or rear firing arcs.	4	
7/19/2015 16:52:21	72001 - USS Bellerophon	Non-unique	Tricobalt Device	Federation	6	2-3	ATTACK: (Target Lock) Spend your target lock and discard this card to perform this attack.  You may only fire this weapon from your forward firing arc.  This Upgrade costs +4 SP if purchased for any ship other than an Intrepid-class ship.	6	Yes
7/25/2015 14:23:59	72010 - IRW Vrax	Non-unique	Photon Torpedoes	Romulan	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
7/25/2015 14:25:00	72010 - IRW Vrax	Non-unique	Plasma Torpedoes	Romulan	5	1-2	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may re-roll all of your blank results one time.  You may fire this weapon from your forward or rear firing arcs.	5	
7/25/2015 14:26:20	72010 - IRW Vrax	Non-unique	Flanking Attack	Romulan	6	2-3	ATTACK: Discard this card to perform this attack.  The defending ship rolls -1 defense die against this attack.  You may only fire this weapon from your forward firing arc and you may only perform this attack if your ship is not within the forward or rear firing arc of the defending ship.	6	
7/30/2015 14:56:55	72008 - USS Thunderchild	Non-unique	Quantum Torpedoes	Federation	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  If the target ship is hit, add 1 [HIT] result to your total damage.  You may fire this weapon from your forward or rear firing arcs.	6	
7/30/2015 14:57:30	72008 - USS Thunderchild	Non-unique	Photon Torpedoes	Federation	5	2-3	ATTACK: (Target Lock) Spend your target lock and place 3 Time Tokens on this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
7/19/2015 16:46:12	72001 - USS Bellerophon	Unique	William Ross	Federation	FLEET ACTION: Target a ship within Range 1-2 that is in your forward firing arc.  If the target ship attacks this round, that ship rolls 1 less attack die this round.	2	1	4	6	ACTION: Target a ship within Range 1-2 that is in your forward firing arc.  If the target ship attacks this round, that ship rolls 1 less attack die this round.	1	4	
7/25/2015 14:28:06	72010 - IRW Vrax	Unique	Velal	Romulan	FLEET ACTION: Each time you defend this round, during the Roll Defense Dice step, you may choose to roll 2 less defense dice.  If you do so, add 1 [EVADE] result to your roll.	1	1	3	5	ACTION: Each time you defend this round, during the Roll Defense Dice step, you may choose to roll 2 less defense dice.  If you do so, add 1 [EVADE] result to your roll.	1	3	
7/30/2015 14:58:06	72008 - USS Thunderchild	Unique	Shanthi	Federation	FLEET ACTION: Target a ship at Range 1-2. When attacking that ship this round, you may re-roll all of your blank results once. In addition, if the target ship is Cloaked, immediately flip that ship's [CLOAK] Token over to its red side.	1	1	2	4	ACTION: Target a ship at Range 1-2. When attacking that ship this round, you may re-roll all of your blank results once. In addition, if the target ship is Cloaked, immediately flip that ship's [CLOAK] Token over to its red side.	1	2		
7/30/2015 14:45:59	72008 - USS Thunderchild	Unique	Hayes	Federation	FLEET ACTION: All friendly ships within Range 1 of your ship gain +1 attack die this round (+2 attack dice against Borg ships).	1	1	3	5	ACTION: All friendly ships within Range 1 of your ship gain +1 attack die this round (+2 attack dice against Borg ships).	1	3	
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
