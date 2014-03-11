
package com.funnyhatsoftware.spacedock;

import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;

public class UpgradeDetailActivity extends DetailActivity {
    
    protected String setupValues(Universe universe, String ugpradeId) {
        Upgrade crew = universe.getUpgrade(ugpradeId);

        mValues.add(new Pair("Name", crew.getTitle()));
        mValues.add(new Pair("Faction", crew.getFaction()));
        mValues.add(new Pair("Type", crew.getUpType()));
        mValues.add(new Pair("Cost", crew.getCost()));
        mValues.add(new Pair("Unique", crew.getUnique()));
        mValues.add(new Pair("Set", crew.getSetName()));
        mValues.add(new Pair("Ability", crew.getAbility()));
        return crew.getTitle();
    }

}
