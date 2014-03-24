package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.data.Flagship;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class FlagshipHolder extends ItemHolder.BaseItemHolder {
    public static final String TYPE_STRING = "Flagship";
    static ItemHolderFactory getFactory() {
        return new ItemHolderFactory(Flagship.class, TYPE_STRING) {
            @Override
            public ItemHolder createHolder(View view) {
                return new FlagshipHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getFlagshipsForFaction(faction);
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                Flagship fs = Universe.getUniverse().getFlagship(id);
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

    final TextView mAttack;
    final TextView mAgility;
    final TextView mHull;
    final TextView mShield;

    private FlagshipHolder(View view) {
        super(view, R.layout.item_flagship_values);
        mAttack = (TextView) view.findViewById(R.id.attack);
        mAgility = (TextView) view.findViewById(R.id.agility);
        mHull = (TextView) view.findViewById(R.id.hull);
        mShield = (TextView) view.findViewById(R.id.shield);

        mUnique.setVisibility(View.GONE);
        mCost.setVisibility(View.GONE);
    }

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {
        Flagship flagship = (Flagship) item;
        setPositiveIntegerText(mAttack, flagship.getAttack());
        setPositiveIntegerText(mAgility, flagship.getAgility());
        setPositiveIntegerText(mHull, flagship.getHull());
        setPositiveIntegerText(mShield, flagship.getShield());
    }
}
