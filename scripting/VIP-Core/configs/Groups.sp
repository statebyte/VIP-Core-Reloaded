enum EConfigState_t
{
	Section_None = 0,
	Section_Groups,
	Section_Group
}
EConfigState_t eCurrentSection = Section_None;

SMCParser g_hConfigParser;
int g_iIgnoreLevel;
int g_iCurrentLine;

GroupInfo g_hGroup;

void LoadConfigurationModule()
{
	LoadGroupsConfig();
	LoadFeatureSortList();
	LoadTimesList();
}

void LoadTimesList()
{
	DebugMsg(DBG_INFO, "LoadTimesList");
	g_hTimes.Clear();

	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "%s/%s", CONFIG_MAIN_PATH, CONFIG_TIMES_FILENAME);
	
	KeyValues hKeyValues = new KeyValues("TIMES");

	if (!hKeyValues.ImportFromFile(szPath))
	{
		addTestTimes();
		delete hKeyValues;
		return;
	}

	hKeyValues.Rewind();
	
	if (hKeyValues.GotoFirstSubKey(false))
	{
		char szTime[32];
		Times hTime;

		do
		{
			hKeyValues.GetSectionName(szTime, sizeof(szTime));

			hTime.Time = StringToInt(szTime);

			hKeyValues.GetString("", hTime.Phrase, sizeof(hTime.Phrase));

			g_hTimes.PushArray(hTime, sizeof(hTime));
			
		}
		while (hKeyValues.GotoNextKey(false));
	}
	
	delete hKeyValues;
}

void LoadFeatureSortList()
{
	DebugMsg(DBG_INFO, "LoadFeatureSortList");
	g_hFeaturesSorted.Clear();

	char sPath[PLATFORM_MAX_PATH], sBuffer[VIP_FEATURENAME_LENGTH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s/%s", CONFIG_MAIN_PATH, CONFIG_SORT_FILENAME);

	if(FileExists(sPath))
	{
		File hFile = OpenFile(sPath, "r");

		if (hFile != null)
		{
			while (!hFile.EndOfFile() && hFile.ReadLine(sBuffer, 128))
			{
				TrimString(sBuffer);
				if (sBuffer[0] && !(sBuffer[0] == '/' && sBuffer[1] == '/'))
				{
					g_hFeaturesSorted.PushString(sBuffer);
				}
			}
		}
		
		delete hFile;
	}
}

// SMC Parser
bool LoadGroupsConfig()
{
	DebugMsg(DBG_INFO, "LoadGroupsConfig");

	g_hGroups.Clear();

	if(!g_hConfigParser)
	{
		g_hConfigParser = new SMCParser();

		g_hConfigParser.OnEnterSection = Config_NewSection;
		g_hConfigParser.OnKeyValue = Config_KeyValue;
		g_hConfigParser.OnLeaveSection = Config_EndSection;
		g_hConfigParser.OnRawLine = Config_CurrentLine;
	}

	SMCError hErr = g_hConfigParser.ParseFile(g_eServerData.GroupsConfigPath);
	if (hErr != SMCError_Okay)
	{
		char sError[64];
		if (g_hConfigParser.GetErrorString(hErr, sError, sizeof(sError)))
		{
			LogError("Failed to parse: '%s'. Line: %d. Error: %s", g_eServerData.GroupsConfigPath, g_iCurrentLine, sError);
		}
		else
		{
			LogError("Failed to parse: '%s'. Line: %d. Unknown error.", g_iCurrentLine, g_eServerData.GroupsConfigPath);
		}
		
		return false;
	}

	CheckRecursiveErrors();

	RebuildFeatureList();

	DebugMsg(DBG_INFO, "Current Line: %i", g_iCurrentLine);

	return true;
}

// Проверка на рекурсию групп
void CheckRecursiveErrors()
{
	int iLen = g_hGroups.Length;

	bool bState = false;

	for(int i = 0; i < iLen; i++)
	{
		GroupInfo hGroup;
		g_hGroups.GetArray(i, hGroup, sizeof(hGroup));

		if(CheckParentGroup(i, hGroup.Name))
		{
			LogError("WARNING!!! - Recursive group %s", hGroup.Name);
			bState = true;
		}
	}

	if(bState)
	{
		SetFailState("[CONFIG] You have recursive groups!");
	}
}

bool CheckParentGroup(int iIndex, char[] sGroup)
{
	GroupInfo hGroup;
	g_hGroups.GetArray(iIndex, hGroup, sizeof(hGroup));

	char sBuf[VIP_GROUPNAME_LENGTH];

	int iSize = hGroup.hExtendList.Length;
	for(int i = 0; i < iSize; i++)
	{
		hGroup.hExtendList.GetString(i, sBuf, sizeof(sBuf));

		if(!strcmp(sGroup, sBuf)) return true;

		int iGID = GetGroupIDByName(sBuf);

		if(iGID != -1 && CheckParentGroup(iGID, sGroup))
		{
			return true;
		}
	}

	return false;
}

// Каллбек новой секции
SMCResult Config_NewSection(Handle parser, const char[] section, bool quotes)
{
	if (g_iIgnoreLevel)
	{
		g_iIgnoreLevel++;

		return SMCParse_Continue;
	}

	switch(eCurrentSection)
	{
		case Section_None:
		{
			if(strcmp(section, "VIP_GROUPS") == 0)
			{
				eCurrentSection = Section_Groups;
			}
			else
			{
				g_iIgnoreLevel++;
			}
		}
		case Section_Groups:
		{
			g_hGroup.Init();

			strcopy(g_hGroup.Name, sizeof(g_hGroup.Name), section);
			TrimString(g_hGroup.Name);

			eCurrentSection = Section_Group;

			DebugMsg(DBG_INFO, "> Start: %s", g_hGroup.Name);
		}
		default:
		{
			g_iIgnoreLevel++;
		}
	}

	return SMCParse_Continue;
}

// Каллбек нового ключа
SMCResult Config_KeyValue(Handle hParser, char[] sKey, char[] sValue, bool bKeyInQuotes, bool bValueInQuotes)
{
	if (g_iIgnoreLevel)
	{
		return SMCParse_Continue;
	}

	switch(eCurrentSection)
	{
		case Section_Groups:
		{
			// TODO - Добавить наследуемую группу по умолчанию...
			if(strcmp(sKey, "extend_by_default") == 0)
			{
				//g_hGroup.AddExtend(sValue);
			}
		}
		case Section_Group:
		{
			if(strcmp(sKey, "extend") == 0)
			{
				g_hGroup.AddExtend(sValue);
			}
			else
			{
				g_hGroup.AddFeature(sKey, sValue);
			}

			DebugMsg(DBG_INFO, "%s - %s", sKey, sValue);
		}
	}
	
	return SMCParse_Continue;
}

SMCResult Config_EndSection(Handle parser) // Калбек конца секции
{
	if (g_iIgnoreLevel)
	{
		g_iIgnoreLevel--;
		return SMCParse_Continue;
	}

	switch(eCurrentSection)
	{
		case Section_Group:
		{
			eCurrentSection = Section_Groups;
			g_hGroups.PushArray(g_hGroup, sizeof(g_hGroup));
			DebugMsg(DBG_INFO, "> End: %s", g_hGroup.Name);
		}
		case Section_Groups:
		{
			eCurrentSection = Section_None;
		}
	}

	return SMCParse_Continue;
}

// void Config_End(Handle parser, bool halted, bool failed) // Калбек окончания парсера
// {
// 	// Проверяем все ли хорошо
// 	if (failed)
// 	{
// 		// В случае неудачи останавливаем работу плагина
// 		SetFailState("Plugin configuration error");
// 	}
// }

SMCResult Config_CurrentLine(SMCParser hParser, const char[] sLine, int iLineNum)
{
	g_iCurrentLine = iLineNum;
	return SMCParse_Continue;
}