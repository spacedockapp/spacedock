require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
8/10/2017 18:16:13	72940 - USS Grissom	Non-unique	Captain's Discretion	Federation	FREE ACTION: Discard this card.  Perform the Action of a [CREW] Upgrade equipped to this ship.	Talent	4			
8/10/2017 18:17:13	72940 - USS Grissom	Unique	David Marcus	Federation	IF A [CREW] UPGRADE EQUIPPED TO THIS SHIP WOULD BE DISCARDED:  Discard this card instead.  WHEN DEFENDING: Discard this card.  Add 1 [EVADE].	Crew	3			
8/10/2017 18:18:04	72940 - USS Grissom	Unique	Saavik	Federation	WHEN DEFENDING: If this ship is within Range of a Planet Token:  This ship may convert 1 [BLANK] into 1 [EVADE].	Crew	1		1-2	
8/10/2017 18:19:53	72940 - USS Grissom	Non-unique	Federation Helmsman	Federation	ACTION: Place an [AUX] Token beside this ship.  Perform a White 1 [FORWARD], 1 [LEFT BANK], or 1 [RIGHT BANK] Maneuver.	Crew	3			
8/10/2017 18:21:15	72940 - USS Grissom	Unique	William T. Riker	Federation	Modify the Captain Skill of the Captain equipped to this ship by +3.  IF THE CAPTAIN EQUIPPED TO THIS SHIP IS DISABLED OR DISCARDED:  This ship's Captain Skill is 5.  IF THIS SHIP RECEIVES A FACE UP "COMMUNICATIONS FAILURE" OR "INJURED CAPTAIN" DAMAGE CARD:  Flip that damage card face down.	Crew	4			
8/10/2017 18:24:43	72940 - USS Grissom	One Per Ship	Comm Station	Federation	Add 1 [CREW] to this ship's Upgrade Bar.  ACTIVATION PHASE: Disable this card and target a friendly ship.  This game round, replace the Captain Skill of this ship's Captain with the Captain Skill of the target ship's Captain.	Tech	4	Yes	1-2	
8/10/2017 18:25:31	72940 - USS Grissom	One Per Ship	Close-Range Scan	Federation	ACTIVATION PHASE: If this ship performed a [SCAN] Action, disable 1 Shield.  Place a [SCAN] Token beside this ship.	Tech	3			
8/10/2017 18:27:09	72940 - USS Grissom	Unique	Genesis Effect	Federation	SETUP: Place 1 [CREW] Upgrade with a cost of 5 SP or less face down beneath this card.  END PHASE: If this ship is within Range of a Planet Token, disable all of its Shields.  Flip the [CREW] Upgrade beneath this card face up, place 2 [TIME] Tokens on it, and equip it to this ship, even if it exceeds its restrictions.	Tech	2	Yes	1-3	
8/10/2017 18:32:17	72936p - Chronological Chaos	Unique	Data	Federation	ACTION: Discard this card and target an opposing ship.  Rolle one attack die and consult the below chart: [CRIT]: Discard a card of your choice on the target ship. [BATTLE STATIONS]: Discard the Captain of the target ship. [HIT]: Discard a [CREW] on the target ship. [BLANK]: Nothing happens.	Crew	5		1-2	
8/10/2017 18:33:02	72936p - Chronological Chaos	Unique	Nanclus	Romulan	ACTION: Discard this card and target an opposing ship.  This game round, the target ship rolls +1 attack die but cannot roll defense dice.	Crew	5		1-3	
8/17/2017 17:04:50	72938 - IKS Ves Batlh	One Per Ship	Dispersive Armor	Klingon	WHEN DEFENDING: Disable this card.  This game round, replace the attacking ship's Primary Weapon Value with 4.  For the remainder of this game round, the attacking ship's Primary Weapon Value can not be replaced or modified.	Tech	4	Yes		3+ Hull
8/17/2017 17:05:33	72938 - IKS Ves Batlh	Non-unique	Reactor Pit	Klingon	PLANNING PHASE: Disable this card.  Remove an [AUX] Token from beside this ship.	Tech	3			
8/17/2017 17:07:13	72937 - Dreadnaught (card pack)	One Per Ship	Photon Detonation	Klingon	This card counts as either a [TECH] Upgrade or a [WEAPON] Upgrade.  ACTION: Disable this card, place 3 [TIME] Tokens on a Photon Torpedoes Upgrade equipped to this ship, and target a Minefield Token.  Remove the Minefield from play.	?	3	Yes	1-2	
8/17/2017 17:08:44	72938 - IKS Ves Batlh	Unique	Goroth	Klingon	Add 1 [CREW] to this ship's Upgrade Bar.  ACTION: Discard this card, discard 1 [CREW] Upgrade, and target an opposing ship.  Disable the Captain equipped to the target ship.	Crew	2		1-2	
8/17/2017 17:09:39	72938 - IKS Ves Batlh	Unique	Kolos	Klingon	IF THE CAPTAIN EQUIPPED TO THIS SHIP WOULD BE DISABLED OR DISCARDED:  Discard this card instead.	Crew	3			
8/17/2017 17:11:56	72938 - IKS Ves Batlh	Unique	DNA Encoded Message	Klingon	SETUP:  Place 3 [KLINGON] [TALENT] Upgrades face down beneath this card.  ACTIVATION PHASE: Discard this card.  Flip 1 of the [KLINGON] [TALENT] Upgrades beneath this card face up and equip it to the Captain equipped to this ship.  Remove the other 2 face down [KLINGON] [TALENT] Upgrades from the game.	Talent	5			
8/17/2017 17:12:59	72937 - Dreadnaught (card pack)	Non-unique	Final Stage Targeting	Dominion	This ship can only target ships that it has a [TARGET LOCK] Token on.  WHEN ATTACKING:  Defending ships must skip the Modify Defense Dice step.	Tech	3			
8/17/2017 17:15:13	72937 - Dreadnaught (card pack)	Non-unique	Captured	Independent	This Upgrade does not require an Upgrade Slot.  This ship gains the [INDEPENDENT] Faction.  WHEN DEFENDING: If the attacking ship shares a Faction with this ship other than [INDEPENDENT]:  The attacking ship rolls +1 attack die.	?	1	Yes		
8/17/2017 17:17:41	72937 - Dreadnaught (card pack)	Unique	B'Elanna's Codes	Independent	IF ONE OR MORE [TIME] TOKENS WOULD BE PLACED ON A [WEAPON] UPGRADE EQUIPPED TO T HIS SHIP:  Place those [TIME] Tokens on this card instead.  WHEN A [WEAPON] UPGRADE EQUIPPED TO THIS SHIP WOULD BE DISCARDED:  Discard this card instead.	Tech	3			
8/17/2017 17:18:37	72937 - Dreadnaught (card pack)	Unique	B'Elanna Torres	Independent	WHEN ATTACKING:  This ship may re-roll 1 [BLANK].  If the defending ship is a [DOMINION] ship, this ship may also convert 1 [BLANK] into 1 [HIT].	Crew	1			
8/17/2017 17:21:05	72937 - Dreadnaught (card pack)	Unique	Shield Adaptation	Dominion	Discard this card if this ship has no active Shields.  WHEN DEFENDING:  The attacking ship rolls -2 attack dice when firing a Primary Weapon and -1 attack die when firing a [WEAPON] Upgrade.	Tech	5	Yes		4+ Hull
8/17/2017 17:22:32	72939 - Prototype 02	Non-unique	Propulsion Matrix	Romulan	ACTIVATION PHASE: If this ship reveals a 3 [FORWARD] Maneuver:  This ship may perform a 4 [FORWARD] or a 5 [FORWARD] Maneuver instead.  If it does, place an [AUX] Token beside this ship.	Tech	3			
8/17/2017 17:23:51	72939 - Prototype 02	One Per Ship	Repair Protocol	Romulan	END PHASE: Place 3 [TIME] Tokens on this card.  Repair 1 damage to this ship's Shields or Hull.	Tech	4	Yes		Romulan Drone Ship
8/17/2017 17:25:42	72939 - Prototype 02	One Per Ship	Evasive Protocol	Romulan	COMBAT PHASE: If this ship is in the Primary or Secondary Firing Arc of an opposing ship, place 3 [TIME] Tokens on this card.  Perform a [SENSOR ECHO] Action as a Free Action.  If this ship does, remove an opposing [TARGET LOCK] Token from this ship.	Tech	3			Romulan Drone Ship
8/17/2017 19:27:05	72939 - Prototype 02	Unique	Disguise Protocol	Romulan	WHEN DEFENDING: Place 3 [TIME] Tokens on this card.  The attacking ship rolls -2 attack dice.	Tech	4	Yes		Romulan Drone Ship
8/21/2017 22:36:16	72938 - IKS Ves Batlh	Non-unique	Tellarite Bounty Hunter	Independent	WHEN THIS CARD WOULD BE DISCARDED:  Discard an [EVADE] Token from beside an opposing ship.	Crew	1		1-2	
9/29/2017 16:47:41	72941p - Resource Rumble	Unique	Elizabeth Shelby	Federation	WHEN DEFENDING:  This ship may re-roll one of its [BLANK] results.  If the attacking ship is a [BORG] ship, this ship rolls +1 defense die and may re-roll all of its [BLANK] results.	Crew	2			
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
8/17/2017 16:53:40	72939 - Prototype 02	Non-unique	Triphasic Emitters	Romulan	?	?	SETUP: Choose a Non-[BORG] [WEAPON] Upgrade with a cost of 5 SP or less and place it face down beneath this card.  ATTACK: Discard this card.  Flip the card that is beneath this card face up and perform the attack listed on that card (if possible).  After the attack resolves, discard that card.	2	Yes	
8/17/2017 16:56:36	72937 - Dreadnought (card pack)	Non-unique	Quantum Torpedoes	Dominion	5	2-3	ATTACK: Spend this ship's [TARGET LOCK] Token and place 2 [TIME] Tokens on this card.  If this attack hits, add 1 [HIT] or add 2 [HITS] if this [WEAPON] is equipped to a Cardassian ATR-4107.	3		
8/17/2017 16:57:45	72937 - Dreadnought (card pack)	One Per Ship	Plasma Pulse	Dominion	4	1-2	ATTACK: Discard this card.  The defending ship cannot spend [BATTLE STATIONS] or [EVADE] Tokens.  WHEN DEFENDING: Discard this card.  The attacking ship suffers 1 [CRIT].	3		
8/17/2017 16:58:49	72937 - Dreadnought (card pack)	Non-unique	Plasma Wave	Dominion	4	1	ATTACK: Place 2 [TIME] Tokens on this card and target all opposing ships.	3	Yes	
8/17/2017 17:01:15	72938 - IKS Ves Batlh	Non-unique	Photon Torpedoes	Klingon	4	2-3	ATTACK: If this ship has a [TARGET LOCK] Token on the defending ship, place 2 [TIME] Tokens on this card.  This ship may convert 1 [BATTLE STATIONS] into a [CRIT].	2		
8/17/2017 17:26:58	72939 - Prototype 02	One Per Ship	Tellarite Disruptor Banks	Independent	4	1-3	ATTACK: Place 3 [TIME] Tokens on this card.  If there is at least 1 unconcealed [HIT], modify the defender's Agility Value by -1 until the end of the game round.	3		
8/17/2017 17:30:10	72937 - Dreadnought (card pack)	Non-unique	Thoron Shock Emitter	Dominion	6	1-3	ATTACK: Discard this card.  This ship may re-roll any number of attack dice.	2	Yes	Cardassian ATR-4107
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
