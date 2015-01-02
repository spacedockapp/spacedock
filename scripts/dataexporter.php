<?php

$opts = getopt('p:');
if ( isset($opts['p']) ) {
	$print = $opts['p'];
} else {
	$print = "all";
}

class MyDB extends SQLite3
{
	function __construct()
	{
		$this->open('data.db',SQLITE3_OPEN_READONLY);
	}

	function dataversion()
	{
		return gmdate("Y-m-d@H-i",filemtime("data.db"));
	}

	function factionforid($id)
	{
		$stmt = $this->prepare("SELECT faction from Factions WHERE _id = ?");
		$stmt->bindParam(1, $id, SQLITE3_INTEGER);
		$result = $stmt->execute();
		if ( $value = $result->fetchArray() ) {
			return $value["faction"];
		} else {
			return "";
		}
	}

	function setsforid($id)
	{
		$stmt = $this->prepare("SELECT set_id from Sets_Map WHERE id = ?");
		$stmt->bindParam(1, $id, SQLITE3_TEXT);
		$result = $stmt->execute();
		$sets = array();
		while ( $value = $result->fetchArray() ) {
			array_push($sets,$value["set_id"]);
		}
		return implode(",",$sets);
	}
}

function print_maneuvers($color,$moves)
{
	$maneuver = "\t\t\t<Maneuver speed=\"%d\" kind=\"%s\" color=\"$color\" />\n";
	foreach ( $moves as $move ) {
		$speed = $move[0];
		switch ($move[1]) {
			case "F":
				printf ($maneuver,$speed,"straight");
				break;
			case "R":
				printf ($maneuver,$speed * -1,"straight");
				break;
			case "A":
				printf ($maneuver,$speed,"about");
				break;
			case "T":
				printf ($maneuver,$speed,"right-turn");
				printf ($maneuver,$speed,"left-turn");
				break;
			case "B":
				printf ($maneuver,$speed,"right-bank");
				printf ($maneuver,$speed,"left-bank");
				break;
			case "S":
				printf ($maneuver,$speed,"right-spin");
				printf ($maneuver,$speed,"left-spin");
				break;
			case "K":
				printf ($maneuver,$speed,"right-flank");
				printf ($maneuver,$speed,"left-flank");
				break;
			case "0":
				printf ($maneuver,$speed,"stop");
				break;
			case "4":
				printf ($maneuver,$speed,"right-45-degree-rotate");
				printf ($maneuver,$speed,"left-45-degree-rotate");
				break;
			case "9":
				printf ($maneuver,$speed,"right-90-degree-rotate");
				printf ($maneuver,$speed,"left-90-degree-rotate");
				break;
			case '':
				break;
			default:
				printf ("Unknown Maneuver: '%s'\n", $move);
		}
	}
}

$db = new MyDB();

if ( $print == "all" ) {
header("Content-Type: text/xml");
print("<Data version=\"".$db->dataversion()."\">\n");
}

if ( $print == "all" || $print == "shipclass" ) {
print("<ShipClassDetails>\n");
$r = $db->query("SELECT * FROM ShipClasses");
while ($ship = $r->fetchArray()) {
	print <<<EOT
	<ShipClassDetail>
		<Name>$ship[name]</Name>
		<Id>$ship[id]</Id>
		<FrontArc>$ship[frontarc]</FrontArc>
		<RearArc>$ship[reararc]</RearArc>
		<Maneuvers>

EOT;
####### 1  b  t  a  s  2  b  t  a  s  3  b  t  a  s  4  b  a  s  5  a  s  6  a  s  -1  -2  -3
####### 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25  26  27  28
	$redmoves = str_split($ship["redmoves"],2);
	$whitemoves = str_split($ship["whitemoves"],2);
	$greenmoves = str_split($ship["greenmoves"],2);
	print_maneuvers( "red",$redmoves );
	print_maneuvers( "white",$whitemoves );
	print_maneuvers( "green",$greenmoves );
	print <<<EOT
		</Maneuvers>
	</ShipClassDetail>

EOT;
}
	print "\t</ShipClassDetails>\n";
}

if ( $print == "all" || $print == "ships" ) {
	print "\t<Ships>\n";
$r = $db->query("SELECT * FROM Ships");

//CREATE TABLE IF NOT EXISTS Ships (id text,title text,class text,classid text,uniq integer not null,faction integer not null,faction2 integer not null,attack integer not null,agility integer not null,hull integer not null,shield integer not null,cost integer not null,evasive integer not null,targetlock integer not null,scan integer not null,battlestations integer not null,cloak integer not null,sensorecho integer not null,regenerate integer not null,crew integer not null,tech integer not null,weapon integer not null,borg integer not null,has360 integer not null,ability blob,primary key(id asc))");

while ($ship = $r->fetchArray()) {
	$up = "N";
	$um = "N";
	$uniq = $ship["uniq"];
	switch( $ship["id"] ) {
		case "federation_attack_fighter_op6prize":
		case "hideki_class_attack_fighter_op5prize":
		case "1st_wave_attack_fighters_71754":
			$caplimit = 0;
			break;
		default:
			$caplimit = 1;
	}
	$faction = $db->factionforid($ship["faction"]);
	$faction2 = $db->factionforid($ship["faction2"]);
	$sets = $db->setsforid($ship["id"]);
	if ($uniq == 1) {
		$up = "Y";
	} elseif ($uniq == -1) {
		$um = "Y";
	}
	print <<<EOT
	<Ship>
		<Id>$ship[id]</Id>
		<Title>$ship[title]</Title>
		<ShipClass>$ship[class]</ShipClass>
		<ShipClassDetailsId>$ship[classid]</ShipClassDetailsId>
		<Unique>$up</Unique>
		<MirrorUniverseUnique>$um</MirrorUniverseUnique>
		<Faction>$faction</Faction>
		<AdditionalFaction>$faction2</AdditionalFaction>
		<Attack>$ship[attack]</Attack>
		<Agility>$ship[agility]</Agility>
		<Hull>$ship[hull]</Hull>
		<Shield>$ship[shield]</Shield>
		<Cost>$ship[cost]</Cost>
		<EvasiveManeuvers>$ship[evasive]</EvasiveManeuvers>
		<TargetLock>$ship[targetlock]</TargetLock>
		<Scan>$ship[scan]</Scan>
		<Battlestations>$ship[battlestations]</Battlestations>
		<Cloak>$ship[cloak]</Cloak>
		<SensorEcho>$ship[sensorecho]</SensorEcho>
		<Regenerate>$ship[regenerate]</Regenerate>
		<Crew>$ship[crew]</Crew>
		<Tech>$ship[tech]</Tech>
		<Weapon>$ship[weapon]</Weapon>
		<Borg>$ship[borg]</Borg>
		<SquadronUpgrade>$ship[squad]</SquadronUpgrade>
		<Has360Arc>$ship[has360]</Has360Arc>
		<Ability>$ship[ability]</Ability>
		<CaptainLimit>$caplimit</CaptainLimit>
		<Set>$sets</Set>
	</Ship>

EOT;
}
	print "\t</Ships>\n";
}

if ( $print == "all" || $print == "captains" ) {
	print "\t<Captains>\n";
$r = $db->query("SELECT * FROM Captains");

while ($cap = $r->fetchArray()) {
//CREATE TABLE IF NOT EXISTS Captains (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,skill integer not null,talent integer not null,cost integer not null,special text,ability blob,primary key(id asc))");
	$up = "N";
	$um = "N";
	$uniq = $cap["uniq"];
	$faction = $db->factionforid($cap["faction"]);
	$faction2 = $db->factionforid($cap["faction2"]);
	$sets = $db->setsforid($cap["id"]);
	if ($uniq == 1) {
		$up = "Y";
	} elseif ($uniq == -1) {
		$um = "Y";
	}
	print <<<EOT
	<Captain>
		<Id>$cap[id]</Id>
		<Title>$cap[title]</Title>
		<Unique>$up</Unique>
		<MirrorUniverseUnique>$um</MirrorUniverseUnique>
		<Faction>$faction</Faction>
		<AdditionalFaction>$faction2</AdditionalFaction>
		<Skill>$cap[skill]</Skill>
		<Talent>$cap[talent]</Talent>
		<Cost>$cap[cost]</Cost>
		<Special>$cap[special]</Special>
		<Ability>$cap[ability]</Ability>
		<Set>$sets</Set>
	</Captain>

EOT;
}
$r = $db->query("SELECT * FROM Admirals");

while ($cap = $r->fetchArray()) {
	$up = "N";
	$um = "N";
	$uniq = $cap["uniq"];
	$faction = $db->factionforid($cap["faction"]);
	$faction2 = $db->factionforid($cap["faction2"]);
	$sets = $db->setsforid($cap["id"]);
	if ($uniq == 1) {
		$up = "Y";
	} elseif ($uniq == -1) {
		$um = "Y";
	}
	$id_parts = explode("_",$cap["id"]);
	$lastpart = array_pop($id_parts);
	array_push( $id_parts, "cap",$lastpart );
	$capid = implode("_",$id_parts);
	print <<<EOT
	<Captain>
		<Id>$capid</Id>
		<Title>$cap[title]</Title>
		<Unique>$up</Unique>
		<MirrorUniverseUnique>$um</MirrorUniverseUnique>
		<Faction>$faction</Faction>
		<AdditionalFaction>$faction2</AdditionalFaction>
		<Skill>$cap[skill]</Skill>
		<Talent>$cap[talent]</Talent>
		<Cost>$cap[cost]</Cost>
		<Special>$cap[special]</Special>
		<Ability>$cap[ability]</Ability>
		<Set>$sets</Set>
	</Captain>

EOT;
}
	print "\t</Captains>\n";
}

if ( $print == "all" || $print == "admirals" ) {
	print "\t<Admirals>\n";
$r = $db->query("SELECT * FROM Admirals");
//CREATE TABLE IF NOT EXISTS Admirals (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null, skill integer not null,talent integer not null,skillmodifier integer not null,cost integer not null,special text,ability blob,admiral_ability blob,primary key(id asc))");

while ($adm = $r->fetchArray()) {
	$up = "N";
	$um = "N";
	$uniq = $adm["uniq"];
	$faction = $db->factionforid($adm["faction"]);
	$faction2 = $db->factionforid($adm["faction2"]);
	$sets = $db->setsforid($adm["id"]);
	if ($uniq == 1) {
		$up = "Y";
	} elseif ($uniq == -1) {
		$um = "Y";
	}
	print <<<EOT
	<Admiral>
		<Id>$adm[id]</Id>
		<Title>$adm[title]</Title>
		<Unique>$up</Unique>
		<MirrorUniverseUnique>$um</MirrorUniverseUnique>
		<Faction>$faction</Faction>
		<AdditionalFaction>$faction2</AdditionalFaction>
		<Skill>$adm[skill]</Skill>
		<Talent>$adm[talent]</Talent>
		<Cost>$adm[cost]</Cost>
		<Special>$adm[special]</Special>
		<Ability>$adm[ability]</Ability>
		<AdmiralAbility>$adm[admiral_ability]</AdmiralAbility>
		<AdmiralCost>$adm[cost]</AdmiralCost>
		<AdmiralTalent>$adm[talent]</AdmiralTalent>
		<SkillModifier>$adm[skillmodifier]</SkillModifier>
		<Set>$sets</Set>
	</Admiral>

EOT;
}
	print "\t</Admirals>\n";
}

if ( $print == "all" || $print == "upgrades" ) {
	print "\t<Upgrades>\n";

//CREATE TABLE IF NOT EXISTS Talent (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,cost integer not null,special text,ability blob,primary key(id asc))");
	foreach (array("Talent","Tech","Crew","Borg","Squadron") as $upg_type) {
	$r = $db->query("SELECT * FROM $upg_type");
	while ($upg = $r->fetchArray()) {
	$up = "N";
	$um = "N";
	$uniq = $upg["uniq"];
	$faction = $db->factionforid($upg["faction"]);
	$faction2 = $db->factionforid($upg["faction2"]);
	$sets = $db->setsforid($upg["id"]);
	if ($uniq == 1) {
		$up = "Y";
	} elseif ($uniq == -1) {
		$um = "Y";
	}
	print <<<EOT
	<Upgrade>
		<Id>$upg[id]</Id>
		<Title>$upg[title]</Title>
		<Type>$upg_type</Type>
		<Unique>$up</Unique>
		<MirrorUniverseUnique>$um</MirrorUniverseUnique>
		<Faction>$faction</Faction>
		<AdditionalFaction>$faction2</AdditionalFaction>
		<Cost>$upg[cost]</Cost>
		<Special>$upg[special]</Special>
		<Ability>$upg[ability]</Ability>
		<Set>$sets</Set>
	</Upgrade>

EOT;
	}
	}
	$r = $db->query("SELECT * FROM Weapon");
	while ($upg = $r->fetchArray()) {
	$up = "N";
	$um = "N";
	$uniq = $upg["uniq"];
	$faction = $db->factionforid($upg["faction"]);
	$faction2 = $db->factionforid($upg["faction2"]);
	$sets = $db->setsforid($upg["id"]);
	if ($uniq == 1) {
		$up = "Y";
	} elseif ($uniq == -1) {
		$um = "Y";
	}
	print <<<EOT
	<Upgrade>
		<Id>$upg[id]</Id>
		<Title>$upg[title]</Title>
		<Type>Weapon</Type>
		<Unique>$up</Unique>
		<MirrorUniverseUnique>$um</MirrorUniverseUnique>
		<Faction>$faction</Faction>
		<AdditionalFaction>$faction2</AdditionalFaction>
		<Cost>$upg[cost]</Cost>
		<Special>$upg[special]</Special>
		<Ability>$upg[ability]</Ability>
		<Attack>$upg[attack]</Attack>
		<Range>$upg[range]</Range>
		<Set>$sets</Set>
	</Upgrade>

EOT;
	}
	print "\t</Upgrades>\n";
}

if ( $print == "all" || $print == "resources" ) {
	print "\t<Resources>\n";
$r = $db->query("SELECT * FROM Resources");

while ($res = $r->fetchArray()) {
	$up = "N";
	$um = "N";
	$uniq = $res["uniq"];
	$sets = $db->setsforid($res["id"]);
	if ($uniq == 1) {
		$up = "Y";
	} elseif ($uniq == -1) {
		$um = "Y";
	}
	print <<<EOT
	<Resource>
		<Id>$res[id]</Id>
		<Title>$res[title]</Title>
		<Unique>$up</Unique>
		<MirrorUniverseUnique>$um</MirrorUniverseUnique>
		<Type>Resource</Type>
		<Cost>$res[cost]</Cost>
		<Ability>$res[ability]</Ability>
		<Set>$sets</Set>
	</Resource>

EOT;
}
	print "\t</Resources>\n";
}

if ( $print == "all" || $print == "sets" ) {
	print "\t<Sets>\n";

$r = $db->query("SELECT * FROM Sets");
//CREATE TABLE Sets (id text, set_group text, release text, name text, primary key(id asc))");

while ($set = $r->fetchArray()) {
	print <<<EOT
	<Set id="$set[id]"	overallSetName="$set[set_group]"	releaseDate="$set[release]">$set[name]</Set>

EOT;
}
	print "\t</Sets>\n";
}
//CREATE TABLE IF NOT EXISTS Flagships (id text,title text,faction integer not null,attack integer not null,agility integer not null,hull integer not null,shield integer not null,evasive integer not null,targetlock integer not null,scan integer not null,battlestations integer not null,cloak integer not null,sensorecho integer not null,talent integer not null,crew integer not null,tech integer not null,weapon integer not null,ability blob,primary key(id asc))");
if ( $print == "all" || $print == "flagships" ) {
	print "\t<Flagships>\n";
$r = $db->query("SELECT * FROM Flagships");

while ($res = $r->fetchArray()) {
	$faction = $db->factionforid($res["faction"]);
	$sets = $db->setsforid($res["id"]);
	print <<<EOT
	<Flagship>
		<Id>$res[id]</Id>
		<Title>$res[title]</Title>
		<Faction>$faction</Faction>
		<Attack>$res[attack]</Attack>
		<Agility>$res[agility]</Agility>
		<Hull>$res[hull]</Hull>
		<Shield>$res[shield]</Shield>
		<EvasiveManeuvers>$res[evasive]</EvasiveManeuvers>
		<TargetLock>$res[targetlock]</TargetLock>
		<Scan>$res[scan]</Scan>
		<Battlestations>$res[battlestations]</Battlestations>
		<Cloak>$res[cloak]</Cloak>
		<SensorEcho>$res[sensorecho]</SensorEcho>
		<Talent>$res[talent]</Talent>
		<Crew>$res[crew]</Crew>
		<Tech>$res[tech]</Tech>
		<Weapon>$res[weapon]</Weapon>
		<Ability>$res[ability]</Ability>
		<Set>$sets</Set>
	</Flagship>

EOT;
}
	print "\t</Flagships>\n";
}
//CREATE TABLE IF NOT EXISTS FleetCaptains (id text,title text,faction integer not null,skillbonus not null,talent integer not null,crew integer not null,tech integer not null,weapon integer not null,cost integer,ability blob,primary key(id asc))");
if ( $print == "all" || $print == "fleetcaptains" ) {
	print "\t<FleetCaptains>\n";
$r = $db->query("SELECT * FROM FleetCaptains");

while ($res = $r->fetchArray()) {
	$faction = $db->factionforid($res["faction"]);
	$sets = $db->setsforid($res["id"]);
	print <<<EOT
	<FleetCaptain>
		<Id>$res[id]</Id>
		<Title>$res[title]</Title>
		<Faction>$faction</Faction>
		<Type>Fleet Captain</Type>
		<CaptainSkillBonus>$res[skillbonus]</CaptainSkillBonus>
		<TalentAdd>$res[talent]</TalentAdd>
		<CrewAdd>$res[crew]</CrewAdd>
		<TechAdd>$res[tech]</TechAdd>
		<WeaponAdd>$res[weapon]</WeaponAdd>
		<Cost>$res[cost]</Cost>
		<Ability>$res[ability]</Ability>
		<Set>$sets</Set>
	</FleetCaptain>

EOT;
}
	print "\t</FleetCaptains>\n";
}
//CREATE TABLE IF NOT EXISTS Officers (id text,title text,uniq integer not null,faction integer not null,cost integer not null,special text, ability blob,primary key(id asc))");
if ( $print == "all" || $print == "officers" ) {
	print "\t<Officers>\n";
$r = $db->query("SELECT * FROM Officers");

while ($res = $r->fetchArray()) {
	$up = "N";
	$um = "N";
	$uniq = $res["uniq"];
	$faction = $db->factionforid($res["faction"]);
	$sets = $db->setsforid($res["id"]);
	if ($uniq == 1) {
		$up = "Y";
	} elseif ($uniq == -1) {
		$um = "Y";
	}
	print <<<EOT
	<Officer>
		<Id>$res[id]</Id>
		<Title>$res[title]</Title>
		<Faction>$faction</Faction>
		<Unique>$up</Unique>
		<Type>Officer</Type>
		<Cost>$res[cost]</Cost>
		<Ability>$res[ability]</Ability>
		<Special>$res[special]</Special>
		<Set>$sets</Set>
	</Officer>

EOT;
}
	print "\t</Officers>\n";
}
//CREATE TABLE IF NOT EXISTS ReferenceItems (id text,title text,type text,ability blob,primary key(id asc))");
if ( $print == "all" || $print == "reference" ) {
	print "\t<ReferenceItems>\n";
$r = $db->query("SELECT * FROM ReferenceItems");

while ($res = $r->fetchArray()) {
	$sets = $db->setsforid($res["id"]);
	print <<<EOT
	<Reference>
		<Id>$res[id]</Id>
		<Title>$res[title]</Title>
		<Type>$res[type]</Type>
		<Ability>$res[ability]</Ability>
		<Set>$sets</Set>
	</Reference>

EOT;
}
	print "\t</ReferenceItems>\n";
}
if ( $print == "all" ) {
	print "</Data>";
}
?>
