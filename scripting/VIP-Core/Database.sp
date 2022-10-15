
#define CHARSET "utf8mb4"
#define COLLATION "utf8mb4_unicode_ci"

#define TABLE_USERS "vip_users"
#define TABLE_GROUPS "vip_groups"
#define TABLE_FEATURES "vip_features"
#define TABLE_STORAGE "vip_storage"

int g_iCreateTablesCount = 0;

void LoadDatabase()
{
	// Проверка на секцию в databases.cfg
	if(SQL_CheckConfig("vip_core"))
	{
		Database.Connect(OnConnect, "vip_core");
	}
	else
	{
		// Теперь мы можем сразу вызвать готовность VIP, так как база не обязательна...
		CallForward_OnVIPLoaded();
	}
}

bool Check_DatabaseConnection(char[] sFunction, const char[] sError, bool bFailState = false)
{
	if(sError[0])
	{
		if(bFailState) SetFailState("%s: %s", sFunction , sError);

		LogMessage("%s: %s", sFunction , sError);
		return true;
	}

	return false;
}

void OnConnect(Database db, const char[] error, any data)
{
	LogMessage(error);

	g_iCreateTablesCount = 0;
	g_eServerData.DB = db;
	DBDriver driver = SQL_ReadDriver(db);

	char sDriverName[64];
	driver.GetProduct(sDriverName, sizeof(sDriverName));

	PrintToServer(sDriverName);

	if(!strcmp(sDriverName, "MySQL"))
	{
		g_eServerData.DB_Type = DB_MySQL;
	}

	if(!strcmp(sDriverName, "sqlite"))
	{
		g_eServerData.DB_Type = DB_SQLite;
	}

	// TODO - PostgreSQL

	DB_CreateTables();
}

void DB_CreateTables()
{
	g_eServerData.DB.Query(SQL_Callback_TableCreate,	"CREATE TABLE IF NOT EXISTS `"... TABLE_USERS ..."` (\
					`account_id` INT NOT NULL, \
					`name` VARCHAR(64) NOT NULL default 'unknown' COLLATE '" ... COLLATION ... "', \
					`sid` INT UNSIGNED NOT NULL, \
					`lastvisit` INT UNSIGNED NOT NULL default 0 \
					) DEFAULT CHARSET=" ... CHARSET ... ";");

	g_eServerData.DB.Query(SQL_Callback_TableCreate,	"CREATE TABLE IF NOT EXISTS `"... TABLE_GROUPS ..."` (\
					`account_id` INT NOT NULL, \
					`sid` INT UNSIGNED NOT NULL, \
					`group` VARCHAR(64) NOT NULL, \
					`expires` INT UNSIGNED NOT NULL default 0, \
					CONSTRAINT pk_GroupID PRIMARY KEY (`account_id`, `sid`, `group`) \
					) DEFAULT CHARSET=" ... CHARSET ... ";");

	g_eServerData.DB.Query(SQL_Callback_TableCreate,	"CREATE TABLE IF NOT EXISTS `"... TABLE_STORAGE ..."` (\
					`account_id` INT NOT NULL, \
					`sid` INT UNSIGNED NOT NULL, \
					`key` VARCHAR(64) NOT NULL, \
					`value` VARCHAR(64) NOT NULL, \
					`updated` VARCHAR(64) NOT NULL, \
					CONSTRAINT pk_StorageID PRIMARY KEY (`account_id`, `sid`, `key`) \
					) DEFAULT CHARSET=" ... CHARSET ... ";");

	g_eServerData.DB.Query(SQL_Callback_TableCreate,	"CREATE TABLE IF NOT EXISTS `"... TABLE_FEATURES ..."` (\
					`account_id` INT NOT NULL, \
					`sid` INT UNSIGNED NOT NULL, \
					`key` VARCHAR(64) NOT NULL, \
					`value` VARCHAR(64) NOT NULL, \
					`updated` VARCHAR(64) NOT NULL, \
					CONSTRAINT pk_FeatureID PRIMARY KEY (`account_id`, `sid`, `key`) \
					) DEFAULT CHARSET=" ... CHARSET ... ";");
}

public void SQL_Callback_TableCreate(Database hOwner, DBResultSet hResult, const char[] szError, any data)
{
	if (Check_DatabaseConnection("SQL_Callback_TableCreate", szError, true)) return;

	g_iCreateTablesCount++;

	// Все таблицы созданы...
	if(g_iCreateTablesCount >= 4)
	{

		CallForward_OnVIPLoaded();
		LoadPlayersData();
	}
}

void DB_LoadPlayerData(int iClient)
{
	if(g_eServerData.DB_Type == DB_None) return;

	g_ePlayerData[iClient].Status = Status_Loading;

	char sQuery[1024];
	FormatEx(sQuery, sizeof(sQuery), "SELECT `group`, `expires` FROM `" ... TABLE_GROUPS ... "` WHERE `account_id` = %i AND `sid` = %i;", g_ePlayerData[iClient].AccountID, g_eServerData.ServerID);
	PrintToServer(sQuery);

	g_eServerData.DB.Query(SQL_LoadPlayerGroups, sQuery, iClient);
}

void DB_AddPlayerGroup(int iClient, char[] sGroup, int iExpire, int iTarget = 0)
{
	// switch(g_eServerData.DB_Type)
	// {
	// 	case DB_Postgre:
	// 	{

	// 	}
	// }
	char sQuery[1024];
	FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `" ... TABLE_GROUPS ... "` SET `account_id` = %i, `sid` = %i, `group` = '%s', `expires` = %i;", g_ePlayerData[iClient].AccountID, g_eServerData.ServerID, sGroup, iExpire);
	PrintToServer(sQuery);
	
	g_eServerData.DB.Query(SQL_CallbackAddPlayerGroup, sQuery, iTarget);
}

void DB_RemovePlayerGroup(int iClient, char[] sGroup, int iTarget = 0)
{
	char sQuery[1024];
	FormatEx(sQuery, sizeof(sQuery), "DELETE FROM `" ... TABLE_GROUPS ... "` WHERE `account_id` = %i AND `sid` = %i AND `group` = '%s';", g_ePlayerData[iClient].AccountID, g_eServerData.ServerID, sGroup);
	PrintToServer(sQuery);
	
	g_eServerData.DB.Query(SQL_CallbackAddPlayerGroup, sQuery, iTarget);
}

void SQL_LoadPlayerGroups(Database hOwner, DBResultSet hResult, const char[] szError, any data)
{
	if(szError[0])
	{
		PrintToServer(szError);
		return;
	}

	char sGroup[D_GROUPNAME_LENGTH];

	while(hResult.FetchRow()) // Тело цикла будет выполнятся пока можно получать данные
	{
		hResult.FetchString(0, sGroup, sizeof(sGroup));
		int iTime = hResult.FetchInt(1);
	
		g_ePlayerData[data].AddGroup(sGroup, iTime);
	}
}

void SQL_CallbackAddPlayerGroup(Database hOwner, DBResultSet hResult, const char[] szError, any data)
{
	if(szError[0])
	{
		PrintToServer(szError);
		PrintToChat(data, "[VIP] Ошибка добавления группы в БД");
		return;
	}

	if(data > 0)
	{
		PrintToChat(data, "[VIP] Группа %s успешно добавлена в БД...", g_ePlayerData[data].CurrentGroup);
	}

	return;
}