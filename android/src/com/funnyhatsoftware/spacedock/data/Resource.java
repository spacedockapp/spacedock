package com.funnyhatsoftware.spacedock.data;

public class Resource extends ResourceBase {
	
	static final String kSideboardResourceId = "4003";
	static final String kFlagshipExternalId = "4004";

	public boolean getIsSideboard() {
		return externalId.equals(kSideboardResourceId);
	}

	public boolean getIsFlagship() {
		return externalId.equals(kFlagshipExternalId);
	}
}
