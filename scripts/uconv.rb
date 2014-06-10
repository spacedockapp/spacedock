require "enumerator"
require "nokogiri"
require "pathname"

require_relative "common"

# Timestamp		Upgrade Name	Faction	Ability	Type	Cost														
upgrade = <<-UPGRADETEXT
6/9/2014 16:01:15	Unique	Kunivas	Klingon	During the Modify Attack Dice step of the Combat Phase, you may discard this card to add 1 additional [HIT] result.	Crew	2
6/9/2014 16:02:36	Unique	Qapla'	Klingon	During the Roll Attack Dice step of the Combat Phase, before rolling any of your attack dice, you may discard this card to select one of your attack dice and set it on the side of your choice. That die cannot be rolled or re-rolled during the round in which you use this Upgrade.	Talent	2
6/9/2014 16:03:52		Tritium Intermix	Klingon	ACTION: Discard this card to flip all of your critical damage cards face down and then repair 1 damage to your ship's Hull. You may perform an [EVASIVE] Action as a free Action this round.	Tech	4
6/9/2014 16:12:42	Unique	Tal	Romulan	When attacking a ship with a [SCAN] Token beside it, during the Roll Attack Dice step of the Combat Phase, you may disable this card to gain +1 attack die.	Crew	2
6/9/2014 16:14:03		Advanced Cloaking	Romulan	When attacking while you are Cloaked, if there are no Auxiliary Power Tokens beside your ship, you may place an Auxiliary Power Token beside your ship before rolling any dice to keep your [CLOAK] Token from flipping to its red side.	Tech	4
6/9/2014 16:14:45	Unique	Lon Suder	Independent	During the Roll Attack Dice step of the Combat Phase, you may disable this card and spend a [BATTLE STATIONS] Token to add +1 additional attack die to your attack.	Crew	2
6/9/2014 16:14:52	Unique	Direct Command	Romulan	ACTION: Discard this card and spend your Target Lock to gain +2 attack dice this round.	Talent	2
6/9/2014 16:15:36	Unique	Sakonna	Independent	Add 1 additional [WEAPON] Updrade slot to your Upgrade Bar.  All of your [WEAPON] Upgrades with a cost of 5 or less cost -2 SP.	Crew	2
6/9/2014 16:17:24	Unique	Hijack	Independent	ACTION: Discard t his card to target a ship at Range 1-2 that is not cloaked and has no Active Shields.  Disable all of your remaining Shields an 1 [CREW] Upgrade on the target ship.  Then steal 1 face up [TECH] or [WEAPON] Upgrade Card of your choice from t hat ship, even if the Upgrade exceeds your ship's restrictions.	Talent	4
6/9/2014 16:24:21	Unique	Seskal	Dominion	If all your Shields have been destroyed, during the Roll Attack Dice step of the Combat Phase you may disable this card to gain +2 attack dice.	Crew	4
6/9/2014 16:25:57	Unique	First Strike	Dominion	During the Combat Phase, if you have 2 or more enemy ships in your forward firing arc within Range 1-3, you may discard this card to treat your Captain's Skill Number as a 10 until the End Phase.  This Upgrade may only be purchased for a ship with a Hull Value of 3 or less.	Talent	2
6/9/2014 16:27:39		Ion Thrusters	Dominion	During the Activation Phase, after you reveal a straight Maneuver, you may disable this card to add +1 to the Maneuver's number (i.e. a 2 becomes a 3, a 3 becomes a 4, etc).  No ship may be equipped with more than 1 Ion Thrusters Upgrade.	Tech	2
6/9/2014 16:32:53	Unique	Preemptive Strike	Federation	ACTION: Discard this card to target a ship at Range 2-3 in forward firing arc and roll 3 attack dice.  Any [HIT] or [CRIT] damages the target ship as normal.  The target ship rolls defense dice against this attack.	Talent	2
6/9/2014 16:34:55	Unique	Elizabeth Shelby	Federation	During the Modify Defense Dice step of the Combat Phase, you may re-roll one of your blank results.  If you are defending against an attack from a Borg ship, you roll +1 defense die during the Roll Defense Dice step and you may re-roll all of your blank results during the Modify Defense Dice step.	Crew	2
6/9/2014 16:36:57	Unique	Reginald Barclay	Federation	ACTION: Disable this card and roll 3 defense dice.  For each [EVADE] result, repair 1 damage to your Hull.  If you repair 2 or more damage with this Action in a single round, place an Auxiliary Power Token beside your ship.  If you repair 3 damage with this Action in a single round, discard this card.	Crew	4
UPGRADETEXT

captains_text = <<-CAPTAINSTEXT
6/9/2014 15:58:27	Unique	K'Nera	7	Klingon	ACTION: Target a ship at Range 1-2. The target ship may choose to disable one of its [CREW] Upgrades (of its choice). If the target ship chooses not to disable 1 of its [CREW] Upgrades or if it has no [CREW] Upgrades that are not already disabled, you gain +1 attack die to all of your attacks against that ship this round.	1	4
6/9/2014 16:09:55	Unique	Liviana Charvanek	6	Romulan	Whenever one of your [CREW] Upgrades is supposed to be disabled, roll 1 defense die. If you roll a [BATTLE STATIONS] result, that Upgrade is not disabled. If you are disabling the [CREW] Upgrade to perform its Action or ability, that Action or ability is still performed even if the Upgrade does not disable.	1	4
6/9/2014 16:11:11	Unique	Michael Eddington	6	Independent	At the start of the game, place 3 Mission Tokens on this card.  ACTION: Target a ship a Range 1-3 and discard 1 Mission Token from this card. Target ship rolls -2 attack dice against your ship for each of its attacks this round.	1	4
6/9/2014 16:23:08	Unique	Gul Damar	6	Dominion	All attacks made against your ship with Secondary Weapons are at -1 attack die.  All attacks made against your ship with Minefields are at -2 attack dice.	1	4
6/9/2014 16:28:05	Unique	Benjamin Maxwell	7	Federation	Immediately before you move, you may change your Maneuver.  If you do so, discard t his card during the End Phase.	1	4
6/9/2014 16:38:07		Federation	1	Federation		0	0
6/9/2014 16:38:26		Maquis	1	Independent		0	0
CAPTAINSTEXT

weapons_text = <<-WEAPONSTEXT
6/9/2014 16:00:20		Photon Torpedoes	Klingon	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may fire this weapon from your forward or rear firing arcs.	4
6/9/2014 16:11:06		Plasma Torpedoes	Romulan	4	1-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may fire this weapon from your forward or rear firing arcs.	4
6/9/2014 16:13:40		Focused Particle Beam	Independent	3	1-3	ATTACK: Disable this card to perform this attack. During the Roll Attack Dice step of the Combat Phase, if you roll a [HIT] or [CRIT] result on each one of your dice with this attack, continue rolling 1 additional attack die, one-at-a-time, until you do not roll a [HIT] or [CRIT] result (max 3 additional dice). Add all [HIT] or [CRIT] results from the additional dice to your total for this attack.  Any Black or [BATTLESTATIONS] results from the additional dice are not added.	4
6/9/2014 16:28:18		Photon Torpedoes	Dominion	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may fire this weapon from your forward or rear firing arcs.	4
6/9/2014 16:31:12		Photon Torpedoes	Federation	5	2-3	ATTACK: (Target Lock) Spend your target lock and disable this card to perform this attack.  You may fire this weapon from your forward or rear firing arcs.	4
WEAPONSTEXT

convert_terms(upgrade)
convert_terms(captains_text)
convert_terms(weapons_text)

new_upgrades = File.open("new_upgrades.xml", "w")
new_captains = File.open("new_captains.xml", "w")

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
