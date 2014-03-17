package com.funnyhatsoftware.spacedock.holder;

import android.content.Context;
import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.UpgradeDetailActivity;
import com.funnyhatsoftware.spacedock.data.SetItem;
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

    @Override
    public void navigateToDetails(Context context, Object item) {
        navigateToDetailsActivity(context, (SetItem)item, UpgradeDetailActivity.class);
    }
}
