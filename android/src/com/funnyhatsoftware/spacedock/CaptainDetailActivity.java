
package com.funnyhatsoftware.spacedock;

import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.Universe;

public class CaptainDetailActivity extends DetailActivity {

    protected String setupValues(Universe universe, String captainId) {
        Captain captain = universe.getCaptain(captainId);

        mValues.add(new Pair("Name", captain.getTitle()));
        mValues.add(new Pair("Faction", captain.getFaction()));
        mValues.add(new Pair("Type", captain.getUpType()));
        mValues.add(new Pair("Skill", captain.getSkill()));
        mValues.add(new Pair("Cost", captain.getCost()));
        mValues.add(new Pair("Unique", captain.getUnique()));
        mValues.add(new Pair("Talent", captain.getTalent()));
        mValues.add(new Pair("Set", captain.getSetName()));
        mValues.add(new Pair("Ability", captain.getAbility()));
        return captain.getTitle();
    }

}
