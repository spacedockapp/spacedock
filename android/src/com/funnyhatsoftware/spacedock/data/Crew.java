
package com.funnyhatsoftware.spacedock.data;

public class Crew extends CrewBase {
    public Crew crewForId(String externalId) {
        return (Crew) Universe.getUniverse().getUpgrade(externalId);
    }
}
