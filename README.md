<div align="center">
  <h1><code>VIP-Core-Reloaded</code></h1>
  <p>
    <strong>AKA 4.0 PRO</strong>
  </p>
  <p style="margin-bottom: 0.5ex;">
    <img
        src="https://img.shields.io/github/downloads/theelsaud/VIP-Core-Reloaded/total"
    />
    <img
        src="https://img.shields.io/github/last-commit/theelsaud/VIP-Core-Reloaded"
    />
    <img
        src="https://img.shields.io/github/issues/theelsaud/VIP-Core-Reloaded"
    />
    <img
        src="https://img.shields.io/github/issues-closed/theelsaud/VIP-Core-Reloaded"
    />
    <img
        src="https://img.shields.io/github/repo-size/theelsaud/VIP-Core-Reloaded"
    />
    <img
        src="https://img.shields.io/github/workflow/status/theelsaud/VIP-Core-Reloaded/Compile%20and%20release"
    />
  </p>
</div>


## Requirements ##
- Sourcemod and Metamod


## Installation ##
1. Grab the latest release from the release page and unzip it in your sourcemod folder.
2. Restart the server or type `sm plugins load VIP-Core` in the console to load the plugin.
3. The config file will be automatically generated in cfg/vip/

## Configuration ##
- You can modify the phrases in addons/sourcemod/translations/vip_core.phrases.txt.
- Once the plugin has been loaded, you can modify the cvars in cfg/vip/VIP-Core.cfg.

## Commands ##
- sm_vip
- sm_vipadmin
- sm_refresh_vips
- sm_reload_vip_cfg

- sm_addvip [TODO]
- sm_delvip [TODO]

## Changes  ##
Основные изменения:  
- Основан на ветке 3.1 dev (https://github.com/R1KO/VIP-Core)
- Переписан с 0
- Поддержка SM 1.10+
- Поддержка наследования групп [+]
- Поддержка мультигрупп [+]
- Поддержка кастомных функции определённого игрока и сохранение в бд [+]
- Переписан интерфейс взаимодействия с игроком [+]
- Поддержка многострочных комментариев (SMC Parser) [+]
- Поддержка нового вида взаимодействия с VIP-функций в модуле [+]
- Поддержка Storage [+]
- Поддрежка MySQL [+]
- Поддержка большенства старых функций и совместимость с новым API [-]
- Поддрежка SQLite [-]
- Поддрежка PostgreSQL (Только на SM 1.11) [-]
- Полная поддержка переводов во всём плагине [-]
