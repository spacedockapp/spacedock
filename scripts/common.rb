def convert_terms(upgrade)
  upgrade.gsub! /\[evade\]/i, "[EVADE]"
  upgrade.gsub! /\[cloak\]/i, "[CLOAK]"
  upgrade.gsub! /\[Sensor Echo\]/i, "[SENSOR ECHO]"
  upgrade.gsub! /\[scan\]/i, "[SCAN]"
  upgrade.gsub! /\[tech\]/i, "[TECH]"
  upgrade.gsub! /\[critical\]/i, "[CRITICAL]"
  upgrade.gsub! /\[Hit\]/i, "[HIT]"
  upgrade.gsub! /\[crew\]/i, "[CREW]"
  upgrade.gsub! /\[Battle *Stations*\]/i, "[BATTLESTATIONS]"
  upgrade.gsub! /\(Battle *Stations*\)/i, "[BATTLESTATIONS]"
  upgrade.gsub! /\(Target Lock\)/i, "[TARGET LOCK]"
  upgrade.gsub! /\(Critical Hit\)/i, "[CRITICAL]"
  upgrade.gsub! /\(talent\)/i, "[TALENT]"
  upgrade.gsub! /\(tech\)/i, "[TECH]"
  upgrade.gsub! /\(weapon\)/i, "[WEAPON]"
  upgrade.gsub! /\(scan\)/i, "[SCAN]"
  upgrade.gsub! /\(cloaked\)/i, "[CLOAK]"
  upgrade.gsub! /\(cloak\)/i, "[CLOAK]"
  upgrade.gsub! /\(crit\)/i, "[CRITICAL]"
  upgrade.gsub! /\(hit\)/i, "[HIT]"
  upgrade.gsub! /\(hits\)/i, "[HIT]"
  upgrade.gsub! /\(crew\)/i, "[CREW]"
  upgrade.gsub! /\(sensor echo\)/i, "[SENSOR ECHO]"
  upgrade.gsub! /[\[(]straight[)\]]/i, "[STRAIGHT]"
  upgrade
end

def no_quotes(a)
    a.gsub("\"", "")
end

def convert_line(a)
  no_quotes(a)
end

def sanitize_title(title)
  title.gsub(/\W+/, "_")
end

def make_external_id(setId, title)
  "#{sanitize_title(title)}_#{setId}".downcase()
end

def set_id_from_faction(faction)
  case faction
  when "Species 8472"
    "71281"
  when "Federation"
    "71280"
  when "Borg"
    "71283"
  when "Kazon"
    "71282"
  when "Independent"
    "OPWebPrize"
  end
end