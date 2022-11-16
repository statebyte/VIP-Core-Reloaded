
// Structure...

enum ChatHookType
{
	ChatHook_None = 0,
	ChatHook_CustomFeature,
	ChatHook_GenerateNewGroup,
	ChatHook_SearchPlayer
}

enum
{
	ADMIN_MENU,
	TOP_MENU
}

// Система приоритетов...
enum
{
	PRIORITY_PLUGIN = -3,
	PRIORITY_CUSTOM = -2,
	PRIORITY_PARANT_GROUP = -1,
	PRIORITY_NORMAL
}

enum struct Times
{
	char Phrase[64];
	int Time;
}
ArrayList g_hTimes;

enum struct ServerData
{
	int ServerID;
	int StorageID;

	EngineVersion Engine;

	VIP_DatabaseUsage DB_Type;
	Database DB;

	float SpawnDelay;

	char GroupsConfigPath[PLATFORM_MAX_PATH];

	char LogsPath[PLATFORM_MAX_PATH];
	char DumpLogsPath[PLATFORM_MAX_PATH];
	char DebugLogsPath[PLATFORM_MAX_PATH];

	// VIP_IsLoaded
	bool CoreIsReady;
}
ServerData g_eServerData;

enum struct PlayerFeature
{
	char Key[VIP_FEATURENAME_LENGTH];
	char Value[VIP_FEATUREVALUE_LENGTH];

	int CurrentPriority;
	int GroupID;
	bool bEnabled; // Для нормального Feature Manager
}

enum struct PlayerStorage
{
	char Key[VIP_FEATURENAME_LENGTH];
	char Value[VIP_FEATUREVALUE_LENGTH];
}

enum struct GroupInfo
{
	char Name[VIP_GROUPNAME_LENGTH];

	// List of Feature (PlayerFeature)
	ArrayList hFeatureList;

	// List of extend Groups...
	ArrayList hExtendList;

	void Init()
	{
		//if(this.hFeatureList) delete this.hFeatureList;
		//if(this.hExtendList) delete this.hExtendList;

		this.hFeatureList = new ArrayList(sizeof(PlayerFeature));
		this.hExtendList = new ArrayList(VIP_GROUPNAME_LENGTH);
	}

	void Clear()
	{
		this.Name[0] = EOS;
		this.hFeatureList.Clear();
		this.hExtendList.Clear();
	}

	void AddFeature(char[] sKey, char[] sValue, int iPriority = 0)
	{
		PlayerFeature hPFeature;
		strcopy(hPFeature.Key, sizeof(hPFeature.Key), sKey);
		strcopy(hPFeature.Value, sizeof(hPFeature.Value), sValue);

		int iIndex = this.GetFeatureIDByKey(sKey);

		if(iIndex == -1)
		{
			this.hFeatureList.PushArray(hPFeature, sizeof(hPFeature));
		}
		else
		{
			this.hFeatureList.SetArray(iIndex, hPFeature, sizeof(hPFeature));
		}
	}

	void DelFeature(char[] sKey)
	{
		int iIndex = this.GetFeatureIDByKey(sKey);

		if(iIndex != -1)
		{
			this.hFeatureList.Erase(iIndex);
		}
	}

	int GetFeatureIDByKey(char[] sKey)
	{
		int iLen = this.hFeatureList.Length;

		for(int i = 0; i < iLen; i++)
		{
			PlayerFeature hFeature;
			this.hFeatureList.GetArray(i, hFeature, sizeof(hFeature));

			if(!strcmp(hFeature.Key, sKey)) return i;
		}

		return -1;
	}

	void AddExtend(char[] sKey)
	{
		this.hExtendList.PushString(sKey);
	}
}
ArrayList g_hGroups;

enum struct PlayerGroup
{
	char Name[VIP_GROUPNAME_LENGTH];
	int ExpireTime;
}

// API
enum struct Feature
{
	char Key[VIP_FEATURENAME_LENGTH];

	
	VIP_ValueType ValType;
	// check VIP_FeatureType
	VIP_FeatureType Type;
	

	Function OnSelectCB;
	Function OnDisplayCB;
	Function OnDrawCB;

	Handle hPlugin;

	VIP_ToggleState ToggleState;

	bool bCookie;
}
ArrayList g_hFeatures;
ArrayList g_hFeaturesSorted;

enum StatusLoading
{
	Status_None,
	Status_Loading,
	Status_Loaded,
	Status_Error
}

/* Player Struct
*/
enum struct PlayerData
{
	int iClient;

	int UserID;
	int AccountID;

	// State
	StatusLoading Status;

	// State (Groups > 0)
	bool bVIP;

	// List of groups player... (check PlayerGroup)
	ArrayList hGroups;

	// ArrayList feature builded from groups (check PlayerFeature)
	ArrayList hFeatures;

	// Unique for player (check PlayerFeature)
	ArrayList hCustomFeatures;

	// Settings Player...
	ArrayList hStorage;

	ChatHookType HookChat;
	// For ConfirmMenu...
	Function hCallBack;

	// AdminMenu
	int CurrentTarget;
	int CurrentGroup;
	int CurrentTime;
	char CurrentFeature[VIP_FEATURENAME_LENGTH];
	int LastMenuType;

	// VIP Menu
	int CurrentPage;

	bool CheckGroup(char[] sGroup)
	{
		return this.GetGroupIDByName(sGroup) > -1;
	}

	void AddGroup(char sGroup[VIP_GROUPNAME_LENGTH], int iExpire = 0)
	{
		int iIndex = this.GetGroupIDByName(sGroup);

		PlayerGroup hGroup;
		hGroup.Name = sGroup;
		hGroup.ExpireTime = iExpire;

		if(iIndex == -1) 
		{
			this.hGroups.PushArray(hGroup, sizeof(hGroup));
		}
		else
		{
			this.hGroups.SetArray(iIndex, hGroup, sizeof(hGroup));
		}

		this.RebuildFeatureList();
		CallForward_OnAddGroup(this.iClient, sGroup);
	}

	void RemoveGroup(char[] sGroup)
	{
		int iIndex = this.GetGroupIDByName(sGroup);
		if(iIndex != -1)
		{
			this.hGroups.Erase(iIndex);

			this.RebuildFeatureList();
			CallForward_OnRemoveGroup(this.iClient, sGroup);
		}
	}

	int GetExpireTimeByGroupID(int iIndex)
	{
		PlayerGroup hGroup;
		this.hGroups.GetArray(iIndex, hGroup, sizeof(hGroup));

		return hGroup.ExpireTime;
	}

	int GetGroupIDByName(char[] sName)
	{
		int iLen = this.hGroups.Length;
		for(int i = 0; i < iLen; i++)
		{
			PlayerGroup hGroup;
			this.hGroups.GetArray(i, hGroup, sizeof(hGroup));

			if(!strcmp(hGroup.Name, sName)) return i;
		}

		return -1;
	}

	void EnableFeature(char[] sFeature)
	{
		int iIndex = this.GetFeatureIDByName(sFeature);

		if(iIndex != -1)
		{
			this.hFeatures.Set(iIndex, true, PlayerFeature::bEnabled);
		}
	}

	void DisableFeature(char[] sFeature)
	{
		int iIndex = this.GetFeatureIDByName(sFeature);

		if(iIndex != -1)
		{
			this.hFeatures.Set(iIndex, false, PlayerFeature::bEnabled);
		}
	}

	bool IsFeatureEnable(char[] sFeature)
	{
		int iIndex = this.GetFeatureIDByName(sFeature);

		if(iIndex != -1)
		{
			return this.hFeatures.Get(iIndex, PlayerFeature::bEnabled);
		}

		return false;
	}

	void AddFeature(char[] sKey, char[] sValue, int iPriority = 0, int iGroupID = -1)
	{
		DebugMsg(DBG_INFO, "AddFeature - %s - %s | %i", sKey, sValue, iPriority);
		PlayerFeature hPFeature;
		strcopy(hPFeature.Key, sizeof(hPFeature.Key), sKey);
		strcopy(hPFeature.Value, sizeof(hPFeature.Value), sValue);
		hPFeature.CurrentPriority = iPriority;
		hPFeature.GroupID = iGroupID;
		hPFeature.bEnabled = true;

		// Получаем индекс функции в массиве
		int iIndex = this.GetFeatureIDByName(sKey);

		// Если функции нету, создаём новую...
		if(iIndex == -1)
		{
			DebugMsg(DBG_INFO, "PushArray - %s", sKey);
			this.hFeatures.PushArray(hPFeature, sizeof(hPFeature));
		}
		else 
		{
			// Если мы хотим удалить параметр из списка...
			if(!sValue[0])
			{
				DebugMsg(DBG_INFO, "Erase - %s", sKey);
				this.hFeatures.Erase(iIndex);
				return;
			}

			DebugMsg(DBG_INFO, "GetArray - %s", sKey);
			// Если есть, проверяем текущий приоритет...
			PlayerFeature hCurrentPFeature;
			this.hFeatures.GetArray(iIndex, hCurrentPFeature, sizeof(hCurrentPFeature));

			if(iPriority <= hCurrentPFeature.CurrentPriority)
			{
				DebugMsg(DBG_INFO, "SetArray - %s", sKey);
				this.hFeatures.SetArray(iIndex, hPFeature, sizeof(hPFeature));
			}
		}
	}

	bool SaveStorage(char[] sKey, char[] sValue)
	{
		PlayerStorage hStorage;
		strcopy(hStorage.Key, sizeof(hStorage.Key), sKey);
		strcopy(hStorage.Value, sizeof(hStorage.Value), sValue);

		int iIndex = this.GetStorageIDByName(sKey);

		if(iIndex == -1)
		{
			this.hStorage.PushArray(hStorage, sizeof(hStorage));
		}
		else
		{
			this.hStorage.SetArray(iIndex, hStorage, sizeof(hStorage));
		}

		CallForward_OnStorageUpdate(this.iClient, sKey);

		return true;
	}

	void ToggleFeatureStatus(char[] sKey, int iAuto = -1)
	{
		VIP_ToggleState State = this.GetFeatureToggleStatus(sKey);

		char sBuf[4];
		if(iAuto == -1)
		{
			IntToString(State == ENABLED ? 0 : 1, sBuf, sizeof(sBuf));
		}
		else
		{
			IntToString(iAuto, sBuf, sizeof(sBuf));
		}

		this.SaveStorage(sKey, sBuf);
	}

	VIP_ToggleState GetFeatureToggleStatus(char[] sKey)
	{
		int iIndex = this.GetFeatureIDByName(sKey);

		if(iIndex == -1)
		{
			return NO_ACCESS;
		}

		iIndex = this.GetStorageIDByName(sKey);

		if(iIndex != -1)
		{
			PlayerStorage hStorage;
			this.hStorage.GetArray(iIndex, hStorage, sizeof(hStorage));
			return view_as<VIP_ToggleState>(StringToInt(hStorage.Value));
		}

		// По умолчанию функция выкл или вкл?
		return DISABLED;
	}

	int GetStorageIDByName(char[] sKey)
	{
		int iLen = this.hStorage.Length;
		for(int i = 0; i < iLen; i++)
		{
			PlayerStorage hStorage;
			this.hStorage.GetArray(i, hStorage, sizeof(hStorage));
			if(!strcmp(hStorage.Key, sKey)) return i;
		}

		return -1;
	}

	int GetFeatureIDByName(char[] sKey)
	{
		int iLen = this.hFeatures.Length;
		for(int i = 0; i < iLen; i++)
		{
			PlayerFeature hPFeature;
			this.hFeatures.GetArray(i, hPFeature, sizeof(hPFeature));
			if(!strcmp(hPFeature.Key, sKey)) return i;
		}

		return -1;
	}

	bool RemoveFeature(char[] sKey)
	{
		int iIndex = this.GetFeatureIDByName(sKey);

		if(iIndex != -1)
		{
			this.hFeatures.Erase(iIndex);
			return true;
		}

		return false;
	}

	bool AddCustomFeature(char[] sKey, char[] sValue)
	{
		int iIndex = this.GetCustomFeatureIDByKey(sKey);

		PlayerFeature hFeature;
		strcopy(hFeature.Key, sizeof(hFeature.Key), sKey);
		strcopy(hFeature.Value, sizeof(hFeature.Value), sValue);

		if(iIndex != -1)
		{
			this.hCustomFeatures.SetArray(iIndex, hFeature, sizeof(hFeature));
		}
		else
		{
			this.hCustomFeatures.PushArray(hFeature, sizeof(hFeature));
		}

		this.RebuildFeatureList();

		return true;
	}

	bool RemoveCustomFeature(char[] sKey)
	{
		int iIndex = this.GetCustomFeatureIDByKey(sKey);

		if(iIndex != -1)
		{
			this.hCustomFeatures.Erase(iIndex);

			this.RebuildFeatureList();

			return true;
		}

		return false;
	}

	int GetCustomFeatureIDByKey(char[] sKey)
	{
		int iLen = this.hCustomFeatures.Length;

		for(int i = 0; i < iLen; i++)
		{
			PlayerFeature hFeature;
			this.hCustomFeatures.GetArray(i, hFeature, sizeof(hFeature));

			if(!strcmp(hFeature.Key, sKey)) return i;
		}

		return -1;
	}

	void RebuildFeatureList()
	{
		DebugMsg(DBG_INFO, "Start - RebuildFeatureList - this.hFeatures.Clear()");
		this.hFeatures.Clear();

		int iLen = g_hGroups.Length;
		for(int i = iLen-1; i >= 0; i--)
		{
			GroupInfo hGroup;
			g_hGroups.GetArray(i, hGroup, sizeof(hGroup));

			if(this.CheckGroup(hGroup.Name))
			{
				DebugMsg(DBG_INFO, "Group: %s", hGroup.Name);

				this.AddFeatureByGroupID(i);
			}
		}

		// Выставляем игроку кастомные функции...
		iLen = this.hCustomFeatures.Length;
		for(int i = 0; i < iLen; i++)
		{
			PlayerFeature hPFeature;
			this.hCustomFeatures.GetArray(i, hPFeature, sizeof(hPFeature));

			this.AddFeature(hPFeature.Key, hPFeature.Value, PRIORITY_CUSTOM, PRIORITY_CUSTOM);
		}

		this.bVIP = this.IsVIP();
		CallForward_OnRebuildFeatureList(this.iClient);
	}

	void AddFeatureByGroupID(int iIndex, int iDeep = 0)
	{
		GroupInfo hGroup;
		g_hGroups.GetArray(iIndex, hGroup, sizeof(hGroup));

		char sName[VIP_GROUPNAME_LENGTH];
		int iLen = hGroup.hExtendList.Length;
		for(int i = 0; i < iLen; i++)
		{
			hGroup.hExtendList.GetString(i, sName, sizeof(sName));
		
			int iID = GetGroupIDByName(sName);
			if(iID != -1)
			{
				char sBuffer[256];
				for(int j = 0; j < iDeep+1; j++)
				{
					sBuffer[j] = '>';
				}
				sBuffer[iDeep+1] = '\0';
				DebugMsg(DBG_INFO, "Extend: %s %s", sBuffer, sName);
				iDeep++;
				this.AddFeatureByGroupID(iID, iDeep);
			}
		}

		iLen = hGroup.hFeatureList.Length;
		for(int i = 0; i < iLen; i++)
		{
			PlayerFeature hPFeature;
			hGroup.hFeatureList.GetArray(i, hPFeature, sizeof(hPFeature));

			// Приоритет группы по ее сортировке в groups.ini
			int iGroupID = GetGroupIDByName(hGroup.Name);
			this.AddFeature(hPFeature.Key, hPFeature.Value, iDeep == 0 ? PRIORITY_PARANT_GROUP : iGroupID, iGroupID);
		}
	}

	// Получение ID группы с максимальным приоритетом
	int GetGroupIDByMaxPriority()
	{
		int iLen = this.hGroups.Length;

		int iResult = -1;

		PlayerGroup hGroup;

		for(int i = 0; i < iLen; i++)
		{
			this.hGroups.GetArray(i, hGroup, sizeof(hGroup));

			int iPriorityID = GetGroupIDByName(hGroup.Name);

			DebugMsg(DBG_INFO, "%i - %s", iPriorityID, hGroup.Name);

			if(iPriorityID != -1) iResult = iPriorityID;
		}

		DebugMsg(DBG_INFO, "result %i", iResult);

		return iResult;
	}

	void Init(int iClient)
	{
		this.iClient = iClient;
		this.hGroups = new ArrayList(sizeof(PlayerGroup));
		this.hFeatures = new ArrayList(sizeof(PlayerFeature));
		this.hCustomFeatures = new ArrayList(sizeof(PlayerFeature));
		this.hStorage = new ArrayList(sizeof(PlayerStorage));
	}

	void SetID()
	{
		this.AccountID = GetSteamAccountID(this.iClient);
		this.UserID = GetClientUserId(this.iClient);
	}

	void LoadData()
	{
		// TODO: Загрузка данных...
		this.SetID();

		if(CallForward_OnClientPreLoad(this.iClient))
		{
			DB_LoadPlayerData(this.iClient);

			this.RebuildFeatureList();
		}
	}

	void ClearData()
	{
		this.Status = Status_None;
		this.hGroups.Clear();
		this.hFeatures.Clear();
		this.hCustomFeatures.Clear();
		this.bVIP = false;
	}

	void UpdateData()
	{
		DB_UpdatePlayerData(this.iClient);
	}

	/* VIP-статус
	Может быть выдан не только, если есть хотя бы одна группа, но и когда у игрока есть хотя бы одна функция!
	*/
	bool IsVIP()
	{
		return this.hFeatures.Length > 0 || this.hGroups.Length > 0;
	}
}
PlayerData g_ePlayerData[MAXPLAYERS+1];

// Methods...

void LoadStructModule()
{
	g_hGroups = new ArrayList(sizeof(GroupInfo));
	g_hFeatures = new ArrayList(sizeof(Feature));
	g_hFeaturesSorted = new ArrayList(ByteCountToCells(VIP_FEATURENAME_LENGTH));
	g_hTimes = new ArrayList(sizeof(Times));

	InitServerData();
	InitPlayersData();
}

void InitServerData()
{
	// FUCKING SM 1.10
	char sPath[PLATFORM_MAX_PATH];

	BuildPath(Path_SM, sPath, sizeof(sPath), "%s/%s", CONFIG_MAIN_PATH, CONFIG_GROUPS_FILENAME);
	g_eServerData.GroupsConfigPath = sPath;

	BuildPath(Path_SM, sPath, sizeof(sPath), "logs/%s", LOGS_FILENAME);
	g_eServerData.LogsPath = sPath;

	BuildPath(Path_SM, sPath, sizeof(sPath), "logs/%s", LOGS_DEBUG_FILENAME);
	g_eServerData.DebugLogsPath = sPath;

	BuildPath(Path_SM, sPath, sizeof(sPath), "logs/%s", LOGS_DUMP_FILENAME);
	g_eServerData.DumpLogsPath = sPath;

	g_eServerData.Engine = GetEngineVersion();

	DebugMsg(DBG_INFO, "New log started VIP Core - version %s", PL_VERSION);
	DumpMsg("New log started VIP Core - version %s", PL_VERSION);
}

int GetGroupIDByName(char[] sKey)
{
	int iLen = g_hGroups.Length;
	for(int i = 0; i < iLen; i++)
	{
		GroupInfo hGroup;
		g_hGroups.GetArray(i, hGroup, sizeof(hGroup));
		if(!strcmp(hGroup.Name, sKey)) return i;
	}

	return -1;
}

bool IsFeatureExists(char[] sKey)
{
	return GetFeatureIDByKey(sKey) != -1 ? true : false;
}

int GetFeatureIDByKey(char[] sKey)
{
	int iLen = g_hFeatures.Length;
	for(int i = 0; i < iLen; i++)
	{
		Feature hFeature;
		g_hFeatures.GetArray(i, hFeature, sizeof(hFeature));

		if(!strcmp(hFeature.Key, sKey)) return i;
	}
	return -1;
}

void InitPlayersData()
{
	for(int i = 0; i <= MaxClients; i++)
	{
		g_ePlayerData[i].Init(i);
	}
}

void LoadPlayersData()
{
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		g_ePlayerData[i].SetID();
		g_ePlayerData[i].UpdateData();
		g_ePlayerData[i].LoadData();
	}
}

void RebuildFeatureList()
{
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		g_ePlayerData[i].RebuildFeatureList();
	}
}