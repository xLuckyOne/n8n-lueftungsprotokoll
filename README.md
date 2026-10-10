# Lüftungsprotokoll – Telegram + n8n

Ein selbst gehosteter Telegram-Bot zum Erfassen von Lüftungsereignissen. n8n fragt Telegram per Polling ab und speichert bestätigte Einträge in PostgreSQL. Es ist kein öffentlich erreichbarer Webhook erforderlich.

## Voraussetzungen

- n8n mit Schedule Trigger, Code, HTTP Request und Postgres Nodes
- PostgreSQL 18 oder kompatibel; die Datenbank ist für n8n über ein internes Docker-Netzwerk erreichbar
- Ein Telegram-Bot, erstellt über [@BotFather](https://t.me/BotFather)
- Eigene PostgreSQL-Datenbank und eigener Benutzer für die App

## Einrichtung

1. Importiere `n8n-lueftungsprotokoll-db-setup.json` und wähle im Postgres-Node deine PostgreSQL-Credential aus. Führe den Workflow einmal aus. Er legt Tabellen und Räume an und enthält auch die Schema-Aktualisierung für bereits eingerichtete Datenbanken. Das wiederholte Ausführen ist vorgesehen.
2. Importiere `n8n-lueftungsprotokoll-bot.json`.
3. Im Node **Konfiguration** lokal in n8n den Bot-Token und die erlaubten numerischen Telegram-User-IDs eintragen:

   ```js
   const config = {
     botToken: 'DEIN_TELEGRAM_BOT_TOKEN',
     allowedUserIds: ['DEINE_USER_ID']
   };
   ```

   Weitere Nutzer kommen als weitere Strings in das Array. Diese Werte sind privat und dürfen nicht in einen öffentlichen Export oder ein Repository gelangen.
4. In beiden Postgres-Nodes die PostgreSQL-Credential auswählen. n8n exportiert Credentials nicht mit dem Workflow.
5. Stelle sicher, dass kein anderer aktiver Workflow mit demselben Bot `getUpdates` abfragt. Aktiviere anschließend den Lüftungsprotokoll-Workflow.
6. Schreibe dem Bot `/neu` und folge den Fragen. Raum, Zeitpunkt und Dauer werden erfasst; Lüftungsart, Temperatur und Luftfeuchtigkeit sind optional. Der Eintrag wird erst nach der Bestätigung gespeichert.

## Datenbank und Sicherung

Die PostgreSQL-Datenbank und der Benutzer sollten separat von n8n-internen Daten und Paperless-Zugangsdaten angelegt werden. Datenbankzugriff für n8n kann intern über ein gemeinsames Docker-Netzwerk erfolgen; den PostgreSQL-Port nicht ohne Not ins Internet veröffentlichen.

Sichere die Datenbank regelmäßig und teste die Wiederherstellung. Workflow-JSONs enthalten keine PostgreSQL-Credentials; diese müssen nach Import in n8n zugewiesen werden.

## Sicherheit beim Veröffentlichen

- Niemals den echten Bot-Token, Datenbankpasswörter, persönliche Telegram-IDs, n8n-Credentials oder Datenbank-Dumps committen.
- Für öffentliche Beiträge nur die unveränderte Beispielkonfiguration ohne private Werte exportieren.
- `*.env` und `.env.*` sind in `.gitignore` ausgeschlossen. Vor jedem Push trotzdem die Änderungen prüfen.
- Wenn ein Token versehentlich veröffentlicht wurde, sofort über BotFather widerrufen/erneuern.
- Der Bot ist auf die IDs in `allowedUserIds` beschränkt. Nur vertrauenswürdige IDs eintragen.

## Dateien

- `n8n-lueftungsprotokoll-bot.json` – Telegram-Polling und geführte Erfassung
- `n8n-lueftungsprotokoll-db-setup.json` – wiederholbarer Datenbank-Setup und Schema-Upgrade
- `database-schema.sql` – SQL-Schema als lesbare Referenz

Der Polling-Workflow läuft alle 15 Sekunden. Es sollte nur eine aktive Polling-Instanz pro Bot geben. n8n-Ausführungsaufbewahrung passend konfigurieren, damit die Historie nicht unnötig anwächst.
