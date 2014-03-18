// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.Map;

public class SideboardBase extends EquippedShip {

    public void update(Map<String,Object> data) {
        super.update(data);
    }


    public boolean equals(Object obj) {
        if (obj == null)
            return false;
        if (obj == this)
            return false;
        if (!(obj instanceof Sideboard))
            return false;
        return true;
    }

}
