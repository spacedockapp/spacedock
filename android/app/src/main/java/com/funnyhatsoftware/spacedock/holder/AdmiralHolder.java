package com.funnyhatsoftware.spacedock.holder;

import java.util.List;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Admiral;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;

public class AdmiralHolder extends SetItemHolder{
	 public static final String TYPE_STRING = "Admiral";
	 static SetItemHolderFactory getFactory() {
	    return new SetItemHolderFactory(Admiral.class, TYPE_STRING) {
            @Override
            public SetItemHolder createHolder(View view) {
                return new AdmiralHolder(view);
            }

            @Override
            public List<? extends SetItem> getItemsForFaction(String faction) {
                return Universe.getUniverse().getAdmiralsForFaction(faction);
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                Admiral admiral = Universe.getUniverse().getAdmiral(id);
                String faction = admiral.getFaction();
                if (!"".equals(admiral.getAdditionalFaction())) {
                    faction += ", " + admiral.getAdditionalFaction();
                }
                builder.addString("Faction", faction);
                builder.addString("Type", admiral.getUpType());
                builder.addInt("Skill", admiral.getSkillModifier());
                builder.addInt("Cost", admiral.getAdmiralCost());
                builder.addBoolean("Unique", admiral.getUnique());
                builder.addInt("Talents", admiral.getAdmiralTalent());
                builder.addString("Set", admiral.getSetName());
                builder.addString("Ability", admiral.getAdmiralAbility());
                return admiral.getTitle();
            }
        };
    }
	 final TextView mSkill;

	    private AdmiralHolder(View view) {
	        super(view, R.layout.item_admiral_values);
	        mSkill = (TextView) view.findViewById(R.id.admiralRowSkill);
	    }

	    @Override
	    public void reinitializeStubViews(Resources res, SetItem item) {
	        Admiral admiral = (Admiral) item;
	        mSkill.setText("+" + Integer.toString(admiral.getSkillModifier()));
	        mAbility.setText(admiral.getAdmiralAbility());
	    }

}
