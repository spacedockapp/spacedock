require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
5/28/2015 22:32:37	71802 - USS Prometheus	Unique	EMH Mark II	Federation	This Upgrade counts as either a [CREW] Upgrade or a [TECH] Upgrade (your choice).  ACTION: Discard this card to target a ship at Range 1.  Disable all [CREW] Upgrades on the target ship.	?	5	Yes
5/28/2015 22:35:05	71802 - USS Prometheus	Unique	Tactical Prototype	Federation	You may disable this card to perform an [EVADE], [SCAN] or [BATTLE STATIONS] Action while you have an Auxiliary Power Token beside your ship.  Your ship must have the appropriate Action on its Action Bar in order to use this ability, and you cannot perform any free Actions during the round in which you use this ability.	Tech	4	
5/28/2015 22:42:30	71802 - USS Prometheus	Unique	Romulan Hijackers	Romulan	While this card is assigned to your ship, you may only have a Romulan Captain and Romulan [CREW] Upgrades assigned to your ship and all of your non-Borg [TECH] and [WEAPON] Upgrades cost -1 SP.  In addition, if this card is assigned to a non-Romulan ship, you do not pay a Faction penalty for any of your Romulan upgrades (including this one).  When attacking with your Primary Weapon, if your ship is not within Range 1-3 of any other friendly ships, during the Roll Attack Dice step, you may disable this card to gain +1 attack die.	Crew	4	Yes
5/30/2015 12:14:17	71804 - IKS Ning'tao	Unique	Darok	Klingon	After your ship moves, you may discard Darok to perform an additional Action as a free Action this round.  This Upgrade may only be purchased for a Klingon ship.	Crew	5	Yes
5/30/2015 12:15:32	71804 - IKS Ning'tao	Unique	Inverse Graviton Burst	Klingon	ACTION: Discard this card to target every ship at Range 1-3. Place 1 Auxiliary Power Token beside your ship and each of the targeted ships.  This Upgrade costs +5 SP if purchased for a non-Klingon ship.	Tech	5	Yes
5/30/2015 12:17:05	71804 - IKS Ning'tao	Unique	Long Live the Empire!	Klingon	When attacking with your Primary Weapon, during the Roll Attack Dice step, you may discard this card to add up to 3 attack die to your attack.  If you do so, immediately after you complete the attack, your ship suffers 1 damage to your Hull or Shields (your choice) for each additional die you added with this ability.  This Upgrade may only be purchased for a Klingon Captain assigned to a Klingon ship.	Talent	5	Yes
6/3/2015 16:45:53	71802 - USS Prometheus	Non-unique	Regenerative Shielding	Federation	During the Planning Phase, you may disable this card to repair 1 of your Shield Tokens.  This Upgrade costs +4 SP for any ship other than the U.S.S. Prometheus and no ship may be equipped with more than 1 Regenerative Shielding Upgrade.	Tech	4	Yes
6/3/2015 16:47:28	71802 - USS Prometheus	Unique	Ablative Hull Armor	Federation	When defending, during the Modify Defense Dice step, convert all of your opponent's [CRIT] results into [HIT] results.  Place all t he damage cards that your ship receives beneath this card.  Once there are 3 damage cards beneath this card, discard this Upgrade and all damage cards beneath it.  All excess damage affects the ship as normal.  This Upgrade may only be purchased for a Prometheus Class ship.	Tech	7	Yes
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
5/28/2015 22:44:38	71802 - USS Prometheus	Unique	The Doctor	2	Federation	At the start of the Combat Phase, you may attempt to increase your Skill Number.  If you do so, roll 1 attack die.  If you roll a [HIT] or [CRIT] result, your Captain Skill is a 10 until the End Phase.  Otherwise, your Captain Skill is a 0 until the End Phase.  Either way, place an Auxiliary Power Token beside your ship.	0	1		
5/28/2015 22:45:12	71802 - USS Prometheus	Non-unique	Federation	1	Federation		0	0		
5/28/2015 22:45:27	71804 - IKS Ning'tao	Non-unique	Klingon Starship	1	Klingon		0	0		
5/28/2015 22:47:59	71804 - IKS Ning'tao	Unique	Kor	8	Klingon	Add 1 [CREW] Upgrade Slot to your Upgrade Bar.  Each time you attack, during the Modify Attack Dice step, you may select any number of attack dice (up to the number of non-disabled [CREW] Upgrades assigned to your ship) and re-roll those dice once.	1	5	Yes	
5/30/2015 12:11:42	71804 - IKS Ning'tao	Unique	Worf	4	Klingon	When defending, during the Roll Defense Dice step, you may roll up to 2 additional defense dice.  If you do so, place 1 Auxiliary Power Token beside your ship for each extra die you rolled.	0	3		
5/30/2015 12:12:37	71804 - IKS Ning'tao	Unique	Kor	6	Klingon	ACTION: If your ship is not cloaked, all enemy ships at Range 1-3 must attack your ship this round, if possible.  When defending against each of these attacks, roll +2 defense dice.	1	4		
6/3/2015 16:36:46	71802 - USS Prometheus	Unique	Rekar	5	Romulan	When attacking with a Secondary Weapon, you may add +1 attack die to the attack.  If you do so, discard that [WEAPON] Upgrade after the attack is completed.	0	3		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
5/30/2015 12:24:06	71804 - IKS Ning'tao	Non-unique	Photon Torpedoes	Klingon	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may convert 1 of your [BATTLE STATIONS] results into 1 [CRIT] result.  You may fire this weapon from your forward or rear firing arcs.	5	
5/30/2015 12:25:52	71804 - IKS Ning'tao	Non-unique	Strafing Attack	Klingon	3	1	ATTACK: Discard this card to perform this attack.  After completing this attack, you may immediately target up to 2 other ships within Range 1 of your ship and make an additional 3 dice attack against each of those ships.  The additional target ships do not need to be in your forward firing arc.  You cannot perform this attack the if you performed a Full Astern Maneuver this round.	6	
5/30/2015 12:29:37	71802 - USS Prometheus	Non-unique	Photon Torpedoes	Federation	5	2-3	ATTACK: (Target Lock) Spend your Target Lock and disable this card to perform this attack.  If fired from a Prometheus class ship, add +1 attack die.  You may fire this weapon from your forward or rear firing arcs.	5	
6/3/2015 16:43:37	71802 - USS Prometheus	Unique	Multi-Vector Assault Mode	Federation	8	1	ACTION: Place a Multi-Vector Assault Mode Token beside your ship.  You cannot perform any free Actions this round.  ATTACK (Target Lock): Disable this card, spend your target lock and spend your Multi-Vector Assault Mode Token to perform this attack.  You may fire this weapon in any direction.  This Upgrade may only be purchased for a Prometheus Class ship.	8	Yes
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
5/28/2015 22:50:51	71804 - IKS Ning'tao	Unique	Martok	Klingon	FLEET ACTION: When attacking with your Primary Weapon, gain +1 attack die and roll -2 defense dice this round.  You may convert 1 of your [HIT] results into a [CRIT] result.	1	1	4	7	ACTION: When attacking with your Primary Weapon, gain +1 attack die and roll -2 defense dice this round.  You may convert 1 of your [HIT] results into a [CRIT] result.	1	4	
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
