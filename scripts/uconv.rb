require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
9/9/2014 10:21:47	71510 - U.S.S. Stargazer	Secondary Impulse Reactor	Federation	During the Activation Phase, if you reveal a Red Maneuver and you have an Auxiliary Power Token beside your ship, you may disable this card to perform that Maneuver with no penalty.	Tech	1	Non-unique																			
9/9/2014 10:22:47	71510 - U.S.S. Stargazer	Jack Crusher	Federation	During the Modify Defense Dice step of the Combat Phase, you may discard this card and spend 1 [EVASIVE MANEUVERS] Token to add 2 [EVADE] results to your roll.	Crew	2	Unique																			
9/9/2014 10:24:21	71510 - U.S.S. Stargazer	Picard Maneuver	Federation	ACTION: If you performed a 1 [STRAIGHT], a 4 [STRAIGHT], or a 5 [STRAIGHT] Maneuver this round, discard this card and immediately perform an additional 5 [STRAIGHT] Maneuver.  Place an Auxiliary Power Token beside your ship.  All attacks against your ship this round are at -4 attack dice.	Talent	5	Unique																			
9/9/2014 10:26:25	71510b - Assimilation Target Prime	Regeneration Sequencers	Borg, Mirror Universe	"Whenever one of your Upgrades is discarded, repair 1 damage to your Hull. OR You may discard this card and spend 1 Drone Token to repair up to 2 damage to your Hull."	Borg	5	Non-unique																			
9/9/2014 10:28:14	71510b - Assimilation Target Prime	We Won't Go Back!	Mirror Universe	If your ship, its Captain, or any of its Upgrades are targeted by an Upgrade on an enemy ship, you may discard this card before that Upgrade takes effect to immediately make 1 free attack against that ship, if possible.  If the enemy ship is destroyed by this free attack, the enemy Upgrade does not take effect.	Talent	5	Mirror Universe Unique																			
9/9/2014 10:29:20	71510b - Assimilation Target Prime	Worf	Mirror Universe	If you inflict at least 1 damage (normal or critical) to an enemy ship during the Deal Damage step of the Combat Phase, you may discard this card to inflict 1 additional normal damage to that ship.	Crew	4	Mirror Universe Unique																			
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
9/9/2014 10:10:14	71510 - U.S.S. Stargazer	Jean-Luc Picard	6	Federation	"Add 1 [CREW] slot to your Upgrade Bar. ACTION: Disable all of your remaining Shields and immediately perform an additional green or white maneuver."	1	4	Unique																		
9/9/2014 10:12:52	71510b - Assimilation Target Prime	William T. Riker	7	Mirror Universe	Each time you perform a [BATTLE STATIONS], an [EVASIVE MANEUVERS], or a [TARGET LOCK] Action, place 1 additional Token of the appropriate type ([BATTLE STATIONS], [EVASIVE MANEUVERS], or [TARGET LOCK]) on this card.  During the Activation Phase,  you may spend 1 Token from this card and perform the corresponding Action as a free Action.	1	4	Mirror Universe Unique																		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
9/9/2014 10:14:24	71510 - U.S.S. Stargazer	Tactical Station	Federation			"Add 1 [WEAPON] Upgrade slot to your Upgrade Bar. When attacking, you may disable this card to gain +1 attack die until the End Phase. OR When attacking, you may discard this card to gain +2 attack dice until the End Phase."	4	Non-unique																		
9/9/2014 10:16:15	71510b - Assimilation Target Prime	Fire All Weapons	Mirror Universe	5	2-3	"ATTACK (Target Lock): Spend your target lock and disable this card to perform this attack.  You may fire this weapon from your forward or rear firing arcs. You may immediately make 1 additional attack with your Primary Weapon at a different enemy ship, if possible. This Upgrade costs +5 SP for any ship other than a Galaxy, Intrepid or Sovereign Class ship."	7	Non-unique																		
9/9/2014 10:17:27	71510b - Assimilation Target Prime	Quantum Torpedoes	Mirror Universe	5	2-3	"ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack. If the target ship is hit, add 1 [HIT] result to your total damage. You may fire this weapon from your forward or rear firing arcs."	6	Non-unique																		
9/9/2014 10:20:47	71510b - Assimilation Target Prime	Biogenic Weapon	Borg, Mirror Universe	7	2-3	"You must use 1 [BORG] and 1 [WEAPON] Upgrade slot to deploy this Upgrade to your ship. ATTACK: (Target Lock) Spend your target lock and discard this card to perform this attack.  In addition to normal damage, the opposing ship must discard 1 of its [CREW] Upgrades of its choice for each damage you inflict to that ship's Hull with this attack (max 2).  Add 1 Drone Token to your Captain Card for each [CREW] Upgrade that was discarded with this attack.  You cannot exceed your starting number of Drone Tokens."	8	Non-unique																		
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
    parts = l.split "\t"
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

weapons_lines = weapons_text.split "\n"

weapons_lines.each do |l|
    l = convert_line(l)
# Timestamp	Expansion Pack	Weapon Name	Faction	Attack	Range	Ability	Cost	Uniqueness																		
    parts = l.split "\t"
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

captains_lines = captains_text.split "\n"
captains_lines.each do |l|
  l = convert_line(l)
#Timestamp	Expansion Pack	Captain Name	Skill	Faction	Ability	Talents	Cost	Uniqueness																		  
  parts = l.split "\t"
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

admirals_lines = admirals_text.split "\n"
admirals_lines.each do |l|
  l = convert_line(l)
  # Timestamp		Admiral Name	Faction	Fleet Action	Skill Modifier	Talents	Cost	Captain-side Cost	Captain-side Action	Captain-side Talents	Captain-side Skill
  parts = l.split "\t"
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


officers_lines = officers_text.split "\n"
officers_lines.each do |l|
  l = convert_line(l)
# Timestamp	Officer Name	Ability	Cost																						  parts = l.split "\t"
  parts = l.split "\t"
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
