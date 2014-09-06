require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
8/18/2014 17:07:56	71526 - Enterprise	Enhanced Hull Plating	Federation	During the Roll Defense Dice step of the Combat Phase, if your ship is not Cloaked and you have no Active Shields, you may add up to 2 [EVADE] results to your defense roll. If you do so, place 1 Auxiliary Power Token beside your ship for each [EVADE] result you added with this Upgrade. This Upgrade may only be purchased for a Federation ship. You cannot deploy more than 1 "Enhanced Hull Plating" [TECH] Upgrade to any ship.	Tech	4																				
8/18/2014 17:20:33	71526 - Enterprise	T'Pol	Federation	Add 1 [TECH] slot to your Upgrade Bar. When attacking with your Primary Weapon, if there is a [SCAN] Token beside your ship, you may disable this card to force the defending ship to roll -2 defense dice against your attack (instead of -1 defense die). You do not pay a Faction penalty when deploying this card to a Vulcan Ship.	Crew	3	Unique																			
8/18/2014 17:22:40	71526 - Enterprise	Malcolm Reed	Federation	When attacking with your Primary Weapon, you may disable this card and discard 1 of your Secondary Weapon Upgrades to add +2 attack dice to your attack.	Crew	3	Unique																			
8/18/2014 17:24:41	71526 - Enterprise	Hoshi Sato	Federation	When defending, if there is a [SCAN] Token beside your ship, during the Roll Attack Dice step of the Combat Phase you may disable this card to force the attacking ship to roll 1 less attack die.	Crew	3	Unique																			
8/18/2014 17:26:51	71526 - Enterprise	Charles Tucker III	Federation	ACTION: If your ship is not in the forward firing arc of any enemy ships, repair 1 damage to your ship's Hull.	Crew	3	Unique																			
8/18/2014 17:29:01	71526 - Enterprise	Travis Mayweather	Federation	During the Activation Phase, if you reveal a 2 or 3 Bank Maneuver, you may disable this card to change it to a Turn Maneuver. If you do so, treat it as a Red Maneuver. The number and direction of the new Maneuver remain the same.	Crew	2	Unique																			
8/18/2014 17:30:54	71526 - Enterprise	Phlox	Federation	During the Activation Phase, you may disable this card to remove all Disabled Upgrade Tokens from all of your other [CREW] Upgrades.	Crew	2	Unique																			
8/18/2014 17:36:56	71526 - Enterprise	Tactical Alert	Federation	When attacking or defending, you may discard this card and spend a [BATTLESTATIONS] Token to re-roll any number of your attack or defense dice.	Talent	2	Unique																			
8/18/2014 17:52:14	71527 - Ni’Var	Vulcan Commandos	Vulcan	ACTION: If your ship is not Cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not Cloaked and has no Active Shields. Discard this card and any number of your other "Vulcan Commandos" [CREW] Upgrades. For each of your [CREW] Upgrades that you discarded with this Action disable 1 Upgrade of your choice on the target ship AND gain +1 attack die this round against that ship. This Upgrade may only be purchased for a Vulcan Ship.	Crew	3																				
8/18/2014 18:02:14	71527 - Ni’Var	Combat Vessel Variant	Vulcan	Your Primary Weapon and Hull Values are at +1. In addition, add 1 [WEAPON] Upgrade slot to your Upgrade Bar. This Upgrade may only be purchased for a Suurok Class ship. You cannot deploy more than 1 "Combat Vessel Variant" [TECH] Upgrade to any ship.	Tech	5																				
8/18/2014 18:04:05	71527 - Ni’Var	Tractor Beam	Vulcan	If you are attacked at Range 1, during the Modify Attack Dice step of the Combat Phase, you may disable this card to force the attacking ship to re-roll 1 of its attack dice of your choice.	Tech	1																				
8/18/2014 18:07:00	71527 - Ni’Var	Decisive Action	Vulcan	ACTION: If you attack an enemy ship this round whose Captain has a lower Skill Number than yours, during the Roll Attack Dice step of the Combat Phase, you may discard this card to choose 2 of your attack dice and place them both on [HIT] results. These dice cannot be rolled or re-rolled this round.	Talent	5	Unique																			
8/18/2014 18:21:13	71525 - Scout Cube	Third of Five	Borg	ACTION: Target a ship at Range 1-2. Discard this card and disable all [CREW] Upgrades on the target ship. This ability may be used against a ship that is Cloaked.  You cannot deploy this card to the same ship or fleet as "Hugh".	Crew	5	Unique																			
8/18/2014 18:22:46	71525 - Scout Cube	Second of Five	Borg	ACTION: Target a ship at Range 1-2. Discard this card and 1 Upgrade of your choice on the target ship. This ability may be used against a ship that is Cloaked.	Crew	3	Unique																			
8/18/2014 18:24:42	71525 - Scout Cube	Fourth of Five	Borg	ACTION: Target a ship at Range 1-2. Discard this card and disable up to 2 Shields on the target ship. Then disable up to 2 Upgrades of your choice on that ship. This ability may be used against a ship that is Cloaked.	Crew	5	Unique																			
8/18/2014 18:29:53	71525 - Scout Cube	Subspace Beacon	Borg	ACTION: Disable this card to target every friendly ship within Range 1-3 of your ship. Target ship(s) may immediately perform a [SCAN] Action as a free Action. Then place 1 [SCAN] Token beside your ship.	Tech	5																				
8/18/2014 18:32:20	71525 - Scout Cube	Long Range Scan	Borg	When attacking a ship at Range 3, if there is a [SCAN] Token beside your ship, during the Modify Defense Dice step of the Combat Phase you may disable this card to convert 1 of your opponent's [EVADE] or [BATTLESTATIONS] results to a blank result.	Tech	4																				
8/18/2014 18:34:04	71525 - Scout Cube	Borg Alcove	Borg	ACTION: Add 1 Drone Token to your Captain Card. You cannot exceed your Captain's starting number of Drone Tokens.	Borg	4																				
8/18/2014 18:36:19	71525 - Scout Cube	Scavenged Parts	Borg	Whenever one of your Upgrades is discarded, add 1 Drone Token to your Captain Card. You cannot exceed your Captain's starting number of Drone Tokens. You cannot deploy more than 1 "Scavenged Parts" [BORG] Upgrade to any ship.	Borg	2																				
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
8/18/2014 17:11:18	71526 - Enterprise	Jonathan Archer	5	Federation	Add 1 [CREW] Upgrade slot to your Upgrade Bar. ACTION: Disable up to 2 of your [CREW] Upgrades. For each [CREW] Upgrade you disabled with this Action, gain +1 attack die when attacking with your Primary Weapon AND increase your Skill Number by +1 until the End Phase.	1	3	Unique																		
8/18/2014 17:16:52	71526 - Enterprise	J. Hayes	3	Federation	ACTION: Gain +1 attack die this round. At the end of the Combat Phase, suffer 1 normal damage to your Hull.	0	2	Unique																		
8/18/2014 17:48:00	71527 - Ni’Var	Sopek	6	Vulcan	Add 1 [CREW] Upgrade slot to your Upgrade Bar. ACTION: Choose 1 of your [CREW] Upgrades that was discarded from your ship on a previous round. Re-deploy that [CREW] Upgrade to your ship and place an Auxiliary Power Token beside your ship.	1	4	Unique																		
8/18/2014 17:54:52	71527 - Ni’Var	Kuvak	4	Vulcan	After you move, if you perform an [EVADE] Action, you may place 2 [EVADE] Tokens beside your ship instead of 1 if your ship is not in the forward firing arc of any enemy ships.	0	2	Unique																		
8/18/2014 18:15:42	71525 - Scout Cube	Third of Five	3	Borg	At the start of the game, place 3 Drone Tokens on this card. During the Roll Defense Dice step of the Combat Phase, you may spend 1 Drone Token to roll +1 defense die. You cannot assign this card to the same ship or fleet as "Hugh".	0	2	Unique																		
8/18/2014 18:18:59	71525 - Scout Cube	Tactical Drone	2	Borg	At the start of the game, place 2 Drone Tokens on this card. Each time you defend, during the Roll Defense Dice step of the Combat Phase, you may spend 1 Drone Token to roll 1 attack die. A [HIT] or [CRITICAL] result damages the attacking ship as normal. The attacking ship does not roll any defense dice against this.	0	1	Unique																		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
8/18/2014 17:32:43	71526 - Enterprise	Aft Phase Cannon	Federation	3	1-3	ATTACK: Disable this cad to perform this attack. This Weapon can only be fired from your rear firing arc.	2																			
8/18/2014 17:34:42	71526 - Enterprise	Photonic Torpedoes	Federation	4	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack. You may fire this weapon from your forward or rear firing arcs.	2																			
8/18/2014 17:59:43	71527 - Ni’Var	Photonic Weapon	Vulcan	4	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack. You may re-roll one of your blank results. You may fire this weapon from your forward or rear firing arcs.	3																			
8/18/2014 18:27:15	71525 - Scout Cube	Magnetometric Guided Charge	Borg	3	1-3	ATTACK: Disable this card to perform this attack. You may convert 1 of your [BATTLESTATIONS] results into a [CRITICAL] result. Target ship does not roll defense dice against this attack. This Upgrade may only be purchased for a Borg ship.	5																			
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
8/18/2014 17:14:46	71526 - Enterprise	Unique	Maxwell Forrest	Federation	FLEET ACTION: Perform and additional 1 Maneuver (straight, bank or turn).	1	0	3	4	ACTION: Perform an additional 1 Maneuver (straight, bank or turn).	0	3													
8/18/2014 17:57:19	71527 - Ni’Var	Unique	V'Las	Vulcan	FLEET ACTION: Target a ship at Range 1-2. Disable 1 [CREW] Upgrade of your choice on the target ship. 	1	1	3	5	ACTION: Target a ship at Range 1-2. Disable 1 [CREW] Upgrade of your choice on the target ship.	1	3													
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
    unique = parts.shift == "Unique" ? "Y" : "N"
    setId = set_id_from_expansion(expansion)
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
# Timestamp	Expansion Pack	Weapon Name	Faction	Attack	Range	Ability	Cost																																							
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
    unique = parts.shift == "Unique" ? "Y" : "N"
    setId = set_id_from_expansion(expansion)
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
# Timestamp	Expansion Pack	Captain Name	Skill	Faction	Ability	Talents	Cost																			
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
  unique = parts.shift == "Unique" ? "Y" : "N"
  setId = set_id_from_expansion(expansion)
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
  expansion = parts.shift
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
  setId = set_id_from_expansion(expansion)
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
