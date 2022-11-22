## Release Notes

## [4.0.0]

### API:
[+] - Реализовано  
[-] - Не реализовано  
[N] - Новая функция добавлена в новой версии API  
[R] - Функция будет удалена в новой версии API  
[x] - Функция переработана и может быть неправельная работа в старых модулях  

- Natives:  
[+] Native VIP_CheckClient  
[+] Native VIP_IsClientVIP  
[+] Native VIP_GetClientID  
[R] Native VIP_GetClientAccessTime  
[R] Native VIP_SetClientAccessTime  
[x] Native VIP_GetClientVIPGroup  
[R] Native VIP_SetClientVIPGroup  
[+] Native VIP_IsGroupExists  
[+] Native VIP_IsValidVIPGroup  
[+] Native VIP_AddGroup  
[+] Native VIP_RemoveGroup  
[+] Native VIP_PrintToChatClient  
[+] Native VIP_PrintToChatAll  
[+] Native VIP_LogMessage  
[+] Native VIP_SendClientVIPMenu  
[R] Native VIP_GiveClientVIP  
[N] Native VIP_GiveClientGroup  
[R] Native VIP_SetClientVIP  
[R] Native VIP_RemoveClientVIP  
[N] Native VIP_RemoveClientGroup  
[+] Native VIP_IsVIPLoaded  
[+] Native VIP_RegisterFeature  
[+] Native VIP_UnregisterFeature  
[+] Native VIP_UnregisterMe  
[+] Native VIP_IsValidFeature  
[+] Native VIP_GetFeatureType  
[+] Native VIP_GetFeatureValueType  
[+] Native VIP_FillArrayByFeatures  
[+] Native VIP_GetClientFeatureStatus  
[+] Native VIP_SetClientFeatureStatus  
[+] Native VIP_IsClientFeatureUse  
[+] Native VIP_GetClientFeatureInt  
[+] Native VIP_GetClientFeatureFloat  
[+] Native VIP_GetClientFeatureBool  
[+] Native VIP_GetClientFeatureString  
[+] Native VIP_GiveClientFeature  
[+] Native VIP_RemoveClientFeature  
[R] Native VIP_SetClientStorageValue  
[N] Native VIP_SaveClientStorageValue  
[+] Native VIP_GetClientStorageValue  
[+] Native VIP_GetDatabase  
[+] Native VIP_GetDatabaseType  
[+] Native VIP_TimeToSeconds  
[+] Native VIP_SecondsToTime  
[+] Native VIP_GetTimeFromStamp  
[-] Native VIP_AddStringToggleStatus  
[N] Native VIP_GiveClientGroup  
[N] Native VIP_GetCurrentVersionInterface  
[N] Native VIP_GetClientGroupName  
[N] Native VIP_GetClientGroupExpire  
[N] Native VIP_GetClientGroupCount  
[N-] Native VIP_GetGroupIDByName  
[N-] Native VIP_AddFeatureSettingToGroup // Добавляет функцию в существующую группу  
[N-] Native VIP_IsEnabledClientFeature  
[R] Native VIP_GetVIPClientTrie  
[R] Native VIP_RemoveClientVIP2  

- Forawrds:  
[+] Forward VIP_OnPlayerSpawn  
[-] Forward VIP_OnShowClientInfo  
[R] Forward VIP_OnClientStorageLoaded  
[+] Forward VIP_OnFeatureToggle  
[+] Forward VIP_OnVIPLoaded  
[+] Forward VIP_OnConfigsLoaded  
[+] Forward VIP_OnFeatureRegistered  
[+] Forward VIP_OnFeatureUnregistered  
[+] Forward VIP_OnClientPreLoad  
[+] Forward VIP_OnClientLoaded   // Гарантирует загрузку Storage - VIP_OnClientStorageLoaded  
[+] Forward VIP_OnVIPClientLoaded  
[+] Forward VIP_OnClientDisconnect  
[R] Forward VIP_OnVIPClientAdded  
[R] Forward VIP_OnVIPClientRemoved  
[N] Forward VIP_OnRebuildFeatureList  
[N] Forward VIP_OnAddGroup  
[N] Forward VIP_OnRemoveGroup  
[N] Forward VIP_OnStorageUpdate 
