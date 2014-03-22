package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class CaptainHolder extends ItemHolder.BaseItemHolder {
    public static final String TYPE_STRING = "Captain";
    static ItemHolderFactory getFactory() {
        return new ItemHolderFactory(TYPE_STRING) {
            @Override
            public ItemHolder createHolder(View view) {
                return new CaptainHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getCaptainsForFaction(faction);
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                Captain captain = Universe.getUniverse().getCaptain(id);
                builder.addString("Faction", captain.getFaction());
                builder.addString("Type", captain.getUpType());
                builder.addInt("Skill", captain.getSkill());
                builder.addInt("Cost", captain.getCost());
                builder.addBoolean("Unique", captain.getUnique());
                builder.addInt("Talents", captain.getTalent());
                builder.addString("Set", captain.getSetName());
                builder.addString("Ability", captain.getAbility());
                return captain.getTitle();
            }
        };
    }

    final TextView mSkill;

    private CaptainHolder(View view) {
        super(view, R.layout.item_captain_values);
        mSkill = (TextView) view.findViewById(R.id.captainRowSkill);
    }

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {
        Captain captain = (Captain) item;
        mSkill.setText(Integer.toString(captain.getSkill()));
    }
}
