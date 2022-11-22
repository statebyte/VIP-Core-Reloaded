#if defined _vip_core_included
 #endinput
#endif
#define _vip_core_included

#define VIP_INTERFACE_VERSION			400

#define VIP_FEATURENAME_LENGTH			64
#define VIP_FEATUREVALUE_LENGTH			128
#define VIP_GROUPNAME_LENGTH			32

/* ====================
======= TYPES =======
==================== */

/* Тип базы данных */
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


/* ====================
====== NATIVES ======
==================== */

// Global

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
 *	Получает номер версии интерфейса ядра
 *
 * @noparams
 *
 * @return					int VIP_INTERFACE_VERSION
*/
native int VIP_GetCurrentVersionInterface();

// Database

/**
 *	Получает текущие подключение к БД.
 *
 * @noparams
 *
 * @noreturn
*/
native Database VIP_GetDatabase();

/**
 *	Получает тип базы данных
 *
 * @noparams
 *
 * @noreturn
*/
native VIP_DatabaseUsage VIP_GetDatabaseType();

// Features

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
 *	Проверяет существование функции.
 *
 * @param szFeature			Уникальное имя ф-и.
 *
 * @return					true - VIP-функция существует.
 * 							false - VIP-функция не существует.
*/
native bool VIP_IsValidFeature(const char[] szFeature);

/**
 *	Получает тип функции.
 *
 * @param szFeature			Уникальное имя ф-и.
 *
 * @return					Возвращает элемент списка VIP_FeatureType.
*/
native VIP_FeatureType VIP_GetFeatureType(const char[] szFeature);

/**
 *	Получает тип значения функции.
 *
 * @param szFeature			Уникальное имя ф-и.
 *
 * @return					Возвращает элемент списка VIP_ValueType.
*/
native VIP_ValueType VIP_GetFeatureValueType(const char[] szFeature);

/**
 *	Заполняет adt массив ф-ями.
 *
 * @param hArray			Массив типа ArrayList.
 *
 * @return					Количество добавленных элементов.
*/
native int VIP_FillArrayByFeatures(ArrayList hArray);

// Groups
/**
 *	Проверяет наличие группы.
 *
 * @param szGroup			Имя группы.
 *
 * @return					true - группа существует.
 * 							false - группа не существует.
*/	
native bool VIP_IsGroupExists(const char[] szGroup);

/**
 *	Добавляет VIP группу
 *
 * @param szGroup			Имя группы.
 *
 * @return					Индекс добавленной группы (-1 группа уже добавлена)
*/	
native int VIP_AddGroup(const char[] szGroup);

/**
 *	Удаляет VIP группу
 *
 * @param szGroup			Имя группы.
 *
 * @return					true - группа успешно удалена
*/	
native bool VIP_RemoveGroup(const char[] szGroup);

/**
 *	Добавлет функцию в VIP группу
 *
 * @param szGroup			Имя группы
 * @param szFeature			Имя функции
 * @param szValue			Значение функции
 *
 * @return					true - Успешно добавлено
*/	
native bool VIP_GroupAddFeature(const char[] szGroup, const char[] szFeature, const char[] szValue);

/**
 *	Удаляет функцию в VIP группе
 *
 * @param szGroup			Имя группы
 * @param szFeature			Имя функции
 *
 * @return					true - Успешно добавлено
*/	
native bool VIP_GroupRemoveFeature(const char[] szGroup, const char[] szFeature);

/**
 *	Получает GroupID из названия группы.
 *
 * @param szGroup			Название группы
 *
 * @return					Индекс группы (GroupID)
*/
native int VIP_GetGroupIDByName(char[] szGroup);

/**
 *	Заполняет adt массив VIP группами
 *
 * @param hArray			Массив типа ArrayList.
 *
 * @return					Количество добавленных элементов.
*/
native int VIP_FillArrayByGroups(ArrayList hArray);

// Clients

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

/**
 *	Получает уникальный ID VIP-игрока.
 *
 * @param iClient			Индекс игрока.
 *
 * @return					Уникальный ID или -1 если временный.
*/
native int VIP_GetClientID(int iClient);

/**
 *	Запускает проверку игрока на наличие VIP прав.
 *
 * @param iClient			Индекс игрока.
 * @param bNotify			Известить ли игрока о результате проверки.
 * @param bForward			Вызывать ли форврад VIP_OnClientPreLoad перед проверкой.
 *
 * @noreturn
*/
native void VIP_CheckClient(int iClient, bool bNotify = false, bool bForward = true);

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
 *	Выдает игроку VIP группу.
 *
 * @param iAdmin			Индекс админа (0 - сервер, -1 - плагин).
 * @param iClient			Индекс игрока.
 * @param iTime				Время в секундах.
 * @param szGroup			Имя VIP-группы.
 * @param bAddToDB			Добавлять ли в базу данных.
 *
 * @noreturn
*/
native void VIP_GiveClientGroup(int iAdmin = -1, int iClient, int iTime, const char[] szGroup, bool bAddToDB = true);

/**
 *	Отнимает у игрока VIP группу.
 *
 * @param iAdmin			Индекс админа (0 - сервер, -1 - плагин).
 * @param iClient			Индекс игрока.
 * @param bInDB				Удалять ли из базы данных.
 * @param bNotify			Уведомление игрока (true - уведомить/false - не уведомлять).
 *
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native void VIP_RemoveClientGroup(int iAdmin = -1, int iClient, const char[] szGroup, bool bAddToDB = true, bool bNotify = false);

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
 *	Возвращает статус VIP-функции у игрока.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *
 * @return					Возвращает элемент списка VIP_ToggleState.
*/
native VIP_ToggleState VIP_GetClientFeatureStatus(int iClient, const char[] szFeature);

/**
 *	Устанавливает статус VIP-функции игроку.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param eStatus			Статус VIP-функции.
 * @param bCallback			Вызывать ли toggle каллбэк.
 * @param bSave				Сохранить ли в куки.
 *
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_SetClientFeatureStatus(int iClient, const char[] szFeature, VIP_ToggleState eStatus, bool bCallback = true, bool bSave = false);


/**
 *	Возвращает статус VIP-функции у игрока.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *
 * @return					true - VIP-функции включена.
 * 							false - VIP-функции выключена или нет доступа.
*/
native bool VIP_IsClientFeatureUse(int iClient, const char[] szFeature);

/**
 *	Получает целочисленное значение параметра VIP-функции у игрока.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *
 * @return					Возвращает целочисленное значение параметра VIP-функции у игрока.
*/
native int VIP_GetClientFeatureInt(int iClient, const char[] szFeature);

/**
 *	Получает логическое значение параметра VIP-функции у игрока.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *
 * @return					Возвращает логическое значение параметра VIP-функции у игрока (true/false).
*/
native bool VIP_GetClientFeatureBool(int iClient, const char[] szFeature);


/**
 *	Получает дробное значение параметра VIP-функции у игрока.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *
 * @return					Возвращает дробное значение параметра VIP-функции у игрока.
*/
native float VIP_GetClientFeatureFloat(int iClient, const char[] szFeature);

/**
 *	Получает строчное значение параметра VIP-функции у игрока.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param szBuffer			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 *
 * @noreturn
*/
native bool VIP_GetClientFeatureString(int iClient, const char[] szFeature, char[] szBuffer, int iMaxLength);

/**
 *	Выдает игроку VIP-функцию и устанавливает её значение (на время сессии).
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param szValue			Значение (автоматически будет приведено к типу ф-и).
 *
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_GiveClientFeature(int iClient, const char[] szFeature, const char[] szValue, bool bSaveDB = false);

/**
 *	Отнимает у VIP-игрока VIP-функцию (на время сессии).
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 *
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_RemoveClientFeature(int iClient, const char[] szFeature, bool bSaveDB = false);

/**
 *  Сохраняет значение в хранилище игрока (сохраняется при переподключении)
 *
 * @param iClient			Индекс игрока.
 * @param szKey				Ключ
 * @param szValue			Значение
 *
 * @noreturn
*/
native void VIP_SaveClientStorageValue(int iClient, const char[] szKey, const char[] szValue);

/**
 *	Получает значение из хранилища игрока
 *
 * @param szKey				Ключ
 * @param szValue			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 *
 * @return					true - Данные получены
 * 							false - Данные отсуствуют
*/
native bool VIP_GetClientStorageValue(int iClient, const char[] szKey, char[] szValue, int iMaxLength);


// Helpers

/**
 *	Записывает сообщение в лог.
 *
 * @param szMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *
 * @noreturn
*/
native void VIP_LogMessage(const char[] szMessage, any ...);

/**
 *	Выводит игроку сообщение в чат с приставкой (фраза в переводе "VIP_CHAT_PREFIX").
 *
 * @param iClient			Индекс игрока.
 * @param szMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *
 * @noreturn
*/
native void VIP_PrintToChatClient(int iClient, const char[] szMessage, any ...);

/**
 *	Выводит всем игрокам сообщение в чат с приставкой (фраза в переводе "VIP_CHAT_PREFIX").
 *
 * @param szMessage			Правила форматирования сообщение.
 * @param ...				Параметры форматирования.
 *
 * @noreturn
*/
native void VIP_PrintToChatAll(const char[] szMessage, any ...);

/**
 *	Переводит секунды в человекопонятный вид.
 *
 * @param szBuffer			Буфер, в который будет помещен результат.
 * @param iMaxLength		Размер буфера.
 * @param iTimeStamp		Кол-во секунд.
 * @param iClient			Индекс игрока или LANG_SERVER.
 *
 * @return					true - Успешно.
 * 							false - Не удалось выполнить.
*/
native bool VIP_GetTimeFromStamp(char[] szBuffer, int iMaxLength, int iTimeStamp, int iClient = LANG_SERVER);

/**
 *	Получает время в секундах в зависимости от sm_vip_time_mode.
 *
 * @param iTime				Время.
 *
 * @return					Возвращает количество секунд в зависимости от sm_vip_time_mode.
*/
native int VIP_TimeToSeconds(int iTime);

/**
 *	Получает время в зависимости от sm_vip_time_mode.
 *
 * @param iTime				Количество секунд.
 *
 * @return					Возвращает время в зависимости от sm_vip_time_mode.
*/
native int VIP_SecondsToTime(int iTime);


// TODO
/**
 *	Добавляет новую функцию в группу
 *
 * @param sGroup			Название группы
 *
 * @return					Индекс новой группы (GroupID)
*/
//native int VIP_AddFeatureSettingToGroup(int iGroupID, char[] sKey, char[] sValue);

/* ====================
====== FORWARDS ======
==================== */

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
 *	Вызывается когда добавлена новая VIP-группа игроку
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnClientGroupAdded(int iClient, char[] szGroup);

/**
 *	Вызывается когда удалена VIP-группа у игрока
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnClientGroupRemoved(int iClient, char[] szGroup);

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
 *	Вызывается когда у VIP-игрока изменяется статус функции.
 *
 * @param iClient			Индекс игрока.
 * @param szFeature			Уникальное имя ф-и.
 * @param eOldStatus		Старое значение статуса.
 * @param eNewStatus		Новое значение статуса.
 *
 * @return					Plugin_Stop или Plugin_Handled  - остановит переключение статуса;
 * 							Plugin_Continue  - разрешит переключение статуса без изменений;
 * 							Plugin_Changed - разрешит переключение статуса на eNewStatus.
*/
forward Action VIP_OnFeatureToggle(int iClient, const char[] szFeature, VIP_ToggleState eOldStatus, VIP_ToggleState &eNewStatus);

/**
 *	Вызывается когда VIP-функция была зарегистрирована.
 *
 * @param szFeature			Уникальное имя ф-и.
 *
 * @noreturn
*/
forward void VIP_OnFeatureRegistered(const char[] szFeature);

/**
 *	Вызывается когда VIP-функция была удалена.
 *
 * @param szFeature			Уникальное имя ф-и.
 *
 * @noreturn
*/
forward void VIP_OnFeatureUnregistered(const char[] szFeature);

/**
 *	Вызывается когда игрок был загружен.
 *
 * @param iClient			Индекс игрока.
 * @param bIsVIP			Имеет ли игрок VIP-статус.
 *
 * @noreturn
*/
forward void VIP_OnClientLoaded(int iClient, bool bIsVIP);

/**
 *	Вызывается когда VIP-игрок был загружен.
 *
 * @param iClient			Индекс игрока.
 *
 * @noreturn
*/
forward void VIP_OnVIPClientLoaded(int iClient);

/**
 *	Вызывается когда игрок на стадии отключения.
 *
 * @param iClient			Индекс игрока.
 * @param bIsVIP			Имеет ли игрок VIP-статус.
 *
 * @noreturn
*/
forward void VIP_OnClientDisconnect(int iClient, bool bIsVIP);

/**
 *	Вызывается когда у VIP-игрока обновилось хранилище данных
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnStorageUpdate(int iClient, char[] szFeature);

/**
 *	Вызывается перед проверкой игрока на наличие VIP-статуса.
 *
 * @param iClient			Индекс игрока.
 *
 * @return					true - продолжить.
 * 							false - не выполнять проверку.
*/
forward bool VIP_OnClientPreLoad(int iClient);

/**
 *	Вызывается когда VIP-плагин загрузил настройки.
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnConfigsLoaded();

/**
 *	Вызывается когда была добавлена VIP группа
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnAddGroup(const char[] szGroup);

/**
 *	Вызывается когда была удалена VIP группа
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnRemoveGroup(const char[] szGroup);

// TODO: VIP_OnShowClientInfo

/* ====================
======= STOCKS ======
==================== */

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

// Начиная с 4.0
enum struct VIP_Feature
{
	char Name[VIP_FEATURENAME_LENGTH];

	void Register(	VIP_ValueType			eValType				= VIP_NULL,
					VIP_FeatureType			eType					= TOGGLABLE,
					ItemSelectCallback		Item_select_callback	= INVALID_FUNCTION,
					ItemDisplayCallback		Item_display_callback	= INVALID_FUNCTION,
					ItemDrawCallback		Item_draw_callback		= INVALID_FUNCTION,
					VIP_ToggleState			eDefStatus				= NO_ACCESS,
					bool					bCookie					= false)
	{
		VIP_RegisterFeature(this.Name, eValType, eType, Item_select_callback, Item_display_callback, Item_draw_callback, eDefStatus, bCookie);
	}

	void UnRegister()
	{
		VIP_UnregisterFeature(this.Name);
	}

	bool GetString(int iClient, char[] sBuffer, int iMaxLen)
	{
		return VIP_GetClientFeatureString(iClient, this.Name, sBuffer, iMaxLen);
	}

	int GetInt(int iClient)
	{
		return VIP_GetClientFeatureInt(iClient, this.Name);
	}

	float GetFloat(int iClient)
	{
		return VIP_GetClientFeatureFloat(iClient, this.Name);
	}

	bool GetBool(int iClient)
	{
		return VIP_GetClientFeatureBool(iClient, this.Name);
	}

	bool IsUse(int iClient)
	{
		return VIP_IsClientFeatureUse(iClient, this.Name);
	}

	VIP_ToggleState GetStatus(int iClient)
	{
		return VIP_GetClientFeatureStatus(iClient, this.Name);
	}

	bool SetStatus(int iClient, VIP_ToggleState eStatus, bool bCallback = true, bool bSave = false)
	{
		return VIP_SetClientFeatureStatus(iClient, this.Name, eStatus, bCallback, bSave);
	}

	bool SetInt(int iClient, int iValue, bool bSaveDB = false)
	{
		char sBuf[4];
		IntToString(iValue, sBuf, sizeof(sBuf));
		return VIP_GiveClientFeature(iClient, this.Name, sBuf, bSaveDB);
	}

	bool SetBool(int iClient, bool bValue, bool bSaveDB = false)
	{
		char sBuf[4];
		IntToString(bValue, sBuf, sizeof(sBuf));
		return VIP_GiveClientFeature(iClient, this.Name, sBuf, bSaveDB);
	}

	bool SetFloat(int iClient, float fValue, bool bSaveDB = false)
	{
		char sBuf[4];
		FloatToString(fValue, sBuf, sizeof(sBuf));
		return VIP_GiveClientFeature(iClient, this.Name, sBuf, bSaveDB);
	}

	bool SetString(int iClient, char[] sValue, bool bSaveDB = false)
	{
		return VIP_GiveClientFeature(iClient, this.Name, sValue, bSaveDB);
	}

	void Remove(int iClient, bool bSaveDB = false)
	{
		VIP_RemoveClientFeature(iClient, this.Name, bSaveDB)
	}
}

enum struct VIP_Storage
{
	char Name[VIP_FEATURENAME_LENGTH];

	void SaveInt(int iClient, int iValue)
	{
		char sBuf[4];
		IntToString(iValue, sBuf, sizeof(sBuf));
		VIP_SaveClientStorageValue(iClient, this.Name, sBuf);
	}

	void SaveFloat(int iClient, float fValue)
	{
		char sBuf[4];
		FloatToString(fValue, sBuf, sizeof(sBuf));
		VIP_SaveClientStorageValue(iClient, this.Name, sBuf);
	}

	void SaveBool(int iClient, bool bValue)
	{
		char sBuf[4];
		IntToString(bValue, sBuf, sizeof(sBuf));
		VIP_SaveClientStorageValue(iClient, this.Name, sBuf);
	}

	void SaveString(int iClient, char[] sBuffer)
	{
		VIP_SaveClientStorageValue(iClient, this.Name, sBuffer);
	}

	bool GetString(int iClient, char[] sBuffer, int iMaxLen)
	{
		return VIP_GetClientStorageValue(iClient, this.Name, sBuffer, iMaxLen);
	}

	int GetInt(int iClient, char[] sBuffer, int iMaxLen)
	{
		char sBuf[4];

		if(VIP_GetClientStorageValue(iClient, this.Name, sBuf, sizeof(sBuf)))
		{
			return StringToInt(sBuf);
		}

		return 0;
	}

	bool GetBool(int iClient, char[] sBuffer, int iMaxLen)
	{
		char sBuf[4];

		if(VIP_GetClientStorageValue(iClient, this.Name, sBuf, sizeof(sBuf)))
		{
			return StringToInt(sBuf) == 1 ? true : false;
		}

		return false;
	}

	float GetFloat(int iClient, char[] sBuffer, int iMaxLen)
	{
		char sBuf[4];

		if(VIP_GetClientStorageValue(iClient, this.Name, sBuf, sizeof(sBuf)))
		{
			return StringToFloat(sBuf);
		}

		return 0.0;
	}
}

// Depracated
#pragma deprecated Use VIP_IsGroupExists() instead
native bool VIP_IsValidVIPGroup(const char[] szGroup);

/**
 *	Выдает игроку VIP группу.
 *
 * @param iAdmin			Индекс админа (0 - сервер, -1 - плагин).
 * @param iClient			Индекс игрока.
 * @param iTime				Время в секундах.
 * @param szGroup			Имя VIP-группы.
 * @param bAddToDB			Добавлять ли в базу данных.
 *
 * @noreturn
*/
//#pragma deprecated Use VIP_GiveClientGroup() instead
//native void VIP_GiveClientVIP(int iAdmin = -1, int iClient, int iTime, const char[] szGroup, bool bAddToDB = true);
//#pragma deprecated Use VIP_GiveClientVIP() instead
//native bool VIP_SetClientVIP(int iClient, int iTime, any AuthType, const char[] szGroup, bool bAddToDB = true);

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
//#pragma deprecated Use VIP_RemoveClientGroup() instead
//native bool VIP_RemoveClientVIP2(int iAdmin = -1, int iClient, bool bInDB, bool bNotify);
//#pragma deprecated Use VIP_RemoveClientVIP2() instead
//native bool VIP_RemoveClientVIP(int iClient, bool bInDB, bool bNotify);

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
	// Global
	MarkNativeAsOptional("VIP_IsVIPLoaded");
	MarkNativeAsOptional("VIP_GetCurrentVersionInterface");

	// Database
	MarkNativeAsOptional("VIP_GetDatabase");
	MarkNativeAsOptional("VIP_GetDatabaseType");

	// Features
	MarkNativeAsOptional("VIP_RegisterFeature");
	MarkNativeAsOptional("VIP_UnregisterFeature");
	MarkNativeAsOptional("VIP_UnregisterMe");
	MarkNativeAsOptional("VIP_IsValidFeature");
	MarkNativeAsOptional("VIP_GetFeatureType");
	MarkNativeAsOptional("VIP_GetFeatureValueType");
	MarkNativeAsOptional("VIP_FillArrayByFeatures");
	
	// Groups
	MarkNativeAsOptional("VIP_IsGroupExists");
	MarkNativeAsOptional("VIP_IsValidVIPGroup");
	MarkNativeAsOptional("VIP_AddGroup");
	MarkNativeAsOptional("VIP_RemoveGroup");
	MarkNativeAsOptional("VIP_GroupAddFeature");
	MarkNativeAsOptional("VIP_GroupRemoveFeature");
	MarkNativeAsOptional("VIP_GetGroupIDByName");
	MarkNativeAsOptional("VIP_FillArrayByGroups");
	

	// Clients
	MarkNativeAsOptional("VIP_IsClientVIP");
	MarkNativeAsOptional("VIP_GetClientID");
	MarkNativeAsOptional("VIP_CheckClient");

	MarkNativeAsOptional("VIP_GetClientGroupName");
	MarkNativeAsOptional("VIP_GetClientGroupExpire");
	MarkNativeAsOptional("VIP_GetClientGroupCount");

	MarkNativeAsOptional("VIP_GetClientVIPGroup");

	MarkNativeAsOptional("VIP_GiveClientGroup");
	MarkNativeAsOptional("VIP_RemoveClientGroup");

	MarkNativeAsOptional("VIP_SendClientVIPMenu");

	MarkNativeAsOptional("VIP_GetClientFeatureStatus");
	MarkNativeAsOptional("VIP_SetClientFeatureStatus");

	MarkNativeAsOptional("VIP_IsClientFeatureUse");
	MarkNativeAsOptional("VIP_GetClientFeatureInt");
	MarkNativeAsOptional("VIP_GetClientFeatureBool");
	MarkNativeAsOptional("VIP_GetClientFeatureFloat");
	MarkNativeAsOptional("VIP_GetClientFeatureString");

	MarkNativeAsOptional("VIP_GiveClientFeature");
	MarkNativeAsOptional("VIP_RemoveClientFeature");

	// Storage
	MarkNativeAsOptional("VIP_SaveClientStorageValue");
	MarkNativeAsOptional("VIP_GetClientStorageValue");

	// Helpers
	MarkNativeAsOptional("VIP_LogMessage");
	MarkNativeAsOptional("VIP_PrintToChatClient");
	MarkNativeAsOptional("VIP_PrintToChatAll");
	//MarkNativeAsOptional("VIP_AddStringToggleStatus");
	MarkNativeAsOptional("VIP_GetTimeFromStamp");
	MarkNativeAsOptional("VIP_TimeToSeconds");
	MarkNativeAsOptional("VIP_SecondsToTime");
}
#endif