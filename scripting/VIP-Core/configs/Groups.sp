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
}

// SMC Parser
bool LoadGroupsConfig()
{
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

	RebuildFeatureList();

	PrintToServer("%i", g_iCurrentLine);

	return true;
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
			if(strcmp(section, "Groups") == 0)
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

			PrintToServer("> Start: %s", section);

			eCurrentSection = Section_Group;
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
			if(strcmp(sKey, "extend_by_default") == 0)
			{
				//g_hGroup.AddExtend(sValue);
			}
		}
		case Section_Group:
		{
			PrintToServer("%s - %s", sKey, sValue);
			if(strcmp(sKey, "extend") == 0)
			{
				g_hGroup.AddExtend(sValue);
			}
			else
			{
				g_hGroup.AddFeature(sKey, sValue);
			}
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
			PrintToServer("> End: %s", g_hGroup.Name);
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