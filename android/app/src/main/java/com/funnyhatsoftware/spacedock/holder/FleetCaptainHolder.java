package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.FleetCaptain;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;

import java.util.List;

/**
 * Created by Thomas on 8/14/2014.
 */
public class FleetCaptainHolder extends SetItemHolder {
    public static final String TYPE_STRING = "FleetCaptain";
    static SetItemHolderFactory getFactory() {
        return new SetItemHolderFactory(FleetCaptain.class, TYPE_STRING) {
            @Override
            public SetItemHolder createHolder(View view) {
                return new FleetCaptainHolder(view);
            }

            @Override
            public List<? extends SetItem> getItemsForFaction(String faction) {
                return Universe.getUniverse().getFleetCaptainsForFaction(faction);
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                FleetCaptain fs = Universe.getUniverse().getFleetCaptain(id);
                builder.addString("Faction", fs.getFaction());
                builder.addInt("Talent", fs.getTalentAdd());
                builder.addInt("Crew", fs.getCrewAdd());
                builder.addInt("Weapon", fs.getWeaponAdd());
                builder.addInt("Tech", fs.getTechAdd());
                builder.addString("Capabilities", fs.getCapabilities());
                builder.addString("Ability", fs.getAbility());
                return fs.getTitle();
            }
        };
    }

    final TextView mCaptainMod;

    private FleetCaptainHolder(View view) {
        super(view, R.layout.item_admiral_values);
        mCaptainMod = (TextView) view.findViewById(R.id.admiralRowSkill);

        mUnique.setVisibility(View.GONE);
        mCost.setVisibility(View.GONE);
    }

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {
        FleetCaptain fleetCaptain = (FleetCaptain) item;
        setPositiveIntegerText(mCaptainMod, fleetCaptain.getCaptainSkillBonus());
    }
}
