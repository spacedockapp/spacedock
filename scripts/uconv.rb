require "enumerator"
#require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
8/22/2014 7:14:26	71786 - DS9 Promo	Quark	Ferengi	At the start of the game, place 1 non-Borg [TECH] of [WEAPON] Upgrade with a cost of 5 or less face down beneath this card. At any time, you may discard Quark to flip the Upgrade that is beneath this card face up and deploy it to your ship, even if it exceeds your ship's restrictions.	Crew	2	Unique																			
8/22/2014 7:16:06	71786 - DS9 Promo	Odo	Independent	ACTION: Target a ship at Range 1-3 (even if that ship is Cloaked or has Active Shields). Disable this card and one Upgrade on the target ship. If the Upgrade you disabled is a [CREW] Upgrade, you may then use that Upgrade's Action (if any) as a free Action this round.	Crew	5	Unique																			
8/22/2014 7:18:27	71786 - DS9 Promo	Vic Fontaine	Independent	This Upgrade counts as either a [CREW] or [TECH] Upgrade (your choice). If an enemy Upgrade would affect one of your [CREW] Upgrades, roll 2 defense dice. If you roll at least 1 [EVASIVE] result, ignore the effects of the enemy Upgrade. You do not pay a Faction penalty when deploying this Upgrade to a Federation ship.	Crew	3	Unique																			
8/22/2014 7:20:48	71786 - DS9 Promo	T'Kar	Klingon	ACTION: If your ship is not cloaked, disable all of your remaining Shields and target a ship at Range 1-2 that is not cloaked and has no Active Shields. Discards this card and 1 [CREW] Upgrade of your choice on the target ship. Then disable the Captain Card and all remaining [CREW] upgrades on the target ship. While the Captain Card is disabled, the target ship has a Skill of "1".	Crew	5	Unique																			
8/22/2014 7:22:27	71786 - DS9 Promo	T'Rul	Romulan	Add 1 Tech Upgrade slot to your Upgrade Bar. While your ship is cloaked, during the Roll Defense Dice step of the Combat Phase, you may choose to roll 3 less defense dice and add 1 [EVASIVE] result to your defense roll. If the "Cloaking Device" upgrade card is deployed to T'Rul's ship, you do not need to disable that card when you perform the Action listed on it.	Crew	4	Unique																			
8/22/2014 7:24:50	71786 - DS9 Promo	Elim Garak	Dominion	During the Modify Defense step of the Combat Phase, you may disable this card to add 1 [EVASIVE] result to your defense roll. You do not pay a Faction penalty when assigning Elim Garak or his [TALENT] Upgrade to your ship. If Elim Garak is ever disabled or discarded, you cannot use his [TALENT] Upgrade.	Crew	4	Unique																			
8/22/2014 7:26:16	71786 - DS9 Promo	Julian Bashir	Federation	ACTION: Move a Disabled Upgrade Token from one of your disabled [CREW] or [TECH] Upgrades to one of your non-disabled [CREW] or [TECH] upgrades. You may then immediately perform the Action (if any) listed on the Upgrade that you moved the token from as a free Action.	Crew	4	Unique																			
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
8/22/2014 7:30:51	71786 - DS9 Promo	Benjamin Sisko	7	Federation	During the Roll Defense Dice step of the Combat Phase, if your ship is in the forward firing arc of 2 or more ships, roll 1 extra defense die against all attacks from those ships. Each time your ship receives a Damage Card (normal or critical), incrase your Captain Skill by +1 for the rest of the game (max +2). The bonus Skill remains even if the damage is later repaired.	1	4	Unique																		
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
WEAPONSTEXT

admirals_text = <<-ADMIRALSTEXT
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
# Timestamp	Expansion Pack	Upgrade Name	Faction	Ability	Type	Cost																				
    parts = l.split "\t"
    parts.shift
    expansion = parts.shift
    unique = parts.shift == "Unique" ? "Y" : "N"
    title = parts.shift
    faction = parts.shift
    attack = parts.shift
    range = parts.shift
    ability = parts.shift
    upType = "Weapon"
    cost = parts.shift
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
