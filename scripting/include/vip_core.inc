#if defined _vip_core_included
 #endinput
#endif
#define _vip_core_included

#define VIP_INTERFACE_VERSION			400

// Тип базы данных...
enum VIP_DatabaseUsage
{
	DB_None = 0,
	DB_SQLite,
	DB_MySQL,
	DB_Postgre // TODO
}

/* Типы данных VIP-функций */
enum VIP_ValueType
{
	VIP_NULL	= 0,	// Нет данных
	INT,				// Целочисленный тип
	FLOAT,				// Числа с плавающей точкой (Дробные)
	BOOL,				// Логический тип (1/0)
	STRING				// Строчный тип
}

/* Статусы VIP-функций */
enum VIP_ToggleState
{
	DISABLED = 0,		// Выключено
	ENABLED,			// Включено
	NO_ACCESS			// Нет доступа
}

/* Типы VIP-функций */
enum VIP_FeatureType
{
	TOGGLABLE = 0,		// Вкл/Выкл в меню
	SELECTABLE,			// Только нажатие
	HIDE				// Скрытый
}

typeset ItemSelectCallback
{
	/**
	 *	Вызывается когда VIP-игрок нажимает на пункт в меню (для типа TOGGLABLE).
	 *
	 * @param iClient			Индекс игрока.
	 * @param szFeature			Уникальное имя ф-и.
	 * @param eOldStatus		Старое значение статуса.
	 * @param eNewStatus		Новое значение статуса.
	 *
	 * @return					Plugin_Stop или Plugin_Handled - остановит переключение статуса;
	 *							Plugin_Continue - разрешит переключение статуса без изменений;
	 *							Plugin_Changed - разрешит переключение статуса на eNewStatus.
	*/
	function Action (int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState &eNewStatus);

	/**
	 *	Вызывается когда VIP-игрок нажимает на пункт в меню (для типа SELECTABLE).
	 *
	 * @param iClient			Индекс игрока.
	 * @param szFeature			Уникальное имя ф-и.
	 *
	 * @return					true - снова откроет игроку VIP-меню;
	 * 							false.
	*/
	function bool (int iClient, const char[] szFeature);
};

/**
 *	Вызывается когда VIP-игроку отображается пункт в меню.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param szDisplay			Буфер.
 * @param iMaxLength		Размер буфера.
 *
 * @return					true - Отображение содержимого szDisplay.
 * 							false - Отображение без изменений.
*/
typedef ItemDisplayCallback = function bool (int iClient, const char[] szFeature, char[] szDisplay, int iMaxLength);

/**
 *	Вызывается когда VIP-игроку отображается стиль пункта в меню.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param iStyle			Стиль.
 *
 * @return					Необходимый стиль (ITEMDRAW_*).
*/
typedef ItemDrawCallback = function int (int iClient, const char[] szFeature, int iStyle);


native void VIP_RegisterFeature(const char[]			szFeature,
								VIP_ValueType			eValType				= VIP_NULL,
								VIP_FeatureType			eType					= TOGGLABLE,
								ItemSelectCallback		Item_select_callback	= INVALID_FUNCTION,
								ItemDisplayCallback		Item_display_callback	= INVALID_FUNCTION,
								ItemDrawCallback		Item_draw_callback		= INVALID_FUNCTION,
								VIP_ToggleState			eDefStatus				= NO_ACCESS,
								bool					bCookie					= false);

/**
 *	Удаляет VIP-функцию.
 *
 * @param szFeature				Уникальное имя ф-и.
 *
 * @noreturn
*/
native void VIP_UnregisterFeature(const char[] szFeature);

/**
 *	Удаляет все VIP-функции зарегистрированные плагином (вызывать в OnPluginEnd()).
 *
 * @noparams
 *
 * @noreturn
*/
native void VIP_UnregisterMe();

/**
 *	Проверка что ядро загружено и готово к регистрации функций.
 *
 * @noparams
 *
 * @return					true - Ядро загружено.
 * 							false - Ядро не загружено.
*/
native bool VIP_IsVIPLoaded();

/**
 *	Получает номер версии ядра
 *
 * @noparams
 *
 * @return					int VIP_INTERFACE_VERSION
*/
native int VIP_GetCurrentVersionInterface();

/**
 *	Получает VIP-группу игрока. (OLD)
 *
 * @param iClient			Индекс игрока.
 * @param szGroup			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 *
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
#pragma deprecated Use VIP_GetClientGroupName() instead
native bool VIP_GetClientVIPGroup(int iClient, char[] szGroup, int iMaxLength);

/**
 *	Получает VIP-группу игрока.
 *
 * @param iClient			Индекс игрока.
 * @param szGroup			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 * @param iIndex			Номер группы в массиве...
 *
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_GetClientGroupName(int iClient, char[] szGroup, int iMaxLength, int iIndex = 0);

/**
 *	Получает время до окончания VIP-группы в unix
 *
 * @param iClient			Индекс игрока.
 * @param iIndex			Номер группы в массиве...
 *
*/
native int VIP_GetClientGroupExpire(int iClient, int iIndex = 0);


/**
 *	Получает кол-во VIP-групп у игрока.
 *
 * @param iClient			Индекс игрока.
 *
 * @return					Кол-во групп в int
*/
native int VIP_GetClientGroupCount(int iClient);

/**
 *	Выдает игроку VIP-права.
 *
 * @param iAdmin			Индекс админа (0 - сервер, -1 - плагин).
 * @param iClient			Индекс игрока.
 * @param iTime				Время в секундах.
 * @param szGroup			Имя VIP-группы.
 * @param bAddToDB			Добавлять ли в базу данных.
 *
 * @noreturn
*/
native void VIP_GiveClientVIP(int iAdmin = -1, int iClient, int iTime, const char[] szGroup, bool bAddToDB = true);

/**
 *	Отнимает у игрока VIP-права.
 *
 * @param iAdmin			Индекс админа (0 - сервер, -1 - плагин).
 * @param iClient			Индекс игрока.
 * @param bInDB				Удалять ли из базы данных.
 * @param bNotify			Уведомление игрока (true - уведомить/false - не уведомлять).
 *
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_RemoveClientVIP(int iAdmin = -1, int iClient, const char[] szGroup, bool bInDB, bool bNotify);

/**
 *	Получает наличие VIP прав у игрока.
 *	Если у игрока будет хотя бы одна функция, то у него есть VIP статус.
 *
 * @param iClient			Индекс игрока.
 *
 * @return					true - У игрока имеются VIP-статус.
 * 							false - У игрока нет VIP-статуса.
*/
native bool VIP_IsClientVIP(int iClient);

// TODO
/**
 *	Добавляет новую группу в список
 *
 * @param sGroup			Название группы
 *
 * @return					Индекс новой группы (GroupID)
*/
//native int VIP_NewGroup(char[] sGroup);

/**
 *	Добавляет новую функцию в группу
 *
 * @param sGroup			Название группы
 *
 * @return					Индекс новой группы (GroupID)
*/
//native int VIP_AddFeatureSettingToGroup(int iGroupID, char[] sKey, char[] sValue);

/**
 *	Получает GroupID из названия группы.
 *
 * @param sGroup			Название группы
 *
 * @return					Индекс новой группы (GroupID)
*/
//native int VIP_GetGroupIDByName(char[] sKey);


/**
 *	Получает текущие подключение к БД.
 *
 * @noparams
 *
 * @noreturn
*/
native Database VIP_GetDatabase();

/**
 *	Отправляет игроку VIP-меню.
 *
 * @param iClient			Индекс игрока.
 * @param bSelection		Режим открытия:
 * 							true - на первой странице;
 * 							false - на странице последнего выбранного пункта.
 *
 * @noreturn
*/
native void VIP_SendClientVIPMenu(int iClient, bool bSelection = false);

/**
 *	Вызывается когда VIP-плагин загрузился.
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnVIPLoaded();

/**
 *	Вызывается когда у VIP-игрока обновился список функций
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnRebuildFeatureList(int iClient);

/**
 *	Вызывается когда добавлена новая VIP-группа игрока
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnAddGroup(int iClient, char[] szGroup);

/**
 *	Вызывается когда удалена VIP-группа игрока
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnRemoveGroup(int iClient, char[] szGroup);

/**
 *	Вызывается когда игрок возрождается.
 *
 * @param iClient			Индекс игрока.
 * @param iTeam				Команда игрока (2 - Т, 3- КТ).
 * @param bIsVIP			Имеет ли игрок VIP-статус.
 *
 * @noreturn
*/
forward void VIP_OnPlayerSpawn(int iClient, int iTeam, bool bIsVIP);

/**
 *	Формирует путь к файлу с настройками модуля.
 *
 * @param szBuffer			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 * @param szFileName		Имя файла.
 *
 * @noreturn
*/
stock void VIP_BuildModulesPath(char[] szBuffer, int iMaxLen, const char[] szFileName)
{
	BuildPath(Path_SM, szBuffer, iMaxLen, "data/vip/modules/%s", szFileName);
}

/**
 * Проверяет что VIP ядро доступно без ThrowNativeError
 * 
 * @return     Return description
 */
stock bool IsVipCoreAvailable()
{
	return CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available;
}

public SharedPlugin __pl_vip_core= 
{
	name = "vip_core",
	file = "VIP_Core.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_vip_core_SetNTVOptional()
{
	MarkNativeAsOptional("VIP_IsVIPLoaded");
	MarkNativeAsOptional("VIP_GetCurrentVersionInterface");

	MarkNativeAsOptional("VIP_RegisterFeature");
	MarkNativeAsOptional("VIP_UnregisterFeature");
	MarkNativeAsOptional("VIP_UnregisterMe");
	
	MarkNativeAsOptional("VIP_GetClientVIPGroup");
	MarkNativeAsOptional("VIP_GetClientGroupName");
	MarkNativeAsOptional("VIP_GetClientGroupCount");
	
	MarkNativeAsOptional("VIP_IsClientVIP");

	MarkNativeAsOptional("VIP_GetDatabase");

	MarkNativeAsOptional("VIP_SendClientVIPMenu");
	
}
#endif