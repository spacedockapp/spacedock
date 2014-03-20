package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.activity.DetailActivity;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class CaptainHolder extends ItemHolder {
    public static final String TYPE_STRING = "Captain";
    static ItemHolderFactory getFactory() {
        return new ItemHolderFactory(TYPE_STRING, R.layout.captain_list_row, 0) {
            @Override
            public ItemHolder createHolder(View view) {
                return new CaptainHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getCaptainsForFaction(faction);
            }

            @Override
            public String getDetails(DetailActivity.DetailDataBuilder builder, String id) {
                Captain captain = Universe.getUniverse().getCaptain(id);
                builder.addString("Name", captain.getTitle());
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

    final TextView mTitle;
    final TextView mSkill;
    final TextView mCost;

    private CaptainHolder(View view) {
        mTitle = (TextView) view.findViewById(R.id.captainRowTitle);
        mSkill = (TextView) view.findViewById(R.id.captainRowSkill);
        mCost = (TextView) view.findViewById(R.id.captainRowCost);
    }

    @Override
    public void reinitialize(Resources res, Object item) {
        Captain captain = (Captain) item;
        mTitle.setText(captain.getTitle());
        mSkill.setText(Integer.toString(captain.getSkill()));
        mCost.setText(Integer.toString(captain.getCost()));
    }
}
