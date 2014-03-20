package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.DetailActivity;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;

import java.util.List;

public class UpgradeHolder extends ItemHolder {
    public static final String TYPE_STRING_CREW = "Crew";
    public static final String TYPE_STRING_TALENT = "Talent";
    public static final String TYPE_STRING_TECH = "Tech";
    static ItemHolderFactory getFactory(final String upType) {
        return new ItemHolderFactory(upType, R.layout.upgrade_list_row, 0) {
            @Override
            public ItemHolder createHolder(View view) {
                return new UpgradeHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getUpgradesForFaction(upType, faction);
            }

            @Override
            public String getDetails(DetailActivity.DetailDataBuilder builder, String id) {
                Upgrade upgrade = Universe.getUniverse().getUpgrade(id);
                builder.addString("Name", upgrade.getTitle());
                builder.addString("Faction", upgrade.getFaction());
                builder.addString("Type", upgrade.getUpType());
                builder.addInt("Cost", upgrade.getCost());
                builder.addBoolean("Unique", upgrade.getUnique());
                builder.addString("Set", upgrade.getSetName());
                builder.addString("Ability", upgrade.getAbility());
                return upgrade.getTitle();

            }
        };
    }

    final TextView mTitle;
    final TextView mCost;

    private UpgradeHolder(View view) {
        mTitle = (TextView) view.findViewById(R.id.upgradeRowTitle);
        mCost = (TextView) view.findViewById(R.id.upgradeRowCost);
    }

    @Override
    public void reinitialize(Resources res, Object item) {
        Upgrade upgrade = (Upgrade) item;
        mTitle.setText(upgrade.getTitle());
        mCost.setText(Integer.toString(upgrade.getCost()));
    }
}
