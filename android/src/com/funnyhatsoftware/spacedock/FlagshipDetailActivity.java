
package com.funnyhatsoftware.spacedock;

import com.funnyhatsoftware.spacedock.data.Flagship;
import com.funnyhatsoftware.spacedock.data.Universe;

public class FlagshipDetailActivity extends DetailActivity {

    @Override
    protected String setupValues(Universe universe, String itemId) {
        Flagship fs = universe.getFlagship(itemId);

        mValues.add(new Pair("Name", fs.getTitle()));
        mValues.add(new Pair("Faction", fs.getFaction()));
        addPair("Attack", fs.getAttack());
        addPair("Agility", fs.getAgility());
        addPair("Hull", fs.getHull());
        addPair("Shield", fs.getShield());
        mValues.add(new Pair("Capabilities", fs.getCapabilities()));
        mValues.add(new Pair("Ability", fs.getAbility()));
        return fs.getTitle();
    }

}
