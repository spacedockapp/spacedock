package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;

import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.data.Upgrade;

import java.util.List;

public class UpgradeHolder extends SetItemHolder {
    public static final String TYPE_STRING_CREW = "Crew";
    public static final String TYPE_STRING_TALENT = "Talent";
    public static final String TYPE_STRING_TECH = "Tech";
    public static final String TYPE_STRING_BORG = "Borg";
    public static final String TYPE_STRING_SQUADRON = "Squadron";
    public static final String TYPE_STRING_OFFICER = "Officer";
    static SetItemHolderFactory getFactory(Class upClass, final String upType) {
        return new SetItemHolderFactory(upClass, upType) {
            @Override
            public SetItemHolder createHolder(View view) {
                return new UpgradeHolder(view);
            }

            @Override
            public List<? extends SetItem> getItemsForFaction(String faction) {
                return Universe.getUniverse().getUpgradesForFaction(upType, faction);
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                Upgrade upgrade = Universe.getUniverse().getUpgrade(id);
                String faction = upgrade.getFaction();
                if (null != upgrade.getAdditionalFaction() && !"".equals(upgrade.getAdditionalFaction())) {
                    faction += ", " + upgrade.getAdditionalFaction();
                }
                builder.addString("Faction", faction);
                builder.addString("Type", upgrade.getUpType());
                builder.addInt("Cost", upgrade.getCost());
                builder.addBoolean("Unique", upgrade.getUnique());
                builder.addString("Set", upgrade.getSetName());
                builder.addString("Ability", upgrade.getAbility());
                return upgrade.getTitle();
            }
        };
    }

    private UpgradeHolder(View view) {
        super(view);
    }

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {}
}
