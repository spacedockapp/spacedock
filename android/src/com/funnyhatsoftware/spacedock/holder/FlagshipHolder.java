package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.DetailActivity;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Flagship;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class FlagshipHolder extends ItemHolder {
    public static final String TYPE_STRING = "Flagship";
    static ItemHolderFactory getFactory() {
        return new ItemHolderFactory(TYPE_STRING, R.layout.flagship_list_row, 0) {
            @Override
            public ItemHolder createHolder(View view) {
                return new FlagshipHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getFlagshipsForFaction(faction);
            }

            @Override
            public String getDetails(DetailActivity.DetailDataBuilder builder, String id) {
                Flagship fs = Universe.getUniverse().getFlagship(id);
                builder.addString("Name", fs.getTitle());
                builder.addString("Faction", fs.getFaction());
                builder.addInt("Attack", fs.getAttack());
                builder.addInt("Agility", fs.getAgility());
                builder.addInt("Hull", fs.getHull());
                builder.addInt("Shield", fs.getShield());
                builder.addString("Capabilities", fs.getCapabilities());
                builder.addString("Ability", fs.getAbility());
                return fs.getTitle();
            }
        };
    }

    final TextView mTitle;
    final TextView mAttack;
    final TextView mAgility;
    final TextView mHull;
    final TextView mShield;

    private FlagshipHolder(View view) {
        mTitle = (TextView) view.findViewById(R.id.flagshipRowTitle);
        mAttack = (TextView) view.findViewById(R.id.flagshipRowAttack);
        mAgility = (TextView) view.findViewById(R.id.flagshipRowAgility);
        mHull = (TextView) view.findViewById(R.id.flagshipRowHull);
        mShield = (TextView) view.findViewById(R.id.flagshipRowShield);
    }

    @Override
    public void reinitialize(Resources res, Object item) {
        Flagship flagship = (Flagship) item;
        mTitle.setText(flagship.getTitle());

        setPositiveIntegerText(mAttack, flagship.getAttack());
        setPositiveIntegerText(mAgility, flagship.getAgility());
        setPositiveIntegerText(mHull, flagship.getHull());
        setPositiveIntegerText(mShield, flagship.getShield());
    }
}
