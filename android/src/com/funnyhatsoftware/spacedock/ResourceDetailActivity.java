
package com.funnyhatsoftware.spacedock;

import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Universe;

public class ResourceDetailActivity extends DetailActivity {

    @Override
    protected String setupValues(Universe universe, String itemId) {
        Resource resource = universe.getResource(itemId);

        mValues.add(new Pair("Name", resource.getTitle()));
        mValues.add(new Pair("Cost", resource.getCost()));
        mValues.add(new Pair("Ability", resource.getAbility()));
        return resource.getTitle();
    }

}
