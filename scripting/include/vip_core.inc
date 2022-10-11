#if defined _vip_core_included
 #endinput
#endif
#define _vip_core_included

#define VIP_INTERFACE_VERSION			0400

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
 *	Вызывается когда VIP-плагин загрузился.
 *
 * @noparams
 *
 * @noreturn
*/
forward void VIP_OnVIPLoaded();

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
	MarkNativeAsOptional("VIP_RegisterFeature");
	MarkNativeAsOptional("VIP_UnregisterFeature");
	MarkNativeAsOptional("VIP_UnregisterMe");
	MarkNativeAsOptional("VIP_GetCurrentVersionInterface");
}
#endif