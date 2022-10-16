Статус VIP Core 4.0
UI:
- 90% выполнено 

DB:
- 70% выполнено 

API:
[+] - Реализовано
[-] - Не реализовано
[N] - Новая функция добавлена в новой версии API
[R] - Функция будет удалена в новой версии API
[x] - Функция переработана и может быть неправельная работа в старых модулях

[+] Native VIP_IsClientVIP
[-] Native VIP_GetClientID
[x] Native VIP_GetClientAccessTime
[x] Native VIP_SetClientAccessTime
[x] Native VIP_GetClientVIPGroup
[-] Native VIP_SetClientVIPGroup
[R] Native VIP_GetVIPClientTrie
[-] Native VIP_IsValidVIPGroup
[-] Native VIP_PrintToChatClient
[-] Native VIP_PrintToChatAll
[-] Native VIP_LogMessage
[+] Native VIP_SendClientVIPMenu
[+] Native VIP_GiveClientVIP
[+] Native VIP_RemoveClientVIP
[+] Native VIP_IsVIPLoaded
[+] Native VIP_RegisterFeature
[+] Native VIP_UnregisterFeature
[+] Native VIP_UnregisterMe
[-] Native VIP_IsValidFeature
[-] Native VIP_GetFeatureType
[-] Native VIP_GetFeatureValueType
[-] Native VIP_FillArrayByFeatures
[-] Native VIP_GetClientFeatureStatus
[-] Native VIP_SetClientFeatureStatus
[-] Native VIP_IsClientFeatureUse
[-] Native VIP_GetClientFeatureInt
[-] Native VIP_GetClientFeatureFloat
[-] Native VIP_GetClientFeatureBool
[-] Native VIP_GetClientFeatureString
[-] Native VIP_GiveClientFeature
[-] Native VIP_RemoveClientFeature
[+] Native VIP_GetDatabase
[+] Native VIP_GetDatabaseType
[-] Native VIP_TimeToSeconds
[-] Native VIP_SecondsToTime
[-] Native VIP_GetTimeFromStamp
[-] Native VIP_AddStringToggleStatus
[-] Native VIP_AddStringToggleStatus
[-] Native VIP_CheckClient
[N] Native VIP_GetCurrentVersionInterface
[N] Native VIP_GetClientGroupName
[N] Native VIP_GetClientGroupExpire
[N] Native VIP_GetClientGroupCount
[N] Native VIP_SaveToStorage
[N-] Native VIP_GetGroupIDByName
[N-] Native VIP_NewGroup
[N-] Native VIP_AddFeatureSettingToGroup
[R] Native VIP_RemoveClientVIP2

[+] Forward VIP_OnPlayerSpawn
[-] Forward VIP_OnShowClientInfo
[-] Forward VIP_OnFeatureToggle
[+] Forward VIP_OnVIPLoaded
[-] Forward VIP_OnFeatureRegistered
[-] Forward VIP_OnFeatureUnregistered
[-] Forward VIP_OnClientPreLoad
[-] Forward VIP_OnClientLoaded
[-] Forward VIP_OnVIPClientLoaded
[-] Forward VIP_OnClientDisconnect
[-] Forward VIP_OnVIPClientAdded
[-] Forward VIP_OnVIPClientRemoved
[N] Forward VIP_OnRebuildFeatureList
[N] Forward VIP_OnAddGroup
[N] Forward VIP_OnRemoveGroup