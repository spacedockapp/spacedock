#!/usr/bin/perl -w


use Data::Dumper;
use strict;
use DBI;
use XML::Simple;
use bigint;
use Time::Piece;
use File::Basename;
use File::Spec::Functions qw(rel2abs);

my $xmlfile;
my $dbfile;

if ( $#ARGV == 1 ) {
	$xmlfile = $ARGV[0];
	$dbfile = $ARGV[1];
} else {
	chdir dirname(rel2abs($0));
	$xmlfile = "../src/Data.xml";
	$dbfile = "../src/data.db";
}

my $dbh = DBI->connect("dbi:SQLite:dbname=".$dbfile,"","");
my $data = XMLin($xmlfile,SuppressEmpty => '');
my $t = Time::Piece->strptime($data->{'version'},"%Y-%m-%d\@%H-%M");
print "Version: ".$data->{'version'}."\n";
print "(".$t->datetime.")\n";

factions();
sets();

my $sth_faction = $dbh->prepare_cached("SELECT faction FROM Factions WHERE _id = ?");
my $sth_factionid = $dbh->prepare_cached("SELECT _id FROM Factions WHERE faction = ? LIMIT 1");

admirals();
captains();
upgrades();
ship_classes();
ships();
flagships();
fleet_captains();
officers();
resources();
reference();

utime($t->epoch,$t->epoch,$dbfile);

sub factions {
	my $sth = $dbh->prepare("SELECT COUNT(*) AS rows FROM sqlite_master WHERE type = 'table' AND name = 'Factions' LIMIT 1");
	$sth->execute;
	my ($rows,undef) = $sth->fetchrow_array;
	if ( $rows < 1 ) {
	    my $sth = $dbh->prepare("CREATE TABLE Factions (_id integer,faction text,primary key(_id asc))");
	    $sth->execute;
	}
	$sth = $dbh->prepare("SELECT COUNT(*) as rows FROM Factions");
	$sth->execute;
	($rows,undef) = $sth->fetchrow_array;

	$sth = $dbh->prepare("INSERT INTO Factions (faction) VALUES(?)");

	$sth->execute("Federation") if ($rows < 1);
	$sth->execute("Klingon") if ($rows < 2);
	$sth->execute("Romulan") if ($rows < 3);
	$sth->execute("Dominion") if ($rows < 4);
	$sth->execute("Borg") if ($rows < 5);
	$sth->execute("Species 8472") if ($rows < 6);
	$sth->execute("Kazon") if ($rows < 7);
	$sth->execute("Bajoran") if ($rows < 8);
	$sth->execute("Ferengi") if ($rows < 9);
	$sth->execute("Vulcan") if ($rows < 10);
	$sth->execute("Independent") if ($rows < 11);
	$sth->execute("Mirror Universe") if ($rows < 12);
	$sth->execute("Q Continuum") if ($rows < 13);
        $sth->execute("Xindi") if ($rows < 14);
}

sub sets {
	my $sets = $data->{"Sets"};
	my $sth = $dbh->prepare("SELECT COUNT(*) AS rows FROM sqlite_master WHERE type = 'table' AND name = 'Sets' LIMIT 1");
	$sth->execute;
	my ($rows,undef) = $sth->fetchrow_array;
	if ( $rows < 1 ) {
		$sth = $dbh->prepare("CREATE TABLE Sets (id text, set_group text, release text, name text, primary key(id asc))");
		$sth->execute;
	}
	$sth = $dbh->prepare("SELECT COUNT(*) AS rows FROM sqlite_master WHERE type = 'table' AND name = 'Sets_Map' LIMIT 1");
	$sth->execute;
	($rows,undef) = $sth->fetchrow_array;
	if ( $rows < 1 ) {
		$sth = $dbh->prepare("CREATE TABLE Sets_Map (_id integer,id text, set_id text,primary key(_id asc))");
		$sth->execute;
	}

	$sth = $dbh->prepare("INSERT OR REPLACE INTO Sets VALUES(?,?,?,?)");
	foreach my $s (keys %{$sets->{"Set"}}) {
		my $set = $sets->{"Set"}{$s};
		#print "Found set: $set->{'content'}\n";
		$sth->execute($s,$set->{'overallSetName'},$set->{'releaseDate'},$set->{'content'});
	}
}

##Admirals
sub admirals {
	my $admirals = $data->{'Admirals'};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Admirals (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null, skill integer not null,talent integer not null,skillmodifier integer not null,cost integer not null,special text,ability blob,admiral_ability blob,primary key(id asc))");
	$sth->execute;
	$sth = $dbh->prepare("INSERT OR REPLACE INTO Admirals VALUES( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? )");
	foreach my $a (@{$admirals->{"Admiral"}}) {
		#print "Admiral Found: ".$a->{"Title"}."\n";
        my $unique = 0;
        if ($a->{"Unique"} eq "Y") {
            $unique = 1;
        } elsif ($a->{"MirrorUniverseUnique"} eq "Y") {
            $unique = -1;
        }
        my $faction;
	my $faction2;
        $sth_factionid->execute($a->{"Faction"});
        my $rc = $sth_factionid->bind_columns(\$faction);
        $sth_factionid->fetch;

        if ( $sth_factionid->rows != 1 ) {
            $faction = 0;
            print STDERR "Could not find faction: ".$a->{"Faction"}."\n"
        }
	$sth_factionid->execute($a->{"AdditionalFaction"});
        $rc = $sth_factionid->bind_columns(\$faction2);
        $sth_factionid->fetch;

        if ( $sth_factionid->rows != 1 ) {
            $faction2 = 0;
        }

        $sth->execute(($a->{"Id"} or 0),($a->{"Title"} or 0),$unique,$faction,$faction2,($a->{"Skill"} or 0),($a->{"Talent"} or 0),($a->{"SkillModifier"} or 0),($a->{"Cost"} or 0),($a->{"Special"}),($a->{"Ability"}),($a->{"AdmiralAbility"}));

        my $sth_set_check = $dbh->prepare("SELECT COUNT(*) AS rows FROM Sets_Map WHERE id = ? AND set_id = ?");
        my $sth_set = $dbh->prepare("INSERT INTO Sets_Map (id,set_id) VALUES(?,?)");
        foreach my $setid (split(/,/,$a->{"Set"})) {
		$setid =~ s/^\s+|\s+$//g;
		$sth_set_check->execute($a->{"Id"},$setid);
		my ($rows,undef) = $sth_set_check->fetchrow_array;
		if ($rows < 1) {
			$sth_set->execute($a->{"Id"},$setid);
		}
        }
    }

	my $sth_dup = $dbh->prepare("SELECT id FROM Admirals where id not in (SELECT min(id) from Admirals GROUP BY title,uniq,faction,faction2,skill,talent,skillmodifier,cost,special,ability,admiral_ability)");
	$sth_dup->execute();
	my $dup_id;
	my $rc_dup = $sth_dup->bind_columns(\$dup_id);
	while ($sth_dup->fetch) {
		print STDERR "Duplicate Admiral found: $dup_id";
	}
}
##Captains
sub captains {
	my $captains = $data->{'Captains'};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Captains (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,skill integer not null,talent integer not null,cost integer not null,special text,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("INSERT OR REPLACE INTO Captains VALUES( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? )");
	foreach my $c (@{$captains->{"Captain"}}) {
		#print "Captain Found: ".$c->{"Title"}."\n";
        my $unique = 0;
        if (defined $c->{"Unique"} && $c->{"Unique"} eq "Y") {
            $unique = 1;
        } elsif (defined $c->{"MirrorUniverseUnique"} && $c->{"MirrorUniverseUnique"} eq "Y") {
            $unique = -1;
        }

        my $faction;
	my $faction2;
        $sth_factionid->execute($c->{"Faction"});
        my $rc = $sth_factionid->bind_columns(\$faction);
        $sth_factionid->fetch;

        if ( $sth_factionid->rows != 1 ) {
            $faction = 0;
            print STDERR "Could not find faction: ".$c->{"Faction"}."\n"
        }
	$sth_factionid->execute($c->{"AdditionalFaction"});
        $rc = $sth_factionid->bind_columns(\$faction2);
        $sth_factionid->fetch;

        if ( $sth_factionid->rows != 1 ) {
            $faction2 = 0;
        }
 
       $sth->execute(($c->{"Id"} or 0),($c->{"Title"} or 0),$unique,$faction,$faction2,($c->{"Skill"} or 0),($c->{"Talent"} or 0),($c->{"Cost"} or 0),($c->{"Special"}),($c->{"Ability"}));

        my $sth_set_check = $dbh->prepare("SELECT COUNT(*) AS rows FROM Sets_Map WHERE id = ? AND set_id = ?");
        my $sth_set = $dbh->prepare("INSERT INTO Sets_Map (id,set_id) VALUES(?,?)");
        foreach my $setid (split(/,/,$c->{"Set"})) {
		$setid =~ s/^\s+|\s+$//g;
		$sth_set_check->execute($c->{"Id"},$setid);
		my ($rows,undef) = $sth_set_check->fetchrow_array;
		if ($rows < 1) {
			$sth_set->execute($c->{"Id"},$setid);
		}
        }
    }

	my $sth_dup = $dbh->prepare("SELECT id FROM Captains where id not in (SELECT min(id) from Captains GROUP BY title,uniq,faction,faction2,skill,talent,cost,special,ability)");
	$sth_dup->execute();
	my $dup_id;
	my $rc_dup = $sth_dup->bind_columns(\$dup_id);
	while ($sth_dup->fetch) {
		if ( $dup_id eq "calvin_hudson_b_71528" ||  $dup_id eq "calvin_hudson_c_71528" || $dup_id eq "chakotay_b_71528" || $dup_id eq "jean_luc_picard_c_71531" ) {
			next;
		}
		print STDERR "Duplicate Captain found: $dup_id\n";
	}
}
##Upgrades
sub upgrades {
	my $upgrades = $data->{'Upgrades'};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Talent (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,cost integer not null,special text,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Crew (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,cost integer not null,special text,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Tech (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,cost integer not null,special text,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Borg (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,cost integer not null,special text,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Squadron (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,cost integer not null,special text,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS ResourceUpgrade (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,cost integer not null,special text,ability blob,primary key(id asc))");
	$sth->execute;
	$sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Weapon (id text,title text,uniq integer not null,faction integer not null,faction2 integer not null,cost integer not null,attack integer not null,range text,special text,ability blob,primary key(id asc))");
	$sth->execute;
	my $sthe = $dbh->prepare("INSERT OR REPLACE INTO Talent VALUES(?,?,?,?,?,?,?,?)");
	my $sthc = $dbh->prepare("INSERT OR REPLACE INTO Crew VALUES(?,?,?,?,?,?,?,?)");
	my $stht = $dbh->prepare("INSERT OR REPLACE INTO Tech VALUES(?,?,?,?,?,?,?,?)");
	my $sthb = $dbh->prepare("INSERT OR REPLACE INTO Borg VALUES(?,?,?,?,?,?,?,?)");
	my $sths = $dbh->prepare("INSERT OR REPLACE INTO Squadron VALUES(?,?,?,?,?,?,?,?)");
	my $sthru = $dbh->prepare("INSERT OR REPLACE INTO ResourceUpgrade VALUES(?,?,?,?,?,?,?,?)");
	my $sthw = $dbh->prepare("INSERT OR REPLACE INTO Weapon VALUES(?,?,?,?,?,?,?,?,?,?)");
	foreach my $u (@{$upgrades->{"Upgrade"}}) {
		#print "Upgrade Found: ".$u->{"Title"}."(".$u->{"Type"}.")\n";
	        my $unique = 0;
	        if (defined $u->{"Unique"} && $u->{"Unique"} eq "Y") {
	            $unique = 1;
	        } elsif (defined $u->{"MirrorUniverseUnique"} && $u->{"MirrorUniverseUnique"} eq "Y") {
	            $unique = -1;
	        }

	        my $faction;
            my $faction2;
	        $sth_factionid->execute($u->{"Faction"});
	        my $rc = $sth_factionid->bind_columns(\$faction);
	        $sth_factionid->fetch;

	        if ( $sth_factionid->rows != 1 ) {
                $faction = 0;
                print STDERR "Could not find faction: ".$u->{"Faction"}."\n"
        	}
            $sth_factionid->execute($u->{"AdditionalFaction"});
        	$rc = $sth_factionid->bind_columns(\$faction2);
        	$sth_factionid->fetch;

        	if ( $sth_factionid->rows != 1 ) {
            		$faction2 = 0;
        	}

			if ($u->{"Type"} eq "Weapon") {
$sthw->execute(($u->{"Id"} or 0),($u->{"Title"} or 0),$unique,$faction,$faction2,($u->{"Cost"} or 0),($u->{"Attack"} or 0),($u->{"Range"} or 0),($u->{"Special"}),($u->{"Ability"}));
            } elsif ($u->{"Type"} eq "Talent") {
$sthe->execute(($u->{"Id"} or 0),($u->{"Title"} or 0),$unique,$faction,$faction2,($u->{"Cost"} or 0),($u->{"Special"}),($u->{"Ability"}));
            } elsif ($u->{"Type"} eq "Crew") {
$sthc->execute(($u->{"Id"} or 0),($u->{"Title"} or 0),$unique,$faction,$faction2,($u->{"Cost"} or 0),($u->{"Special"}),($u->{"Ability"}));
            } elsif ($u->{"Type"} eq "Tech") {
$stht->execute(($u->{"Id"} or 0),($u->{"Title"} or 0),$unique,$faction,$faction2,($u->{"Cost"} or 0),($u->{"Special"}),($u->{"Ability"}));
            } elsif ($u->{"Type"} eq "Borg") {
$sthb->execute(($u->{"Id"} or 0),($u->{"Title"} or 0),$unique,$faction,$faction2,($u->{"Cost"} or 0),($u->{"Special"}),($u->{"Ability"}));
            } elsif ($u->{"Type"} eq "Squadron") {
$sths->execute(($u->{"Id"} or 0),($u->{"Title"} or 0),$unique,$faction,$faction2,($u->{"Cost"} or 0),($u->{"Special"}),($u->{"Ability"}));
            } elsif ($u->{"Type"} eq "Resource") {
$sthru->execute(($u->{"Id"} or 0),($u->{"Title"} or 0),$unique,$faction,$faction2,($u->{"Cost"} or 0),($u->{"Special"}),($u->{"Ability"}));

            } else {
                print STDERR "Unknown upgrade type: ".$u->{"Type"}."\n";
		print STDERR "\t".$u->{"Id"}.": ".$u->{"Title"}."\n";
            }

	        my $sth_set_check = $dbh->prepare("SELECT COUNT(*) AS rows FROM Sets_Map WHERE id = ? AND set_id = ?");
	        my $sth_set = $dbh->prepare("INSERT INTO Sets_Map (id,set_id) VALUES(?,?)");
	        foreach my $setid (split(/,/,$u->{"Set"})) {
			$setid =~ s/^\s+|\s+$//g;
                	$sth_set_check->execute($u->{"Id"},$setid);
                	my ($rows,undef) = $sth_set_check->fetchrow_array;
                	if ($rows < 1) {
                	    	$sth_set->execute($u->{"Id"},$setid);
                	}
		}
	}
	foreach my $upgtype ("Talent","Tech","Crew","Borg","Squadron","ResourceUpgrade") {
		my $sth_dup = $dbh->prepare("SELECT id FROM $upgtype where id not in (SELECT min(id) from $upgtype GROUP BY title,uniq,faction,faction2,cost,special,ability)");
		$sth_dup->execute();
		my $dup_id;
		my $rc_dup = $sth_dup->bind_columns(\$dup_id);
		while ($sth_dup->fetch) {
			print STDERR "Duplicate Upgrade ($upgtype) found: $dup_id\n";
		}
	}
	my $sth_dup = $dbh->prepare("SELECT id FROM Weapon where id not in (SELECT min(id) from Weapon GROUP BY title,uniq,faction,faction2,cost,attack,range,special,ability)");
	$sth_dup->execute();
	my $dup_id;
	my $rc_dup = $sth_dup->bind_columns(\$dup_id);
	while ($sth_dup->fetch) {
		print STDERR "Duplicate Upgrade (Weapon) found: $dup_id\n";
	}
}
##ShipClassDetails
sub ship_classes {
	my $ship_classes = $data->{"ShipClassDetails"};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS ShipClasses (id text,name text,frontarc integer,reararc integer,redmoves text,whitemoves text,greenmoves text,primary key (id asc))");
	$sth->execute;
	$sth = $dbh->prepare("INSERT OR REPLACE INTO ShipClasses VALUES( ?, ?, ?, ?, ?, ?, ? )");

	foreach my $s (@{$ship_classes->{"ShipClassDetail"}}) {
		my $redmoves;
		my $whitemoves;
		my $greenmoves;


		#print "Found ship class: ".$s->{"Name"}."\n";
		if ( $s->{"Maneuvers"} ne "" ) {
		foreach my $m (@{$s->{"Maneuvers"}->{"Maneuver"}}) {
####### 1  b  t  a  s  2  b  t  a  s  3  b  t  a  s  4  b  a  s  5  a  s  6  a  s  -1  -2  -3
####### 1  2  3  4  5  6  7  8  9 10 11	12 13 14 15 16 17 18 19 20 21 22 23 24 25  26  27  28
			my $moves;
			if ( $m->{"speed"} == 1 && $m->{"kind"} eq "straight" ) {
				$moves = "1F";
			} elsif ( $m->{"speed"} == 1 && $m->{"kind"} eq "right-bank" ) {
				$moves = "1B";
			} elsif ( $m->{"speed"} == 1 && $m->{"kind"} eq "right-turn" ) {
				$moves = "1T";
			} elsif ( $m->{"speed"} == 1 && $m->{"kind"} eq "about" ) {
				$moves = "1A";
			} elsif ( $m->{"speed"} == 1 && $m->{"kind"} eq "right-spin" ) {
				$moves = "1S";
			} elsif ( $m->{"speed"} == 1 && $m->{"kind"} eq "right-flank" ) {
				$moves = "1K";
			} elsif ( $m->{"speed"} == 2 && $m->{"kind"} eq "straight" ) {
				$moves = "2F";
			} elsif ( $m->{"speed"} == 2 && $m->{"kind"} eq "right-bank" ) {
				$moves = "2B";
			} elsif ( $m->{"speed"} == 2 && $m->{"kind"} eq "right-turn" ) {
				$moves = "2T";
			} elsif ( $m->{"speed"} == 2 && $m->{"kind"} eq "about" ) {
				$moves = "2A";
			} elsif ( $m->{"speed"} == 2 && $m->{"kind"} eq "right-spin" ) {
				$moves = "2S";
			} elsif ( $m->{"speed"} == 2 && $m->{"kind"} eq "right-flank" ) {
				$moves = "2K";
			} elsif ( $m->{"speed"} == 3 && $m->{"kind"} eq "straight" ) {
				$moves = "3F";
			} elsif ( $m->{"speed"} == 3 && $m->{"kind"} eq "right-bank" ) {
				$moves = "3B";
			} elsif ( $m->{"speed"} == 3 && $m->{"kind"} eq "right-turn" ) {
				$moves = "3T";
			} elsif ( $m->{"speed"} == 3 && $m->{"kind"} eq "about" ) {
				$moves = "3A";
			} elsif ( $m->{"speed"} == 3 && $m->{"kind"} eq "right-spin" ) {
				$moves = "3S";
			} elsif ( $m->{"speed"} == 4 && $m->{"kind"} eq "straight" ) {
				$moves = "4F";
			} elsif ( $m->{"speed"} == 4 && $m->{"kind"} eq "right-bank" ) {
				$moves = "4B";
			} elsif ( $m->{"speed"} == 4 && $m->{"kind"} eq "about" ) {
				$moves = "4A";
			} elsif ( $m->{"speed"} == 4 && $m->{"kind"} eq "right-spin" ) {
				$moves = "4S";
			} elsif ( $m->{"speed"} == 5 && $m->{"kind"} eq "straight" ) {
				$moves = "5F";
			} elsif ( $m->{"speed"} == 5 && $m->{"kind"} eq "about" ) {
				$moves = "5A";
			} elsif ( $m->{"speed"} == 5 && $m->{"kind"} eq "right-spin" ) {
				$moves = "5S";
			} elsif ( $m->{"speed"} == 6 && $m->{"kind"} eq "straight" ) {
				$moves = "6F";
			} elsif ( $m->{"speed"} == 6 && $m->{"kind"} eq "about" ) {
				$moves = "6A";
			} elsif ( $m->{"speed"} == 6 && $m->{"kind"} eq "right-spin" ) {
				$moves = "6S";
			} elsif ( $m->{"speed"} == -1 && $m->{"kind"} eq "straight" ) {
				$moves = "1R";
			} elsif ( $m->{"speed"} == -2 && $m->{"kind"} eq "straight" ) {
				$moves = "2R";
			} elsif ( $m->{"speed"} == -3 && $m->{"kind"} eq "straight" ) {
				$moves = "3R";
			} elsif ( $m->{"speed"} == 0 && $m->{"kind"} eq "stop" ) {
				$moves = "00";
			} elsif ( $m->{"speed"} == 0 && $m->{"kind"} eq "right-45-degree-rotate" ) {
				$moves = "04";
			} elsif ( $m->{"speed"} == 0 && $m->{"kind"} eq "right-90-degree-rotate" ) {
				$moves = "09";
			} elsif ( $m->{"kind"} eq "left-turn" || $m->{"kind"} eq "left-bank" || $m->{"kind"} eq "left-spin" || $m->{"kind"} eq "left-flank" || $m->{"kind"} eq "left-45-degree-rotate" || $m->{"kind"} eq "left-90-degree-rotate" ) {
				$moves = "";
			} else {
				$moves .= "";
				print STDERR "Unknown maneuver: ".$m->{"speed"}." ".$m->{"kind"}."\n";
			}
			if ( $m->{"color"} eq "red" ) {
				$redmoves .= $moves;
			} elsif ( $m->{"color"} eq "white" ) {
				$whitemoves .= $moves;
			} elsif ( $m->{"color"} eq "green" ) {
				$greenmoves .= $moves;
			}
		}
		}
		$sth->execute($s->{"Id"},$s->{"Name"},$s->{"FrontArc"},$s->{"RearArc"},$redmoves,$whitemoves,$greenmoves);
	}
	my $sth_dup = $dbh->prepare("SELECT id FROM ShipClasses where id not in (SELECT min(id) from ShipClasses GROUP BY name,frontarc,reararc,redmoves,whitemoves,greenmoves)");
	$sth_dup->execute();
	my $dup_id;
	my $rc_dup = $sth_dup->bind_columns(\$dup_id);
	while ($sth_dup->fetch) {
		print STDERR "Duplicate Ship Class found: $dup_id\n";
	}
}
##Ships
sub ships {
	my $ships = $data->{'Ships'};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Ships (id text,title text,class text,classid text,uniq integer not null,faction integer not null,faction2 integer not null,attack integer not null,agility integer not null,hull integer not null,shield integer not null,cost integer not null,evasive integer not null,targetlock integer not null,scan integer not null,battlestations integer not null,cloak integer not null,sensorecho integer not null,regenerate integer not null,crew integer not null,tech integer not null,weapon integer not null,borg integer not null,squad integer not null,has360 integer not null,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("INSERT OR REPLACE INTO Ships VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
	foreach my $s (@{$ships->{"Ship"}}) {
		#print "Ship Found: ".$s->{"Title"}."\n";
        my $unique = 0;
        if ($s->{"Unique"} eq "Y") {
            $unique = 1;
        } elsif (defined $s->{"MirrorUniverseUnique"} && $s->{"MirrorUniverseUnique"} eq "Y") {
            $unique = -1;
        }

        my $faction;
	my $faction2;
        $sth_factionid->execute($s->{"Faction"});
        my $rc = $sth_factionid->bind_columns(\$faction);
        $sth_factionid->fetch;

        if ( $sth_factionid->rows != 1 ) {
            $faction = 0;
            print STDERR "Could not find faction: ".$s->{"Faction"}."\n"
        }
	$sth_factionid->execute($s->{"AdditionalFaction"});
        $rc = $sth_factionid->bind_columns(\$faction2);
        $sth_factionid->fetch;

        if ( $sth_factionid->rows != 1 ) {
            $faction2 = 0;
        }

	my $has360 = 0;
	if (defined $s->{"Has360Arc"} && $s->{"Has360Arc"} eq "Y") {
		$has360 = 1;
	}
	my $classid = "";
	if ($s->{"ShipClassDetailsId"}) {
		$classid = $s->{"ShipClassDetailsId"};
	} else {
		my $sth_class = $dbh->prepare("SELECT id FROM ShipClasses WHERE name = ? LIMIT 1");
		$sth_class->execute($s->{"ShipClass"});
		$rc = $sth_class->bind_columns(\$classid);
		$sth_class->fetch;
	}
       $sth->execute(($s->{"Id"} or 0),($s->{"Title"} or 0),($s->{"ShipClass"} or 0),$classid,$unique,$faction,$faction2,($s->{"Attack"} or 0),($s->{"Agility"} or 0),($s->{"Hull"} or 0),($s->{"Shield"} or 0),($s->{"Cost"} or 0),($s->{"EvasiveManeuvers"} or 0),($s->{"TargetLock"} or 0),($s->{"Scan"} or 0),($s->{"Battlestations"} or 0),($s->{"Cloak"} or 0),($s->{"SensorEcho"} or 0),($s->{"Regenerate"} or 0),($s->{"Crew"} or 0),($s->{"Tech"} or 0),($s->{"Weapon"} or 0),($s->{"Borg"} or 0),($s->{"SquadronUpgrade"} or 0),$has360,($s->{"Ability"}));

        my $sth_set_check = $dbh->prepare("SELECT COUNT(*) AS rows FROM Sets_Map WHERE id = ? AND set_id = ?");
        my $sth_set = $dbh->prepare("INSERT INTO Sets_Map (id,set_id) VALUES(?,?)");
        foreach my $setid (split(/,/,$s->{"Set"})) {
		$setid =~ s/^\s+|\s+$//g;
		$sth_set_check->execute($s->{"Id"},$setid);
		my ($rows,undef) = $sth_set_check->fetchrow_array;
		if ($rows < 1) {
			$sth_set->execute($s->{"Id"},$setid);
		}
        }
    }
	my $sth_dup = $dbh->prepare("SELECT id FROM Ships where id not in (SELECT min(id) from Ships GROUP BY title,class,classid,uniq,faction,faction2,attack,agility,hull,shield,cost,evasive,targetlock,scan,battlestations,cloak,sensorecho,regenerate,crew,tech,weapon,borg,squad,has360,ability)");
	$sth_dup->execute();
	my $dup_id;
	my $rc_dup = $sth_dup->bind_columns(\$dup_id);
	while ($sth_dup->fetch) {
		print STDERR "Duplicate Ship found: $dup_id\n";
	}
}
##Flagships
sub flagships {
	my $flagships = $data->{'Flagships'};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Flagships (id text,title text,faction integer not null,attack integer not null,agility integer not null,hull integer not null,shield integer not null,evasive integer not null,targetlock integer not null,scan integer not null,battlestations integer not null,cloak integer not null,sensorecho integer not null,talent integer not null,crew integer not null,tech integer not null,weapon integer not null,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("INSERT OR REPLACE INTO Flagships VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
	foreach my $f (@{$flagships->{"Flagship"}}) {
		#print "Flagship Found: ".$f->{"Title"}."\n";

        my $faction;
        $sth_factionid->execute($f->{"Faction"});
        my $rc = $sth_factionid->bind_columns(\$faction);
        $sth_factionid->fetch;

        if ( $sth_factionid->rows != 1 ) {
            $faction = 0;
            print STDERR "Could not find faction: ".$f->{"Faction"}."\n"
        }

       $sth->execute(($f->{"Id"} or 0),($f->{"Title"} or 0),$faction,($f->{"Attack"} or 0),($f->{"Agility"} or 0),($f->{"Hull"} or 0),($f->{"Shield"} or 0),($f->{"EvasiveManeuvers"} or 0),($f->{"TargetLock"} or 0),($f->{"Scan"} or 0),($f->{"Battlestations"} or 0),($f->{"Cloak"} or 0),($f->{"SensorEcho"} or 0),($f->{"Talent"} or 0),($f->{"Crew"} or 0),($f->{"Tech"} or 0),($f->{"Weapon"} or 0),($f->{"Ability"}));

        my $sth_set_check = $dbh->prepare("SELECT COUNT(*) AS rows FROM Sets_Map WHERE id = ? AND set_id = ?");
        my $sth_set = $dbh->prepare("INSERT INTO Sets_Map (id,set_id) VALUES(?,?)");
        foreach my $setid (split(/,/,$f->{"Set"})) {
		$setid =~ s/^\s+|\s+$//g;
		$sth_set_check->execute($f->{"Id"},$setid);
		my ($rows,undef) = $sth_set_check->fetchrow_array;
		if ($rows < 1) {
			$sth_set->execute($f->{"Id"},$setid);
		}
        }
    }
}
##FleetCaptains
sub fleet_captains {
	my $fleetcaptains = $data->{'FleetCaptains'};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS FleetCaptains (id text,title text,faction integer not null,skillbonus not null,talent integer not null,crew integer not null,tech integer not null,weapon integer not null,cost integer,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("INSERT OR REPLACE INTO FleetCaptains VALUES(?,?,?,?,?,?,?,?,?,?)");
	foreach my $f (@{$fleetcaptains->{"FleetCaptain"}}) {
		#print "Fleet Captain Found: ".$f->{"Title"}."\n";

        my $faction;
        $sth_factionid->execute($f->{"Faction"});
        my $rc = $sth_factionid->bind_columns(\$faction);
        $sth_factionid->fetch;

        if ( $sth_factionid->rows != 1 ) {
            $faction = 0;
            print STDERR "Could not find faction: ".$f->{"Faction"}."\n"
        }

       $sth->execute(($f->{"Id"} or 0),($f->{"Title"} or 0),$faction,($f->{"CaptainSkillBonus"} or 0),($f->{"TalentAdd"} or 0),($f->{"CrewAdd"} or 0),($f->{"TechAdd"} or 0),($f->{"WeaponAdd"} or 0),($f->{"Cost"} or 0),($f->{"Ability"}));

        my $sth_set_check = $dbh->prepare("SELECT COUNT(*) AS rows FROM Sets_Map WHERE id = ? AND set_id = ?");
        my $sth_set = $dbh->prepare("INSERT INTO Sets_Map (id,set_id) VALUES(?,?)");
        foreach my $setid (split(/,/,$f->{"Set"})) {
		$setid =~ s/^\s+|\s+$//g;
		$sth_set_check->execute($f->{"Id"},$setid);
		my ($rows,undef) = $sth_set_check->fetchrow_array;
		if ($rows < 1) {
			$sth_set->execute($f->{"Id"},$setid);
		}
        }
    }
}
##Officers
sub officers {
	my $officers = $data->{'Officers'};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Officers (id text,title text,uniq integer not null,faction integer not null,cost integer not null,special text, ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("INSERT OR REPLACE INTO Officers VALUES(?,?,?,?,?,?,?)");
	foreach my $o (@{$officers->{"Officer"}}) {
		#print "Officer Found: ".$o->{"Title"}."\n";

        my $unique = 0;
        if ($o->{"Unique"} eq "Y") {
            $unique = 1;
        } elsif ($o->{"MirrorUniverseUnique"} eq "Y") {
            $unique = -1;
        }

        my $faction;
        $sth_factionid->execute($o->{"Faction"});
        my $rc = $sth_factionid->bind_columns(\$faction);
        $sth_factionid->fetch;

        if ( $sth_factionid->rows != 1 ) {
            $faction = 0;
            print STDERR "Could not find faction: ".$o->{"Faction"}."\n"
        }

       $sth->execute(($o->{"Id"} or 0),($o->{"Title"} or 0),$unique,$faction,($o->{"Cost"} or 0),($o->{"Special"}),($o->{"Ability"}));

        my $sth_set_check = $dbh->prepare("SELECT COUNT(*) AS rows FROM Sets_Map WHERE id = ? AND set_id = ?");
        my $sth_set = $dbh->prepare("INSERT INTO Sets_Map (id,set_id) VALUES(?,?)");
        foreach my $setid (split(/,/,$o->{"Set"})) {
		$setid =~ s/^\s+|\s+$//g;
		$sth_set_check->execute($o->{"Id"},$setid);
		my ($rows,undef) = $sth_set_check->fetchrow_array;
		if ($rows < 1) {
			$sth_set->execute($o->{"Id"},$setid);
		}
        }
    }

}
##Resources
sub resources {
	my $resources = $data->{'Resources'};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS Resources (id text,title text,uniq integer not null,cost integer not null,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("INSERT OR REPLACE INTO Resources VALUES(?,?,?,?,?)");
	foreach my $r (@{$resources->{"Resource"}}) {
		#print "Resource Found: ".$r->{"Title"}."\n";

        my $unique = 0;
        if ($r->{"Unique"} eq "Y") {
            $unique = 1;
        } elsif ($r->{"MirrorUniverseUnique"} eq "Y") {
            $unique = -1;
        }

       $sth->execute(($r->{"Id"} or 0),($r->{"Title"} or 0),$unique,($r->{"Cost"} or 0),($r->{"Ability"}));

        my $sth_set_check = $dbh->prepare("SELECT COUNT(*) AS rows FROM Sets_Map WHERE id = ? AND set_id = ?");
        my $sth_set = $dbh->prepare("INSERT INTO Sets_Map (id,set_id) VALUES(?,?)");
        foreach my $setid (split(/,/,$r->{"Set"})) {
		$setid =~ s/^\s+|\s+$//g;
		$sth_set_check->execute($r->{"Id"},$setid);
		my ($rows,undef) = $sth_set_check->fetchrow_array;
		if ($rows < 1) {
			$sth_set->execute($r->{"Id"},$setid);
		}
        }
    }


}
##ReferenceItems
sub reference {
	my $references = $data->{'ReferenceItems'};
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS ReferenceItems (id text,title text,type text,ability blob,primary key(id asc))");
        $sth->execute;
	$sth = $dbh->prepare("INSERT OR REPLACE INTO ReferenceItems VALUES(?,?,?,?)");
	foreach my $r (@{$references->{"Reference"}}) {
		#print "Reference Found: ".$r->{"Title"}."\n";

       $sth->execute(($r->{"Id"} or 0),($r->{"Title"} or 0),($r->{"Type"} or 0),($r->{"Ability"}));

        my $sth_set_check = $dbh->prepare("SELECT COUNT(*) AS rows FROM Sets_Map WHERE id = ? AND set_id = ?");
        my $sth_set = $dbh->prepare("INSERT INTO Sets_Map (id,set_id) VALUES(?,?)");
        foreach my $setid (split(/,/,$r->{"Set"})) {
		$setid =~ s/^\s+|\s+$//g;
		$sth_set_check->execute($r->{"Id"},$setid);
		my ($rows,undef) = $sth_set_check->fetchrow_array;
		if ($rows < 1) {
			$sth_set->execute($r->{"Id"},$setid);
		}
        }
    }


}
##version


$sth_factionid->finish;
$sth_faction->finish;
$dbh->disconnect;
