package com.funnyhatsoftware.spacedock.holder;

import android.support.v4.util.ArrayMap;
import android.view.View;

import com.funnyhatsoftware.spacedock.data.Crew;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Talent;
import com.funnyhatsoftware.spacedock.data.Tech;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;

import java.util.List;
import java.util.Set;

/**
 * Class that wraps the static portion of SetItem display - A ItemHolderFactory can be acquired from
 * a SetItem's type, and can be used to create an ListAdapter for displaying SetItems as
 * ItemHolder-managed ListView views.
 */
public abstract class ItemHolderFactory {
    private static final ArrayMap<Class, ItemHolderFactory> sFactoriesForClass =
            new ArrayMap<Class, ItemHolderFactory>();
    private static final ArrayMap<String, ItemHolderFactory> sFactoriesForType =
            new ArrayMap<String, ItemHolderFactory>();

    public static Set<String> getFactoryTypes() {
        return sFactoriesForType.keySet();
    }

    public static ItemHolderFactory getHolderFactory(String key) {
        if (!sFactoriesForType.containsKey(key)) {
            throw new IllegalStateException("factory of type " + key + " missing");
        }
        return sFactoriesForType.get(key);
    }

    public static ItemHolderFactory getHolderFactory(Class key) {
        if (!sFactoriesForClass.containsKey(key)) {
            throw new IllegalStateException("factory of type " + key + " missing");
        }
        return sFactoriesForClass.get(key);
    }

    private static void registerHolderFactory(ItemHolderFactory factory) {
        String factoryType = factory.getType();
        if (sFactoriesForType.containsKey(factoryType)) {
            throw new IllegalArgumentException(
                    "Error: factory with type " + factoryType + " already exists");
        }
        sFactoriesForClass.put(factory.getItemClass(), factory);
        sFactoriesForType.put(factory.getType(), factory);
    }

    public static void initialize() {
        if (!sFactoriesForType.isEmpty()) throw new IllegalStateException("double init attempted");
        registerHolderFactory(CaptainHolder.getFactory());
        registerHolderFactory(ShipHolder.getFactory());
        registerHolderFactory(FlagshipHolder.getFactory());
        registerHolderFactory(WeaponHolder.getFactory());
        registerHolderFactory(ResourceHolder.getFactory());
        registerHolderFactory(UpgradeHolder.getFactory(Crew.class, UpgradeHolder.TYPE_STRING_CREW));
        registerHolderFactory(UpgradeHolder.getFactory(Talent.class, UpgradeHolder.TYPE_STRING_TALENT));
        registerHolderFactory(UpgradeHolder.getFactory(Tech.class, UpgradeHolder.TYPE_STRING_TECH));
    }

    private final Class mClazz;
    private final String mType;

    public ItemHolderFactory(Class clazz, String type) {
        mClazz = clazz;
        mType = type;
    }

    public Class getItemClass() { return mClazz; }
    public String getType() { return mType; }
    public boolean usesFactions() { return true; }
    public abstract ItemHolder createHolder(View view);
    public abstract List<? extends SetItem> getItemsForFaction(String faction);
    public abstract String getDetails(DetailsFragment.DetailDataBuilder builder, String id);
}
