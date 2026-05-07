---
title: Environment Variable Configuration / Open WebUI
description: Overview
---

[Skip to main content](#%5F%5Fdocusaurus%5FskipToContent%5Ffallback)

On this page

## Overview[​](#overview "Direct link to Overview")

Open WebUI provides a large range of environment variables that allow you to customize and configure various aspects of the application. This page serves as a comprehensive reference for all available environment variables, providing their types, default values, and descriptions. As new variables are introduced, this page will be updated to reflect the growing configuration options.

info

This page is up-to-date with Open WebUI release version [v0.9.0](https://github.com/open-webui/open-webui/releases/tag/v0.9.0), but is still a work in progress to later include more accurate descriptions, listing out options available for environment variables, defaults, and improving descriptions.

### Important Note on `PersistentConfig` Environment Variables[​](#important-note-on-persistentconfig-environment-variables "Direct link to important-note-on-persistentconfig-environment-variables")

note

When launching Open WebUI for the first time, all environment variables are treated equally and can be used to configure the application. However, for environment variables marked as `PersistentConfig`, their values are persisted and stored internally.

After the initial launch, if you restart the container, `PersistentConfig` environment variables will no longer use the external environment variable values. Instead, they will use the internally stored values.

In contrast, regular environment variables will continue to be updated and applied on each subsequent restart.

You can update the values of `PersistentConfig` environment variables directly from within Open WebUI, and these changes will be stored internally. This allows you to manage these configuration settings independently of the external environment variables.

Please note that `PersistentConfig` environment variables are clearly marked as such in the documentation below, so you can be aware of how they will behave.

To disable this behavior and force Open WebUI to always use your environment variables (ignoring the database), set `ENABLE_PERSISTENT_CONFIG` to `False`.

**CRITICAL WARNING:** When `ENABLE_PERSISTENT_CONFIG` is `False`, you may still be able to edit settings in the Admin UI. However, these changes are **NOT saved permanently**. They will persist only for the current session and will be **lost** when you restart the container, as the system will revert to the values defined in your environment variables.

### Troubleshooting Ignored Environment Variables 🛠️[​](#troubleshooting-ignored-environment-variables-️ "Direct link to Troubleshooting Ignored Environment Variables 🛠️")

If you change an environment variable (like `ENABLE_SIGNUP=True`) but don't see the change reflected in the UI (e.g., the "Sign Up" button is still missing), it's likely because a value has already been persisted in the database from a previous run or a persistent Docker volume.

#### Option 1: Using `ENABLE_PERSISTENT_CONFIG` (Temporary Fix)[​](#option-1-using-enable%5Fpersistent%5Fconfig-temporary-fix "Direct link to option-1-using-enable_persistent_config-temporary-fix")

Set `ENABLE_PERSISTENT_CONFIG=False` in your environment. This forces Open WebUI to read your variables directly. Note that UI-based settings changes will not persist across restarts in this mode.

#### Option 2: Update via Admin UI (Recommended)[​](#option-2-update-via-admin-ui-recommended "Direct link to Option 2: Update via Admin UI (Recommended)")

The simplest and safest way to change `PersistentConfig` settings is directly through the **Admin Panel** within Open WebUI. Even if an environment variable is set, changes made in the UI will take precedence and be saved to the database.

#### Option 3: Manual Database Update (Last Resort / Lock-out Recovery)[​](#option-3-manual-database-update-last-resort--lock-out-recovery "Direct link to Option 3: Manual Database Update (Last Resort / Lock-out Recovery)")

If you are locked out or cannot access the UI, you can manually update the SQLite database via Docker:

```
docker exec -it open-webui sqlite3 /app/backend/data/webui.db "UPDATE config SET data = json_set(data, '$.ENABLE_SIGNUP', json('true'));"
```

_(Replace `ENABLESIGNUP` and `true` with the specific setting and value needed.)_

#### Option 4: Resetting for a Fresh Install[​](#option-4-resetting-for-a-fresh-install "Direct link to Option 4: Resetting for a Fresh Install")

If you are performing a clean installation and want to ensure all environment variables are fresh:

1. Stop the container.
2. Remove the persistent volume: `docker volume rm open-webui`.
3. Restart the container.

danger

**Warning:** Removing the volume will delete all user data, including chats and accounts.

## App/Backend[​](#appbackend "Direct link to App/Backend")

The following environment variables are used by `backend/open_webui/config.py` to provide Open WebUI startup configuration. Please note that some variables may have different default values depending on whether you're running Open WebUI directly or via Docker. For more information on logging environment variables, see our [logging documentation](https://docs.openwebui.com/getting-started/advanced-topics/logging).

### General[​](#general "Direct link to General")

#### `WEBUI_URL`[​](#webui%5Furl "Direct link to webui_url")

* Type: `str`
* Default: `http://localhost:3000`
* Description: Specifies the URL where your Open WebUI installation is reachable. Needed for search engine support and OAuth/SSO.
* Persistence: This environment variable is a `PersistentConfig` variable.

warning

This variable has to be set before you start using OAuth/SSO for authentication. Since this is a persistent config environment variable, you can only change it through one of the following options:

* Temporarily disabling persistent config using `ENABLE_PERSISTENT_CONFIG`
* Changing `WEBUI_URL` in the admin panel > settings and changing "WebUI URL".

Failure to set WEBUI\_URL before using OAuth/SSO will result in failure to log in.

#### `ENABLE_SIGNUP`[​](#enable%5Fsignup "Direct link to enable_signup")

* Type: `bool`
* Default: `True`
* Description: Toggles user account creation.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_SIGNUP_PASSWORD_CONFIRMATION`[​](#enable%5Fsignup%5Fpassword%5Fconfirmation "Direct link to enable_signup_password_confirmation")

* Type: `bool`
* Default: `False`
* Description: If set to True, a "Confirm Password" field is added to the sign-up page to help users avoid typos when creating their password.

#### `WEBUI_ADMIN_EMAIL`[​](#webui%5Fadmin%5Femail "Direct link to webui_admin_email")

* Type: `str`
* Default: Empty string (' ')
* Description: Specifies the email address for an admin account to be created automatically on first startup when no users exist. This enables headless/automated deployments without manual account creation. When combined with `WEBUI_ADMIN_PASSWORD`, the admin account is created during application startup, and `ENABLE_SIGNUP` is automatically disabled to prevent unauthorized account creation.

info

This variable is designed for automated/containerized deployments where manual admin account creation is impractical. The admin account is only created if:

* No users exist in the database (fresh installation)
* Both `WEBUI_ADMIN_EMAIL` and `WEBUI_ADMIN_PASSWORD` are configured

After the admin account is created, sign-up is automatically disabled for security. You can re-enable it later via the Admin Panel if needed.

#### `WEBUI_ADMIN_PASSWORD`[​](#webui%5Fadmin%5Fpassword "Direct link to webui_admin_password")

* Type: `str`
* Default: Empty string (' ')
* Description: Specifies the password for the admin account to be created automatically on first startup when no users exist. Must be used in conjunction with `WEBUI_ADMIN_EMAIL`. The password is securely hashed before storage using the same mechanism as manual account creation.

danger

**Security Considerations**

* Use a strong, unique password for production deployments
* Consider using secrets management (Docker secrets, Kubernetes secrets, environment variable injection) rather than storing the password in plain text configuration files
* After initial setup, change the admin password through the UI for enhanced security
* Never commit this value to version control

#### `WEBUI_ADMIN_NAME`[​](#webui%5Fadmin%5Fname "Direct link to webui_admin_name")

* Type: `str`
* Default: `Admin`
* Description: Specifies the display name for the automatically created admin account. This is used when `WEBUI_ADMIN_EMAIL` and `WEBUI_ADMIN_PASSWORD` are configured for headless admin creation.

#### `ENABLE_LOGIN_FORM`[​](#enable%5Flogin%5Fform "Direct link to enable_login_form")

* Type: `bool`
* Default: `True`
* Description: Toggles email, password, sign-in and "or" (only when `ENABLE_OAUTH_SIGNUP` is set to True) elements.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_PASSWORD_CHANGE_FORM`[​](#enable%5Fpassword%5Fchange%5Fform "Direct link to enable_password_change_form")

* Type: `bool`
* Default: `True`
* Description: Controls visibility of the password change UI in **Settings > Account**. When set to `False`, users do not see the password update form, which is useful for SSO-focused deployments where password changes should not be presented in the UI.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_PASSWORD_AUTH`[​](#enable%5Fpassword%5Fauth "Direct link to enable_password_auth")

* Type: `bool`
* Default: `True`
* Description: Allows both password and SSO authentication methods to coexist when set to True. When set to False, it disables all password-based login attempts on the /signin and /ldap endpoints, enforcing strict SSO-only authentication. Disable this setting in production environments with fully configured SSO to prevent credential-based account takeover attacks; keep it enabled if you require password authentication as a backup or have not yet completed SSO configuration. Should never be disabled if OAUTH/SSO is not being used. This setting controls backend authentication behavior, while `ENABLE_PASSWORD_CHANGE_FORM` controls UI visibility of password-change controls.

tip

This SHOULD be set to `False` if you only use SSO/OAUTH for Login and expose your Open WebUI publicly as to prevent password based logins.

danger

This should **only** ever be set to `False` when [ENABLE\_OAUTH\_SIGNUP](https://docs.openwebui.com/reference/env-configuration/#enable%5Foauth%5Fsignup)is also being used and set to `True`. **Never disable this if OAUTH/SSO is not being used.** Failure to do so will result in the inability to login.

#### `DEFAULT_LOCALE`[​](#default%5Flocale "Direct link to default_locale")

* Type: `str`
* Default: `en`
* Description: Sets the default locale for the application.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DEFAULT_MODELS`[​](#default%5Fmodels "Direct link to default_models")

* Type: `str`
* Default: Empty string (' '), since `None`.
* Description: Sets a default Language Model.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DEFAULT_PINNED_MODELS`[​](#default%5Fpinned%5Fmodels "Direct link to default_pinned_models")

* Type: `str`
* Default: Empty string (' ')
* Description: Comma-separated list of model IDs to pin by default for new users who haven't customized their pinned models. This provides a pre-selected set of frequently used models in the model selector for new accounts.
* Example: `gpt-4,claude-3-opus,llama-3-70b`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DEFAULT_MODEL_METADATA`[​](#default%5Fmodel%5Fmetadata "Direct link to default_model_metadata")

* Type: `dict` (JSON object)
* Default: `{}`
* Description: Sets global default metadata (capabilities and other model info) for all models. These defaults act as a baseline — per-model overrides always take precedence. For capabilities, the defaults and per-model values are merged (per-model wins on conflicts). For other metadata fields, the default is only applied if the model has no value set. Configurable via **Admin Settings → Models**.
* Persistence: This environment variable is a `PersistentConfig` variable. Stored at config key `models.default_metadata`.

#### `DEFAULT_MODEL_PARAMS`[​](#default%5Fmodel%5Fparams "Direct link to default_model_params")

* Type: `dict` (JSON object)
* Default: `{}`
* Description: Sets global default parameters (temperature, top\_p, max\_tokens, seed, etc.) for all models. These defaults are applied as a baseline at chat completion time — per-model parameter overrides always take precedence. Configurable via **Admin Settings → Models**.
* Persistence: This environment variable is a `PersistentConfig` variable. Stored at config key `models.default_params`.

info

`DEFAULT_MODEL_PARAMS` is read from the environment as a JSON string at startup.

* Use valid JSON (for example: `{"temperature":0.7,"function_calling":"native"}`)
* If parsing fails, Open WebUI logs the error and falls back to `{}`

#### `DEFAULT_USER_ROLE`[​](#default%5Fuser%5Frole "Direct link to default_user_role")

* Type: `str`
* Options:  
   * `pending` \- New users are pending until their accounts are manually activated by an admin.  
   * `user` \- New users are automatically activated with regular user permissions.  
   * `admin` \- New users are automatically activated with administrator permissions.
* Default: `pending`
* Description: Sets the default role assigned to new users.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DEFAULT_GROUP_ID`[​](#default%5Fgroup%5Fid "Direct link to default_group_id")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the default group ID to assign to new users upon registration.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DEFAULT_GROUP_SHARE_PERMISSION`[​](#default%5Fgroup%5Fshare%5Fpermission "Direct link to default_group_share_permission")

* Type: `str`
* Options: `members`, `true`, `false`
* Default: `members`
* Description: Controls the default "Who can share to this group" setting for newly created groups. `members` means only group members can share to the group, `true` means anyone can share, and `false` means no one can share to the group. This applies both to groups created manually and groups created automatically (e.g. via SCIM or OAuth group sync). Existing groups are not affected — this only sets the initial default for new groups.

#### `PENDING_USER_OVERLAY_TITLE`[​](#pending%5Fuser%5Foverlay%5Ftitle "Direct link to pending_user_overlay_title")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets a custom title for the pending user overlay.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PENDING_USER_OVERLAY_CONTENT`[​](#pending%5Fuser%5Foverlay%5Fcontent "Direct link to pending_user_overlay_content")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets a custom text content for the pending user overlay.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_CALENDAR`[​](#enable%5Fcalendar "Direct link to enable_calendar")

* Type: `bool`
* Default: `True`
* Description: Enables or disables the Calendar feature. When enabled, users can create calendars, manage events, and share calendars with other users or groups via access grants. Active automations are automatically surfaced as virtual events on a dedicated "Scheduled Tasks" calendar. Requires the `features.calendar` user permission (admins always pass).
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_CHANNELS`[​](#enable%5Fchannels "Direct link to enable_channels")

* Type: `bool`
* Default: `False`
* Description: Enables or disables channel support.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_FOLDERS`[​](#enable%5Ffolders "Direct link to enable_folders")

* Type: `bool`
* Default: `True`
* Description: Enables or disables the folders feature, allowing users to organize their chats into folders in the sidebar.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `FOLDER_MAX_FILE_COUNT`[​](#folder%5Fmax%5Ffile%5Fcount "Direct link to folder_max_file_count")

* Type: `int`
* Default: `("") empty string`
* Description: Sets the maximum number of files processing allowed per folder.
* Persistence: This environment variable is a `PersistentConfig` variable. It can be configured in the **Admin Panel > Settings > General > Folder Max File Count**. Default is none (empty string) which is unlimited.

#### `ENABLE_AUTOMATIONS`[​](#enable%5Fautomations "Direct link to enable_automations")

* Type: `bool`
* Default: `True`
* Description: Enables or disables the Automations feature globally. When disabled, the scheduler skips automation processing, the automation API endpoints return `403 Forbidden`, automation builtin tools are not injected, and the Automations entry is hidden from the sidebar. Requires the `features.automations` user permission (admins always pass).
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `AUTOMATION_MAX_COUNT`[​](#automation%5Fmax%5Fcount "Direct link to automation_max_count")

* Type: `int`
* Default: `("") empty string` (unlimited)
* Description: Sets the maximum number of automations a non-admin user can create. When set to a positive integer, users who reach this limit will receive a `403 Forbidden` error when attempting to create additional automations. Admins bypass this limit.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `AUTOMATION_MIN_INTERVAL`[​](#automation%5Fmin%5Finterval "Direct link to automation_min_interval")

* Type: `int` (seconds)
* Default: `("") empty string` (no minimum)
* Description: Sets the minimum allowed interval in seconds between automation recurrences for non-admin users. When set, any automation schedule that recurs more frequently than this value will be rejected with a `400 Bad Request` error. One-time automations (`COUNT=1`) are exempt from this check. Admins bypass this limit.
* Persistence: This environment variable is a `PersistentConfig` variable.

Common values for AUTOMATION\_MIN\_INTERVAL

| Value | Meaning                         |
| ----- | ------------------------------- |
| 60    | Minimum 1 minute between runs   |
| 300   | Minimum 5 minutes between runs  |
| 900   | Minimum 15 minutes between runs |
| 3600  | Minimum 1 hour between runs     |

#### `SCHEDULER_POLL_INTERVAL`[​](#scheduler%5Fpoll%5Finterval "Direct link to scheduler_poll_interval")

* Type: `int` (seconds)
* Default: `10`
* Description: Sets the interval in seconds between scheduler ticks. The unified scheduler handles both automation execution and calendar event alerts. Accepts `AUTOMATION_POLL_INTERVAL` as a legacy fallback.

#### `CALENDAR_ALERT_LOOKAHEAD_MINUTES`[​](#calendar%5Falert%5Flookahead%5Fminutes "Direct link to calendar_alert_lookahead_minutes")

* Type: `int` (minutes)
* Default: `10`
* Description: Default lookahead window in minutes for calendar event alerts. Events starting within this window from the current time will trigger toast and webhook notifications. Individual events can override this via the **Reminder** setting in the event editor (`meta.alert_minutes`).

#### `ENABLE_NOTES`[​](#enable%5Fnotes "Direct link to enable_notes")

* Type: `bool`
* Default: `True`
* Description: Enables or disables the notes feature, allowing users to create and manage personal notes within Open WebUI.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_MEMORIES`[​](#enable%5Fmemories "Direct link to enable_memories")

* Type: `bool`
* Default: `True`
* Description: Enables or disables the [memory feature](/features/chat-conversations/memory), allowing models to store and retrieve long-term information about users.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `WEBHOOK_URL`[​](#webhook%5Furl "Direct link to webhook_url")

* Type: `str`
* Description: Sets a webhook for integration with Discord/Slack/Microsoft Teams.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_ADMIN_EXPORT`[​](#enable%5Fadmin%5Fexport "Direct link to enable_admin_export")

* Type: `bool`
* Default: `True`
* Description: Controls whether admins can export data, chats and the database in the admin panel. Database exports only work for SQLite databases for now.

#### `ENABLE_ADMIN_CHAT_ACCESS`[​](#enable%5Fadmin%5Fchat%5Faccess "Direct link to enable_admin_chat_access")

* Type: `bool`
* Default: `True`
* Description: Enables admin users to directly access the chats of other users. When disabled, admins can no longer accesss user's chats in the admin panel. If you disable this, consider disabling `ENABLE_ADMIN_EXPORT` too, if you are using SQLite, as the exports also contain user chats.

#### `ENABLE_ADMIN_ANALYTICS`[​](#enable%5Fadmin%5Fanalytics "Direct link to enable_admin_analytics")

* Type: `bool`
* Default: `True`
* Description: Controls whether the **Analytics** tab is visible and accessible in the admin panel. When set to `False`, the analytics API router is not mounted and the tab is hidden from the admin navigation. Useful for deployments where analytics data collection or display is not desired. Requires a restart to take effect.

#### `BYPASS_ADMIN_ACCESS_CONTROL`[​](#bypass%5Fadmin%5Faccess%5Fcontrol "Direct link to bypass_admin_access_control")

* Type: `bool`
* Default: `True`
* Description: When disabled, admin users are treated like regular users for workspace access (models, knowledge, prompts, tools, and notes) and only see items they have **explicit permission to access** through the existing access control system. This also applies to the visibility of models in the model selector - admins will be treated as regular users: base models and custom models they do not have **explicit permission to access**, will be hidden. If set to `True` (Default), admins have access to **all created items** in the workspace area (including other users' notes) and all models in the model selector, **regardless of access permissions**. This environment variable deprecates `ENABLE_ADMIN_WORKSPACE_CONTENT_ACCESS`. If you are still using `ENABLE_ADMIN_WORKSPACE_CONTENT_ACCESS` you should switch to `BYPASS_ADMIN_ACCESS_CONTROL`.

#### `ENABLE_USER_WEBHOOKS`[​](#enable%5Fuser%5Fwebhooks "Direct link to enable_user_webhooks")

* Type: `bool`
* Default: `False`
* Description: Enables or disables user webhooks.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RESPONSE_WATERMARK`[​](#response%5Fwatermark "Direct link to response_watermark")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets a custom text that will be included when you copy a message in the chat. e.g., `"This text is AI generated"` \-> will add "This text is AI generated" to every message, when copied.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `THREAD_POOL_SIZE`[​](#thread%5Fpool%5Fsize "Direct link to thread_pool_size")

* Type: `int`
* Default: `0`
* Description: Sets the thread pool size for FastAPI/AnyIO blocking calls. By default (when set to `0`) FastAPI/AnyIO use `40` threads. In case of large instances and many concurrent users, it may be needed to increase `THREAD_POOL_SIZE` to prevent blocking.

info

If you are running larger instances, you WILL NEED to set this to a higher value like multiple hundreds if not thousands (e.g. `1000`) otherwise your app may get stuck the default pool size (which is 40 threads) is full and will not react anymore.

#### `ENABLE_CUSTOM_MODEL_FALLBACK`[​](#enable%5Fcustom%5Fmodel%5Ffallback "Direct link to enable_custom_model_fallback")

* Type: `bool`
* Default: `False`
* Description: Controls whether custom models should fall back to a default model if their assigned base model is missing. When set to `True`, if a custom model's base model is not found, the system will use the first model from the configured `DEFAULT_MODELS` list instead of returning an error.

#### `SHOW_ADMIN_DETAILS`[​](#show%5Fadmin%5Fdetails "Direct link to show_admin_details")

* Type: `bool`
* Default: `True`
* Description: Toggles whether to show admin user details in the interface.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_PUBLIC_ACTIVE_USERS_COUNT`[​](#enable%5Fpublic%5Factive%5Fusers%5Fcount "Direct link to enable_public_active_users_count")

* Type: `bool`
* Default: `True`
* Description: Controls whether the active user count is visible to all users or restricted to administrators only. When set to `False`, only admin users can see how many users are currently active, reducing backend load and addressing privacy concerns in large deployments.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_USER_STATUS`[​](#enable%5Fuser%5Fstatus "Direct link to enable_user_status")

* Type: `bool`
* Default: `True`
* Description: Globally enables or disables user status functionality. When disabled, the status UI (including blinking active/away indicators and status messages) is hidden across the application, and user status API endpoints are restricted.
* Persistence: This environment variable is a `PersistentConfig` variable. It can be toggled in the **Admin Panel > Settings > General > User Status**.

#### `ENABLE_EASTER_EGGS`[​](#enable%5Feaster%5Feggs "Direct link to enable_easter_eggs")

* Type: `bool`
* Default: `True`
* Description: Enables or disables easter egg features in the UI, such as special themes (e.g., the "Her" theme option in the theme selector). Set to `False` to hide these optional novelty features from users.

#### `ADMIN_EMAIL`[​](#admin%5Femail "Direct link to admin_email")

* Type: `str`
* Description: Sets the admin email shown by `SHOW_ADMIN_DETAILS`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENV`[​](#env "Direct link to env")

* Type: `str`
* Options:  
   * `dev` \- Enables the FastAPI API documentation on `/docs`  
   * `prod` \- Automatically configures several environment variables
* Default:  
   * **Backend Default**: `dev`  
   * **Docker Default**: `prod`
* Description: Environment setting.

#### `ENABLE_PERSISTENT_CONFIG`[​](#enable%5Fpersistent%5Fconfig "Direct link to enable_persistent_config")

* Type: `bool`
* Default: `True`
* Description: Controls whether the system prioritizes configuration saved in the database over environment variables.  
   * **`True` (Default):** Values saved in the **database** (via the Admin UI) take precedence. If a value is set in the UI, the environment variable is ignored for that setting.  
   * **`False`:** **Environment variables** take precedence. The system will _not_ load configuration from the database at startup if an environment variable is present (or it will use the default).  
         * **CRITICAL WARNING:** When set to `False`, you can still seemingly "change" settings in the Admin UI. These changes will apply to the **current running session** but **will be lost upon restart**. The system will revert to the values defined in your environment variables (or defaults) every time it boots up.  
         * **Use Case:** Set this to `False` if you want to strictly manage configuration via a `docker-compose.yaml` or `.env` file and prevent UI changes from persisting across restarts.

#### `CUSTOM_NAME`[​](#custom%5Fname "Direct link to custom_name")

* Type: `str`
* Description: Sets `WEBUI_NAME` but polls **api.openwebui.com** for metadata.

#### `WEBUI_NAME`[​](#webui%5Fname "Direct link to webui_name")

* Type: `str`
* Default: `Open WebUI`
* Description: Sets the main WebUI name. Appends `(Open WebUI)` if overridden.

#### `PORT`[​](#port "Direct link to port")

* Type: `int`
* Default: `8080`
* Description: Sets the port to run Open WebUI from.

info

If you're running the application via Python and using the `open-webui serve` command, you cannot set the port using the `PORT` configuration. Instead, you must specify it directly as a command-line argument using the `--port` flag. For example:

```
open-webui serve --port 9999
```

This will run the Open WebUI on port `9999`. The `PORT` environment variable is disregarded in this mode.

#### `ENABLE_REALTIME_CHAT_SAVE`[​](#enable%5Frealtime%5Fchat%5Fsave "Direct link to enable_realtime_chat_save")

* Type: `bool`
* Default: `False`
* Description: When enabled, the system saves each individual chunk of streamed chat data to the database in real time.

EXTREME PERFORMANCE RISK: DO NOT ENABLE IN PRODUCTION

**It is strongly recommended to NEVER enable this setting in production or multi-user environments.**

Enabling `ENABLE_REALTIME_CHAT_SAVE` causes every single token generated by the LLM to trigger a separate database write operation. In a multi-user environment, this will:

1. **Exhaust Database Connection Pools**: Rapid-fire writes will quickly consume all available database connections, leading to "QueuePool limit reached" errors and application-wide freezes.
2. **Severe Performance Impact**: The overhead of thousands of database transactions per minute will cause massive latency for all users.
3. **Hardware Strain**: It creates immense I/O pressure on your storage system.

**Keep this set to `False` (the default).** Chats are still saved automatically once generation is complete. This setting is only intended for extreme debugging scenarios or single-user environments where sub-second persistence of every token is more important than stability.

#### `ENABLE_CHAT_RESPONSE_BASE64_IMAGE_URL_CONVERSION`[​](#enable%5Fchat%5Fresponse%5Fbase64%5Fimage%5Furl%5Fconversion "Direct link to enable_chat_response_base64_image_url_conversion")

* Type: `bool`
* Default: `False`
* Description: When set to true, it automatically uploads base64-encoded images exceeding 1KB in markdown and converts them into image file URLs to reduce the size of response text. Some multimodal models directly output images as Base64 strings within the Markdown content. This results in larger response bodies, placing strain on CPU, network, Redis, and database resources.

#### `ENABLE_IMAGE_CONTENT_TYPE_EXTENSION_FALLBACK`[​](#enable%5Fimage%5Fcontent%5Ftype%5Fextension%5Ffallback "Direct link to enable_image_content_type_extension_fallback")

* Type: `bool`
* Default: `False`
* Description: When enabled, uses a hardcoded extension-to-MIME dictionary as a last-resort fallback when both the system MIME database and the file's stored content type metadata fail to determine the content type of an image. This is primarily useful on minimal container images (e.g., wolfi-base) that lack `/etc/mime.types` and have legacy files without stored content type metadata. Supported extensions include `.webp`, `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.bmp`, `.tiff`, `.ico`, `.heic`, `.heif`, and `.avif`.

#### `CHAT_RESPONSE_STREAM_DELTA_CHUNK_SIZE`[​](#chat%5Fresponse%5Fstream%5Fdelta%5Fchunk%5Fsize "Direct link to chat_response_stream_delta_chunk_size")

* Type: `int`
* Default: `1`
* Description: Sets a system-wide minimum value for the number of tokens to batch together before sending them to the client during a streaming response. This allows an administrator to enforce a baseline level of performance and stability across the entire system by preventing excessively small chunk sizes that can cause high CPU load. The final chunk size used for a response will be the highest value set among this global variable, the model's advanced parameters, or the per-chat settings. The default is 1, which applies no minimum batching at the global level.

#### `CHAT_STREAM_RESPONSE_CHUNK_MAX_BUFFER_SIZE`[​](#chat%5Fstream%5Fresponse%5Fchunk%5Fmax%5Fbuffer%5Fsize "Direct link to chat_stream_response_chunk_max_buffer_size")

* Type: `int`
* Default: Empty string (' '), which disables the limit (equivalent to None)
* Description: Sets the maximum buffer size in bytes for handling stream response chunks. When a single chunk exceeds this limit, the system returns an empty JSON object and skips subsequent oversized data until encountering normally-sized chunks. This prevents memory issues when dealing with extremely large responses from certain providers (e.g., models like gemini-2.5-flash-image or services returning extensive web search data exceeding). Set to an empty string or a negative value to disable chunk size limitations entirely. Recommended values are 16-20 MB (`16777216`) or larger depending on the image size of the image generation model (4K images may need even more).

info

It is recommended to set this to a high single-digit or low double-digit value if you run Open WebUI with high concurrency, many users, and very fast streaming models.

#### `ENABLE_RESPONSES_API_STATEFUL`[​](#enable%5Fresponses%5Fapi%5Fstateful "Direct link to enable_responses_api_stateful")

* Type: `bool`
* Default: `False`
* Description: Enables stateful session handling for the Responses API by forwarding `previous_response_id` to the upstream endpoint. When enabled, Open WebUI anchors each response to the previous one, allowing the upstream provider to maintain conversation state server-side.

Experimental

**Only enable this if your upstream Responses API endpoint supports stateful sessions** (i.e., server-side response storage with `previous_response_id` anchoring). Most proxies and third-party endpoints are stateless and **will break** if this is enabled. This is intended for direct connections to providers like OpenAI that natively support the Responses API with session state.

#### `BYPASS_MODEL_ACCESS_CONTROL`[​](#bypass%5Fmodel%5Faccess%5Fcontrol "Direct link to bypass_model_access_control")

* Type: `bool`
* Default: `False`
* Description: Bypasses model access control. When set to `true`, all users (and admins alike) will have access to all models, regardless of the model's privacy setting (Private, Public, Shared with certain groups). This is useful for smaller or individual Open WebUI installations where model access restrictions may not be needed.

#### `WEBUI_BUILD_HASH`[​](#webui%5Fbuild%5Fhash "Direct link to webui_build_hash")

* Type: `str`
* Default: `dev-build`
* Description: Used for identifying the Git SHA of the build for releases.

#### `WEBUI_BANNERS`[​](#webui%5Fbanners "Direct link to webui_banners")

* Type: `list` of `dict`
* Default: `[]`
* Description: List of banners to show to users. The format for banners are:

```
[{"id": "string", "type": "string [info, success, warning, error]", "title": "string", "content": "string", "dismissible": false, "timestamp": 1000}]
```

* Persistence: This environment variable is a `PersistentConfig` variable.

info

When setting this environment variable in a `.env` file, make sure to escape the quotes by wrapping the entire value in double quotes and using escaped quotes (`\"`) for the inner quotes. Example:

```
WEBUI_BANNERS="[{\"id\": \"1\", \"type\": \"warning\", \"title\": \"Your messages are stored.\", \"content\": \"Your messages are stored and may be reviewed by human people. LLM's are prone to hallucinations, check sources.\", \"dismissible\": true, \"timestamp\": 1000}]"

```

#### `USE_CUDA_DOCKER`[​](#use%5Fcuda%5Fdocker "Direct link to use_cuda_docker")

* Type: `bool`
* Default: `False`
* Description: Builds the Docker image with NVIDIA CUDA support. Enables GPU acceleration for local Whisper and embeddings.

#### `DOCKER`[​](#docker "Direct link to docker")

* Type: `bool`
* Default: `False`
* Description: Indicates whether Open WebUI is running inside a Docker container. Used internally for environment detection.

#### `USE_CUDA`[​](#use%5Fcuda "Direct link to use_cuda")

* Type: `bool`
* Default: `False`
* Description: Controls whether to use CUDA acceleration for local models. When set to `true`, attempts to detect and use available NVIDIA GPUs. The code reads the environment variable `USE_CUDA_DOCKER` to set this internal boolean variable.

#### `DEVICE_TYPE`[​](#device%5Ftype "Direct link to device_type")

* Type: `str`
* Default: `cpu`
* Description: Specifies the device type for model execution. Automatically set to `cuda` if CUDA is available and enabled, or `mps` for Apple Silicon.

#### `EXTERNAL_PWA_MANIFEST_URL`[​](#external%5Fpwa%5Fmanifest%5Furl "Direct link to external_pwa_manifest_url")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: When defined as a fully qualified URL (e.g., <https://path/to/manifest.webmanifest>), requests sent to /manifest.json will use the external manifest file. When not defined, the default manifest.json file will be used.

#### `ENABLE_TITLE_GENERATION`[​](#enable%5Ftitle%5Fgeneration "Direct link to enable_title_generation")

* Type: `bool`
* Default: `True`
* Description: Enables or disables chat title generation.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `LICENSE_KEY`[​](#license%5Fkey "Direct link to license_key")

* Type: `str`
* Default: `None`
* Description: Specifies the license key to use (for Enterprise users only).
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SSL_ASSERT_FINGERPRINT`[​](#ssl%5Fassert%5Ffingerprint "Direct link to ssl_assert_fingerprint")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the SSL assert fingerprint to use.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_COMPRESSION_MIDDLEWARE`[​](#enable%5Fcompression%5Fmiddleware "Direct link to enable_compression_middleware")

* Type: `bool`
* Default: `True`
* Description: Enables gzip compression middleware for HTTP responses, reducing bandwidth usage and improving load times.

#### `DEFAULT_PROMPT_SUGGESTIONS`[​](#default%5Fprompt%5Fsuggestions "Direct link to default_prompt_suggestions")

* Type: `list` of `dict`
* Default: `[]` (which means to use the built-in default prompt suggestions)
* Description: Sets global default prompt suggestions shown to users when starting a new chat. These apply when no model-specific prompt suggestions are configured. Prompt suggestions can also be configured per-model via the Model Editor (see [Prompt Suggestions](/features/workspace/models#prompt-suggestions)), or globally for all models using the [Global Model Defaults](/features/workspace/models#global-model-defaults-admin) feature. The format is:

```
[{"title": ["Title part 1", "Title part 2"], "content": "prompt"}]
```

### AIOHTTP Client[​](#aiohttp-client "Direct link to AIOHTTP Client")

#### `AIOHTTP_CLIENT_TIMEOUT`[​](#aiohttp%5Fclient%5Ftimeout "Direct link to aiohttp_client_timeout")

* Type: `int`
* Default: `300`
* Description: Specifies the timeout duration in seconds for the AIOHTTP client. This impacts things such as connections to Ollama and OpenAI endpoints.

info

This is the maximum amount of time the client will wait for a response before timing out. If set to an empty string (' '), the timeout will be set to `None`, effectively disabling the timeout and allowing the client to wait indefinitely.

#### `AIOHTTP_CLIENT_TIMEOUT_MODEL_LIST`[​](#aiohttp%5Fclient%5Ftimeout%5Fmodel%5Flist "Direct link to aiohttp_client_timeout_model_list")

* Type: `int`
* Default: `10`
* Description: Sets the timeout in seconds for fetching the model list from Ollama and OpenAI endpoints. This affects how long Open WebUI waits for each configured endpoint when loading available models.

When to Adjust This Value

**Lower the timeout** (e.g., `3`) if:

* You have multiple endpoints configured and want faster failover when one is unreachable
* You prefer the UI to load quickly even if some slow endpoints are skipped

**Increase the timeout** (e.g., `30`) if:

* Your model servers are slow to respond (e.g., cold starts, large model loading)
* You're connecting over high-latency networks
* You're using providers like OpenRouter that may have variable response times

Database Persistence

Connection URLs configured via the Admin Settings UI are **persisted in the database** and take precedence over environment variables. If you save an unreachable URL and the UI becomes unresponsive, you may need to use one of these recovery options:

* `RESET_CONFIG_ON_START=true` \- Resets database config to environment variable values on next startup
* `ENABLE_PERSISTENT_CONFIG=false` \- Always use environment variables (UI changes won't persist)

See the [Model List Loading Issues](/troubleshooting/connection-error#%EF%B8%8F-model-list-loading-issues-slow-ui--unreachable-endpoints) troubleshooting guide for detailed recovery steps.

#### `AIOHTTP_CLIENT_TIMEOUT_OPENAI_MODEL_LIST`[​](#aiohttp%5Fclient%5Ftimeout%5Fopenai%5Fmodel%5Flist "Direct link to aiohttp_client_timeout_openai_model_list")

* Type: `int`
* Description: Sets the timeout in seconds for fetching the model list. This can be useful in cases where network latency requires a longer timeout duration to successfully retrieve the model list.

#### `AIOHTTP_CLIENT_TIMEOUT_TOOL_SERVER`[​](#aiohttp%5Fclient%5Ftimeout%5Ftool%5Fserver "Direct link to aiohttp_client_timeout_tool_server")

* Type: `int`
* Default: Inherits `AIOHTTP_CLIENT_TIMEOUT` when unset
* Description: Sets the timeout in seconds for executing tool server API calls (OpenAPI/MCP proxy calls made by Open WebUI). Use this to control how long Open WebUI waits for actual tool execution responses.

info

If this variable is unset or invalid, Open WebUI falls back to `AIOHTTP_CLIENT_TIMEOUT`.

#### `AIOHTTP_CLIENT_SESSION_SSL`[​](#aiohttp%5Fclient%5Fsession%5Fssl "Direct link to aiohttp_client_session_ssl")

* Type: `bool`
* Default: `True`
* Description: Controls SSL/TLS verification for AIOHTTP client sessions when connecting to external APIs (e.g., Ollama Embeddings).

#### `AIOHTTP_CLIENT_TIMEOUT_TOOL_SERVER_DATA`[​](#aiohttp%5Fclient%5Ftimeout%5Ftool%5Fserver%5Fdata "Direct link to aiohttp_client_timeout_tool_server_data")

* Type: `int`
* Default: `10`
* Description: Sets the timeout in seconds for retrieving tool server metadata/configuration (for example, loading server data/spec information).

#### `AIOHTTP_CLIENT_SESSION_TOOL_SERVER_SSL`[​](#aiohttp%5Fclient%5Fsession%5Ftool%5Fserver%5Fssl "Direct link to aiohttp_client_session_tool_server_ssl")

* Type: `bool`
* Default: `True`
* Description: Controls SSL/TLS verification specifically for tool server connections via AIOHTTP client.

#### `AIOHTTP_POOL_CONNECTIONS`[​](#aiohttp%5Fpool%5Fconnections "Direct link to aiohttp_pool_connections")

* Type: `int`
* Default: unset (unlimited)
* Description: Maximum number of total concurrent connections in the shared AIOHTTP client pool used for outbound requests (Ollama, OpenAI-compatible endpoints, etc.). When unset, there is no total cap. Lower this if you need to bound total upstream concurrency.

#### `AIOHTTP_POOL_CONNECTIONS_PER_HOST`[​](#aiohttp%5Fpool%5Fconnections%5Fper%5Fhost "Direct link to aiohttp_pool_connections_per_host")

* Type: `int`
* Default: unset (unlimited)
* Description: Maximum number of concurrent connections to any single host in the shared AIOHTTP pool. When unset, there is no per-host cap. Useful for staying under provider-side rate or connection limits.

#### `AIOHTTP_POOL_DNS_TTL`[​](#aiohttp%5Fpool%5Fdns%5Fttl "Direct link to aiohttp_pool_dns_ttl")

* Type: `int`
* Default: `300`
* Description: DNS cache TTL in seconds for the shared AIOHTTP pool. Negative or invalid values fall back to `300`. Increase for stable infrastructure; decrease if upstream hosts change IPs frequently.

info

Open WebUI reuses a single long-lived AIOHTTP client session for outbound HTTP traffic, enabling TCP/TLS connection reuse, a shared DNS cache, and bounded concurrency. The three variables above tune this pool; they do not need to be set in typical deployments.

#### `REQUESTS_VERIFY`[​](#requests%5Fverify "Direct link to requests_verify")

* Type: `bool`
* Default: `True`
* Description: Controls SSL/TLS verification for synchronous `requests` (e.g., Tika, External Reranker). Set to `False` to bypass certificate verification for self-signed certificates.

### Directories[​](#directories "Direct link to Directories")

#### `DATA_DIR`[​](#data%5Fdir "Direct link to data_dir")

* Type: `str`
* Default: `./data`
* Description: Specifies the base directory for data storage, including uploads, cache, vector database, etc.

#### `FONTS_DIR`[​](#fonts%5Fdir "Direct link to fonts_dir")

* Type: `str`
* Description: Specifies the directory for fonts.

#### `FRONTEND_BUILD_DIR`[​](#frontend%5Fbuild%5Fdir "Direct link to frontend_build_dir")

* Type: `str`
* Default: `../build`
* Description: Specifies the location of the built frontend files.

#### `STATIC_DIR`[​](#static%5Fdir "Direct link to static_dir")

* Type: `str`
* Default: `./static`
* Description: Specifies the directory for static files, such as the favicon.

### Logging[​](#logging "Direct link to Logging")

#### `GLOBAL_LOG_LEVEL`[​](#global%5Flog%5Flevel "Direct link to global_log_level")

* Type: `str`
* Default: `INFO`
* Description: Sets the global logging level for all Open WebUI components. Valid values: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`.

#### `LOG_FORMAT`[​](#log%5Fformat "Direct link to log_format")

* Type: `str`
* Default: Not set (plain-text logging)
* Description: Controls the log output format. Set to `json` to switch all stdout logging to single-line JSON objects, suitable for log aggregators like Loki, Fluentd, CloudWatch, and Datadog. When set to `json`, the ASCII startup banner is also suppressed to keep the log stream parseable. Any other value (or unset) uses the default plain-text format. See the [JSON Logging documentation](/getting-started/advanced-topics/logging#structured-json-logging) for details on log fields and examples.

#### `ENABLE_AUDIT_STDOUT`[​](#enable%5Faudit%5Fstdout "Direct link to enable_audit_stdout")

* Type: `bool`
* Default: `False`
* Description: Controls whether audit logs are output to stdout (console). Useful for containerized environments where logs are collected from stdout.

#### `ENABLE_AUDIT_LOGS_FILE`[​](#enable%5Faudit%5Flogs%5Ffile "Direct link to enable_audit_logs_file")

* Type: `bool`
* Default: `True`
* Description: Controls whether audit logs are written to a file. When enabled, logs are written to the location specified by `AUDIT_LOGS_FILE_PATH`.

#### `AUDIT_LOGS_FILE_PATH`[​](#audit%5Flogs%5Ffile%5Fpath "Direct link to audit_logs_file_path")

* Type: `str`
* Default: `${DATA_DIR}/audit.log`
* Description: Configures where the audit log file is stored. Enables storing logs in separate volumes or custom locations for better organization and persistence.
* Example: `/var/log/openwebui/audit.log`, `/mnt/logs/audit.log`

#### `AUDIT_LOG_FILE_ROTATION_SIZE`[​](#audit%5Flog%5Ffile%5Frotation%5Fsize "Direct link to audit_log_file_rotation_size")

* Type: `str`
* Default: `10MB`
* Description: Specifies the maximum size of the audit log file before rotation occurs (e.g., `10MB`, `100MB`, `1GB`).

#### `AUDIT_UVICORN_LOGGER_NAMES`[​](#audit%5Fuvicorn%5Flogger%5Fnames "Direct link to audit_uvicorn_logger_names")

* Type: `str`
* Default: `uvicorn.access`
* Description: Comma-separated list of logger names to capture for audit logging. Defaults to Uvicorn's access logger.

#### `AUDIT_LOG_LEVEL`[​](#audit%5Flog%5Flevel "Direct link to audit_log_level")

* Type: `str`
* Default: `NONE`
* Options: `NONE`, `METADATA`, `REQUEST`, `REQUEST_RESPONSE`
* Description: Controls the verbosity level of audit logging. `METADATA` logs basic request info, `REQUEST` includes request bodies, `REQUEST_RESPONSE` includes both requests and responses.

#### `MAX_BODY_LOG_SIZE`[​](#max%5Fbody%5Flog%5Fsize "Direct link to max_body_log_size")

* Type: `int`
* Default: `2048`
* Description: Sets the maximum size in bytes for request/response bodies in audit logs. Bodies larger than this are truncated.

#### `AUDIT_EXCLUDED_PATHS`[​](#audit%5Fexcluded%5Fpaths "Direct link to audit_excluded_paths")

* Type: `str`
* Default: `/chats,/chat,/folders`
* Description: Comma-separated list of URL paths to exclude from audit logging (blacklist mode). Paths are matched without leading slashes against `/api/` and `/api/v1/` prefixed routes. Ignored when `AUDIT_INCLUDED_PATHS` is set.

#### `AUDIT_INCLUDED_PATHS`[​](#audit%5Fincluded%5Fpaths "Direct link to audit_included_paths")

* Type: `str`
* Default: Empty string (disabled)
* Description: Comma-separated list of URL paths to include in audit logging (whitelist mode). When set, **only** matching paths are audited and `AUDIT_EXCLUDED_PATHS` is ignored. Paths are matched without leading slashes against `/api/` and `/api/v1/` prefixed routes. Auth endpoints (signin, signout, signup) are always logged regardless of filtering mode.

Whitelist vs Blacklist

By default, audit logging uses **blacklist mode** — all paths are logged except those in `AUDIT_EXCLUDED_PATHS`. If you set `AUDIT_INCLUDED_PATHS`, it switches to **whitelist mode** — only the specified paths are logged. If both are set, whitelist mode takes precedence and a warning is logged at startup.

### Ollama[​](#ollama "Direct link to Ollama")

#### `ENABLE_OLLAMA_API`[​](#enable%5Follama%5Fapi "Direct link to enable_ollama_api")

* Type: `bool`
* Default: `True`
* Description: Enables the use of Ollama APIs.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `OLLAMA_BASE_URL` (`OLLAMA_API_BASE_URL` is deprecated)[​](#ollama%5Fbase%5Furl "Direct link to ollama_base_url")

* Type: `str`
* Default: `http://localhost:11434`
* Docker Default:  
   * If `K8S_FLAG` is set: `http://ollama-service.open-webui.svc.cluster.local:11434`  
   * If `USE_OLLAMA_DOCKER=True`: `http://localhost:11434`  
   * Else `http://host.docker.internal:11434`
* Description: Configures the Ollama backend URL.

#### `OLLAMA_BASE_URLS`[​](#ollama%5Fbase%5Furls "Direct link to ollama_base_urls")

* Type: `str`
* Description: Configures load-balanced Ollama backend hosts, separated by `;`. See[OLLAMA\_BASE\_URL](#ollama%5Fbase%5Furl). Takes precedence over[OLLAMA\_BASE\_URL](#ollama%5Fbase%5Furl).
* Example: `http://host-one:11434;http://host-two:11434`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `USE_OLLAMA_DOCKER`[​](#use%5Follama%5Fdocker "Direct link to use_ollama_docker")

* Type: `bool`
* Default: `False`
* Description: Builds the Docker image with a bundled Ollama instance.

#### `K8S_FLAG`[​](#k8s%5Fflag "Direct link to k8s_flag")

* Type: `bool`
* Default: `False`
* Description: If set, assumes Helm chart deployment and sets [OLLAMA\_BASE\_URL](#ollama%5Fbase%5Furl) to `http://ollama-service.open-webui.svc.cluster.local:11434`

### OpenAI[​](#openai "Direct link to OpenAI")

#### `ENABLE_OPENAI_API`[​](#enable%5Fopenai%5Fapi "Direct link to enable_openai_api")

* Type: `bool`
* Default: `True`
* Description: Enables the use of OpenAI APIs.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `OPENAI_API_BASE_URL`[​](#openai%5Fapi%5Fbase%5Furl "Direct link to openai_api_base_url")

* Type: `str`
* Default: `https://api.openai.com/v1`
* Description: Configures the OpenAI base API URL.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `OPENAI_API_BASE_URLS`[​](#openai%5Fapi%5Fbase%5Furls "Direct link to openai_api_base_urls")

* Type: `str`
* Description: Supports balanced OpenAI base API URLs, semicolon-separated.
* Example: `http://host-one:11434;http://host-two:11434`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `OPENAI_API_KEY`[​](#openai%5Fapi%5Fkey "Direct link to openai_api_key")

* Type: `str`
* Description: Sets the OpenAI API key.
* Example: `sk-124781258123`
* Persistence: This environment variable is a `PersistentConfig` variable.

Provider Key Scope (Important)

For OpenAI-compatible backends and proxies (including LiteLLM), configure least-privilege keys for regular user traffic whenever possible.

Do not use provider management/master keys unless your deployment explicitly requires that trust level.

#### `OPENAI_API_KEYS`[​](#openai%5Fapi%5Fkeys "Direct link to openai_api_keys")

* Type: `str`
* Description: Supports multiple OpenAI API keys, semicolon-separated.
* Example: `sk-124781258123;sk-4389759834759834`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_OPENAI_API_PASSTHROUGH`[​](#enable%5Fopenai%5Fapi%5Fpassthrough "Direct link to enable_openai_api_passthrough")

* Type: `bool`
* Default: `False`
* Description: When enabled, the OpenAI proxy's catch-all endpoint (`/{path:path}`) forwards any request to the upstream OpenAI-compatible API using the admin-configured API key and without additional access control. When disabled (default), the catch-all returns `403 Forbidden`. Other routers (Ollama, Responses) do not have catch-all proxies.

danger

**Keep this disabled unless you explicitly need it.** The catch-all proxy forwards requests to the upstream API using the admin's API key with no model-level access control. Any authenticated user can reach any upstream endpoint — including endpoints not natively handled by Open WebUI — using the admin's credentials. Only enable this if you understand and accept these implications.

### Tasks[​](#tasks "Direct link to Tasks")

#### `TASK_MODEL`[​](#task%5Fmodel "Direct link to task_model")

* Type: `str`
* Description: The default model to use for tasks such as title and web search query generation when using Ollama models.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `TASK_MODEL_EXTERNAL`[​](#task%5Fmodel%5Fexternal "Direct link to task_model_external")

* Type: `str`
* Description: The default model to use for tasks such as title and web search query generation when using OpenAI-compatible endpoints.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `TITLE_GENERATION_PROMPT_TEMPLATE`[​](#title%5Fgeneration%5Fprompt%5Ftemplate "Direct link to title_generation_prompt_template")

* Type: `str`
* Description: Prompt to use when generating chat titles.
* Default: The value of `DEFAULT_TITLE_GENERATION_PROMPT_TEMPLATE` environment variable.

`DEFAULT_TITLE_GENERATION_PROMPT_TEMPLATE`:

```

### Task:
Generate a concise, 3-5 word title with an emoji summarizing the chat history.

### Guidelines:
- The title should clearly represent the main theme or subject of the conversation.
- Use emojis that enhance understanding of the topic, but avoid quotation marks or special formatting.
- Write the title in the chat's primary language; default to English if multilingual.
- Prioritize accuracy over excessive creativity; keep it clear and simple.

### Output:
JSON format: { "title": "your concise title here" }

### Examples:
- { "title": "📉 Stock Market Trends" },
- { "title": "🍪 Perfect Chocolate Chip Recipe" },
- { "title": "Evolution of Music Streaming" },
- { "title": "Remote Work Productivity Tips" },
- { "title": "Artificial Intelligence in Healthcare" },
- { "title": "🎮 Video Game Development Insights" }

### Chat History:
<chat_history>
{{MESSAGES:END:2}}
</chat_history>

```

* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_FOLLOW_UP_GENERATION`[​](#enable%5Ffollow%5Fup%5Fgeneration "Direct link to enable_follow_up_generation")

* Type: `bool`
* Default: `True`
* Description: Enables or disables follow up generation.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `FOLLOW_UP_GENERATION_PROMPT_TEMPLATE`[​](#follow%5Fup%5Fgeneration%5Fprompt%5Ftemplate "Direct link to follow_up_generation_prompt_template")

* Type: `str`
* Description: Prompt to use for generating several relevant follow-up questions.
* Default: The value of `DEFAULT_FOLLOW_UP_GENERATION_PROMPT_TEMPLATE` environment variable.

`DEFAULT_FOLLOW_UP_GENERATION_PROMPT_TEMPLATE`:

```

### Task:
Suggest 3-5 relevant follow-up questions or prompts that the user might naturally ask next in this conversation as a **user**, based on the chat history, to help continue or deepen the discussion.

### Guidelines:
- Write all follow-up questions from the user’s point of view, directed to the assistant.
- Make questions concise, clear, and directly related to the discussed topic(s).
- Only suggest follow-ups that make sense given the chat content and do not repeat what was already covered.
- If the conversation is very short or not specific, suggest more general (but relevant) follow-ups the user might ask.
- Use the conversation's primary language; default to English if multilingual.
- Response must be a JSON array of strings, no extra text or formatting.

### Output:
JSON format: { "follow_ups": ["Question 1?", "Question 2?", "Question 3?"] }

### Chat History:
<chat_history>
{{MESSAGES:END:6}}
</chat_history>"

```

* Persistence: This environment variable is a `PersistentConfig` variable.

#### `TOOLS_FUNCTION_CALLING_PROMPT_TEMPLATE`[​](#tools%5Ffunction%5Fcalling%5Fprompt%5Ftemplate "Direct link to tools_function_calling_prompt_template")

* Type: `str`
* Description: Prompt to use when calling tools.
* Default: The value of `DEFAULT_TOOLS_FUNCTION_CALLING_PROMPT_TEMPLATE` environment variable.

`DEFAULT_TOOLS_FUNCTION_CALLING_PROMPT_TEMPLATE`:

```
Available Tools: {{TOOLS}}

Your task is to choose and return the correct tool(s) from the list of available tools based on the query. Follow these guidelines:

- Return only the JSON object, without any additional text or explanation.

- If no tools match the query, return an empty array:
   {
     "tool_calls": []
   }

- If one or more tools match the query, construct a JSON response containing a "tool_calls" array with objects that include:
   - "name": The tool's name.
   - "parameters": A dictionary of required parameters and their corresponding values.

The format for the JSON response is strictly:
{
  "tool_calls": [
    {"name": "toolName1", "parameters": {"key1": "value1"}},
    {"name": "toolName2", "parameters": {"key2": "value2"}}
  ]
}

```

* Persistence: This environment variable is a `PersistentConfig` variable.

### Code Execution[​](#code-execution "Direct link to Code Execution")

#### `ENABLE_CODE_EXECUTION`[​](#enable%5Fcode%5Fexecution "Direct link to enable_code_execution")

* Type: `bool`
* Default: `True`
* Description: Enables or disables code execution.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_EXECUTION_ENGINE`[​](#code%5Fexecution%5Fengine "Direct link to code_execution_engine")

* Type: `str`
* Default: `pyodide`
* Description: Specifies the code execution engine to use.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_EXECUTION_JUPYTER_URL`[​](#code%5Fexecution%5Fjupyter%5Furl "Direct link to code_execution_jupyter_url")

* Type: `str`
* Default: `None`
* Description: Specifies the Jupyter URL to use for code execution.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_EXECUTION_JUPYTER_AUTH`[​](#code%5Fexecution%5Fjupyter%5Fauth "Direct link to code_execution_jupyter_auth")

* Type: `str`
* Default: `None`
* Description: Specifies the Jupyter authentication method to use for code execution.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_EXECUTION_JUPYTER_AUTH_TOKEN`[​](#code%5Fexecution%5Fjupyter%5Fauth%5Ftoken "Direct link to code_execution_jupyter_auth_token")

* Type: `str`
* Default: `None`
* Description: Specifies the Jupyter authentication token to use for code execution.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_EXECUTION_JUPYTER_AUTH_PASSWORD`[​](#code%5Fexecution%5Fjupyter%5Fauth%5Fpassword "Direct link to code_execution_jupyter_auth_password")

* Type: `str`
* Default: `None`
* Description: Specifies the Jupyter authentication password to use for code execution.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_EXECUTION_JUPYTER_TIMEOUT`[​](#code%5Fexecution%5Fjupyter%5Ftimeout "Direct link to code_execution_jupyter_timeout")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the timeout for Jupyter code execution.
* Persistence: This environment variable is a `PersistentConfig` variable.

### Code Interpreter[​](#code-interpreter "Direct link to Code Interpreter")

#### `ENABLE_CODE_INTERPRETER`[​](#enable%5Fcode%5Finterpreter "Direct link to enable_code_interpreter")

* Type: `bool`
* Default: `True`
* Description: Enables or disables code interpreter.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_INTERPRETER_ENGINE`[​](#code%5Finterpreter%5Fengine "Direct link to code_interpreter_engine")

* Type: `str`
* Default: `pyodide`
* Description: Specifies the code interpreter engine to use.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_INTERPRETER_BLACKLISTED_MODULES`[​](#code%5Finterpreter%5Fblacklisted%5Fmodules "Direct link to code_interpreter_blacklisted_modules")

* Type: `str` (comma-separated list of module names)
* Default: None
* Description: Specifies a comma-separated list of Python modules that are blacklisted and cannot be imported or used within the code interpreter. This enhances security by preventing access to potentially sensitive or system-level functionalities.

#### `CODE_INTERPRETER_PROMPT_TEMPLATE`[​](#code%5Finterpreter%5Fprompt%5Ftemplate "Direct link to code_interpreter_prompt_template")

* Type: `str`
* Default: `None`
* Description: Specifies the prompt template to use for code interpreter.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_INTERPRETER_JUPYTER_URL`[​](#code%5Finterpreter%5Fjupyter%5Furl "Direct link to code_interpreter_jupyter_url")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the Jupyter URL to use for code interpreter.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_INTERPRETER_JUPYTER_AUTH`[​](#code%5Finterpreter%5Fjupyter%5Fauth "Direct link to code_interpreter_jupyter_auth")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the Jupyter authentication method to use for code interpreter.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_INTERPRETER_JUPYTER_AUTH_TOKEN`[​](#code%5Finterpreter%5Fjupyter%5Fauth%5Ftoken "Direct link to code_interpreter_jupyter_auth_token")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the Jupyter authentication token to use for code interpreter.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_INTERPRETER_JUPYTER_AUTH_PASSWORD`[​](#code%5Finterpreter%5Fjupyter%5Fauth%5Fpassword "Direct link to code_interpreter_jupyter_auth_password")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the Jupyter authentication password to use for code interpreter.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CODE_INTERPRETER_JUPYTER_TIMEOUT`[​](#code%5Finterpreter%5Fjupyter%5Ftimeout "Direct link to code_interpreter_jupyter_timeout")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the timeout for the Jupyter code interpreter.
* Persistence: This environment variable is a `PersistentConfig` variable.

### Direct Connections (OpenAPI/MCPO Tool Servers)[​](#direct-connections-openapimcpo-tool-servers "Direct link to Direct Connections (OpenAPI/MCPO Tool Servers)")

#### `ENABLE_DIRECT_CONNECTIONS`[​](#enable%5Fdirect%5Fconnections "Direct link to enable_direct_connections")

* Type: `bool`
* Default: `True`
* Description: Enables or disables direct connections.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `TOOL_SERVER_CONNECTIONS`[​](#tool%5Fserver%5Fconnections "Direct link to tool_server_connections")

* Type: `str` (JSON array)
* Default: `[]`
* Description: Specifies a JSON array of tool server connection configurations. Each connection should define the necessary parameters to connect to external tool servers that implement the OpenAPI/MCPO protocol. For mcpo-backed routes, `path` should point at the mounted tool route. The JSON must be properly formatted or it will fallback to an empty array.
* Field reference:  
   * `url`: the server base URL.  
   * `path`: the specific tool route exposed by the server.  
   * `auth_type`: the authentication mode for the connection.  
   * `key`: the API key or token used by the selected auth mode.  
   * `config`: per-connection configuration object, such as `{ "enable": true }`.  
   * `info`: optional metadata shown in the UI, such as the connection name and description.  
   * `spec_type` / `spec`: OpenAPI spec location details when the connection is backed by a spec URL or file.
* Example:

```
[
  {
    "type": "openapi",
    "url": "example-url",
    "spec_type": "url",
    "spec": "",
    "path": "openapi.json",
    "auth_type": "none",
    "key": "",
    "config": { "enable": true },
    "info": {
      "id": "",
      "name": "example-server",
      "description": "MCP server description."
    }
  }
]
```

* Persistence: This environment variable is a `PersistentConfig` variable.

warning

The JSON data structure of `TOOL_SERVER_CONNECTIONS` might evolve over time as new features are added.

### Terminal Server[​](#terminal-server "Direct link to Terminal Server")

#### `TERMINAL_SERVER_CONNECTIONS`[​](#terminal%5Fserver%5Fconnections "Direct link to terminal_server_connections")

* Type: `str` (JSON array)
* Default: `[]`
* Description: Specifies a JSON array of terminal server connection configurations. Each connection defines the parameters needed to connect to an [Open Terminal](/features/open-terminal) instance or a [Terminals orchestrator](/features/open-terminal/terminals/). Unlike user-level tool server connections, these are admin-configured and proxied through Open WebUI, which means the terminal URL and API key are never exposed to the browser. Supports group-based access control via `access_grants`.
* Example (direct Open Terminal connection):

```
[
  {
    "id": "unique-id",
    "url": "http://open-terminal:8000",
    "key": "your-api-key",
    "name": "Dev Terminal",
    "auth_type": "bearer",
    "config": {
      "access_grants": []
    }
  }
]
```

* Example (Terminals orchestrator connection):

```
[
  {
    "id": "terminals",
    "url": "http://terminals-orchestrator:8080",
    "key": "your-api-key",
    "name": "Terminals",
    "auth_type": "bearer",
    "config": {
      "access_grants": [
        {"principal_type": "user", "principal_id": "*", "permission": "read"}
      ]
    }
  }
]
```

* Persistence: This environment variable is a `PersistentConfig` variable.

Helm chart auto-configuration

When deploying on Kubernetes with the Open WebUI Helm chart and `terminals.enabled: true`, this variable is set automatically to point at the in-cluster orchestrator service. See the [Terminals (Orchestrator) guide](/features/open-terminal/terminals/) for details.

warning

The JSON data structure of `TERMINAL_SERVER_CONNECTIONS` might evolve over time as new features are added.

### Autocomplete[​](#autocomplete "Direct link to Autocomplete")

#### `ENABLE_AUTOCOMPLETE_GENERATION`[​](#enable%5Fautocomplete%5Fgeneration "Direct link to enable_autocomplete_generation")

* Type: `bool`
* Default: `True`
* Description: Enables or disables autocomplete generation.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

When enabling `ENABLE_AUTOCOMPLETE_GENERATION`, ensure that you also configure `AUTOCOMPLETE_GENERATION_INPUT_MAX_LENGTH` and `AUTOCOMPLETE_GENERATION_PROMPT_TEMPLATE` accordingly.

#### `AUTOCOMPLETE_GENERATION_INPUT_MAX_LENGTH`[​](#autocomplete%5Fgeneration%5Finput%5Fmax%5Flength "Direct link to autocomplete_generation_input_max_length")

* Type: `int`
* Default: `-1`
* Description: Sets the maximum input length for autocomplete generation.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `AUTOCOMPLETE_GENERATION_PROMPT_TEMPLATE`[​](#autocomplete%5Fgeneration%5Fprompt%5Ftemplate "Direct link to autocomplete_generation_prompt_template")

* Type: `str`
* Default: The value of the `DEFAULT_AUTOCOMPLETE_GENERATION_PROMPT_TEMPLATE` environment variable.

`DEFAULT_AUTOCOMPLETE_GENERATION_PROMPT_TEMPLATE`:

```

### Task:
You are an autocompletion system. Continue the text in `<text>` based on the **completion type** in `<type>` and the given language.

### **Instructions**:
1. Analyze `<text>` for context and meaning.
2. Use `<type>` to guide your output:
   - **General**: Provide a natural, concise continuation.
   - **Search Query**: Complete as if generating a realistic search query.
3. Start as if you are directly continuing `<text>`. Do **not** repeat, paraphrase, or respond as a model. Simply complete the text.
4. Ensure the continuation:
   - Flows naturally from `<text>`.
   - Avoids repetition, overexplaining, or unrelated ideas.
5. If unsure, return: `{ "text": "" }`.

### **Output Rules**:
- Respond only in JSON format: `{ "text": "<your_completion>" }`.

### **Examples**:

#### Example 1:
Input:
<type>General</type>
<text>The sun was setting over the horizon, painting the sky</text>
Output:
{ "text": "with vibrant shades of orange and pink." }

#### Example 2:
Input:
<type>Search Query</type>
<text>Top-rated restaurants in</text>
Output:
{ "text": "New York City for Italian cuisine." }

---

### Context:
<chat_history>
{{MESSAGES:END:6}}
</chat_history>
<type>{{TYPE}}</type>
<text>{{PROMPT}}</text>

#### Output:

```

* Description: Sets the prompt template for autocomplete generation.
* Persistence: This environment variable is a `PersistentConfig` variable.

### Evaluation Arena Model[​](#evaluation-arena-model "Direct link to Evaluation Arena Model")

#### `ENABLE_EVALUATION_ARENA_MODELS`[​](#enable%5Fevaluation%5Farena%5Fmodels "Direct link to enable_evaluation_arena_models")

* Type: `bool`
* Default: `True`
* Description: Enables or disables evaluation arena models.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_MESSAGE_RATING`[​](#enable%5Fmessage%5Frating "Direct link to enable_message_rating")

* Type: `bool`
* Default: `True`
* Description: Enables message rating feature.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_COMMUNITY_SHARING`[​](#enable%5Fcommunity%5Fsharing "Direct link to enable_community_sharing")

* Type: `bool`
* Default: `True`
* Description: Controls whether users can share content with the Open WebUI Community and access community resources. When enabled, this setting shows the following UI elements across the application:  
   * **Prompts Workspace**: "Made by Open WebUI Community" section with a link to discover community prompts, and a "Share" button in the prompt menu dropdown  
   * **Tools Workspace**: "Made by Open WebUI Community" section with a link to discover community tools, and a "Share" button in the tool menu dropdown  
   * **Models Workspace**: "Made by Open WebUI Community" section with a link to discover community model presets, and a "Share" button in the model menu dropdown  
   * **Functions Admin**: "Made by Open WebUI Community" section with a link to discover community functions  
   * **Share Chat Modal**: "Share to Open WebUI Community" button when sharing a chat conversation  
   * **Evaluation Feedbacks**: "Share to Open WebUI Community" button for contributing feedback history to the community leaderboard  
   * **Stats Sync Modal**: Enables syncing usage statistics with the community
* Persistence: This environment variable is a `PersistentConfig` variable.

info

When `ENABLE_COMMUNITY_SHARING` is set to `False`, all community sharing buttons and community resource discovery sections will be hidden from the UI. Users will still be able to export content locally, but the option to share directly to the Open WebUI Community will not be available.

### Tags Generation[​](#tags-generation "Direct link to Tags Generation")

#### `ENABLE_TAGS_GENERATION`[​](#enable%5Ftags%5Fgeneration "Direct link to enable_tags_generation")

* Type: `bool`
* Default: `True`
* Description: Enables or disables tag generation.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `TAGS_GENERATION_PROMPT_TEMPLATE`[​](#tags%5Fgeneration%5Fprompt%5Ftemplate "Direct link to tags_generation_prompt_template")

* Type: `str`
* Default: The value of `DEFAULT_TAGS_GENERATION_PROMPT_TEMPLATE` environment variable.

`DEFAULT_TAGS_GENERATION_PROMPT_TEMPLATE`:

```

### Task:
Generate 1-3 broad tags categorizing the main themes of the chat history, along with 1-3 more specific subtopic tags.

### Guidelines:
- Start with high-level domains (e.g., Science, Technology, Philosophy, Arts, Politics, Business, Health, Sports, Entertainment, Education)
- Consider including relevant subfields/subdomains if they are strongly represented throughout the conversation
- If content is too short (less than 3 messages) or too diverse, use only ["General"]
- Use the chat's primary language; default to English if multilingual
- Prioritize accuracy over specificity

### Output:
JSON format: { "tags": ["tag1", "tag2", "tag3"] }

### Chat History:
<chat_history>
{{MESSAGES:END:6}}
</chat_history>

```

* Description: Sets the prompt template for tag generation.
* Persistence: This environment variable is a `PersistentConfig` variable.

### API Key Endpoint Restrictions[​](#api-key-endpoint-restrictions "Direct link to API Key Endpoint Restrictions")

#### `ENABLE_API_KEYS`[​](#enable%5Fapi%5Fkeys "Direct link to enable_api_keys")

* Type: `bool`
* Default: `False`
* Description: Enables the API key creation feature, allowing users to generate API keys for programmatic access to Open WebUI.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

This variable replaces the deprecated `ENABLE_API_KEY` environment variable.

info

For API Key creation (and the API keys themselves) to work:

1. Enable API keys globally using this setting (`ENABLE_API_KEYS`)
2. For non-admin users, grant the "API Keys" permission via Default Permissions or User Groups

**Note:** Administrators can generate API keys whenever `ENABLE_API_KEYS` is enabled, even without `features.api_keys`.

#### `ENABLE_API_KEYS_ENDPOINT_RESTRICTIONS`[​](#enable%5Fapi%5Fkeys%5Fendpoint%5Frestrictions "Direct link to enable_api_keys_endpoint_restrictions")

* Type: `bool`
* Default: `False`
* Description: Enables API key endpoint restrictions for added security and configurability, allowing administrators to limit which endpoints can be accessed using API keys.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

This variable replaces the deprecated `ENABLE_API_KEY_ENDPOINT_RESTRICTIONS` environment variable.

#### `API_KEYS_ALLOWED_ENDPOINTS`[​](#api%5Fkeys%5Fallowed%5Fendpoints "Direct link to api_keys_allowed_endpoints")

* Type: `str`
* Description: Specifies a comma-separated list of allowed API endpoints when API key endpoint restrictions are enabled.
* Example: `/api/v1/messages,/api/v1/channels,/api/v1/chat/completions`
* Persistence: This environment variable is a `PersistentConfig` variable.

note

The value of `API_KEYS_ALLOWED_ENDPOINTS` should be a comma-separated list of endpoint URLs, such as `/api/v1/messages, /api/v1/channels`.

info

This variable replaces the deprecated `API_KEY_ALLOWED_ENDPOINTS` environment variable.

#### `CUSTOM_API_KEY_HEADER`[​](#custom%5Fapi%5Fkey%5Fheader "Direct link to custom_api_key_header")

* Type: `str`
* Default: `x-api-key`
* Description: Name of the HTTP header the auth middleware checks for API-key credentials. Useful when Open WebUI sits behind a reverse proxy or API gateway that consumes the `Authorization` header for its own authentication — set this to a distinct header (for example `X-OpenWebUI-Key`) so clients can deliver their Open WebUI API key without colliding with the proxy's own auth.
* Read at startup from the process environment (not a `PersistentConfig`).

**How the auth middleware picks up a credential**, in order:

1. `Authorization: Bearer <token>` (most common — API key or JWT)
2. `token` cookie (Bearer — used by the WebUI itself)
3. The header named by `CUSTOM_API_KEY_HEADER` (default `x-api-key`)

If none of the three is present, the request falls through as anonymous.

Behind a proxy that eats `Authorization`?

Many corporate gateways (basic auth, mutual TLS adapters, SSO sidecars) consume the `Authorization` header and never forward it upstream. In that case, point your clients at the custom header instead:

```
curl -H "X-OpenWebUI-Key: sk-..." http://openwebui.internal/api/models
```

And set on the Open WebUI container:

```
CUSTOM_API_KEY_HEADER=X-OpenWebUI-Key

```

The header name is matched case-insensitively by the ASGI layer, so pick whatever fits your naming convention.

### Model Caching[​](#model-caching "Direct link to Model Caching")

#### `ENABLE_BASE_MODELS_CACHE`[​](#enable%5Fbase%5Fmodels%5Fcache "Direct link to enable_base_models_cache")

* Type: `bool`
* Default: `False`
* Description: When enabled, caches the list of base models from connected Ollama and OpenAI-compatible endpoints in memory. This reduces the number of API calls made to external model providers when loading the model selector, improving performance particularly for deployments with many users or slow connections to model endpoints. Can also be configured from Admin Panel > Settings > Connections > "Cache Base Model List".
* Persistence: This environment variable is a `PersistentConfig` variable.

**How the cache works:**

* **Initialization**: When enabled, base models are fetched and cached during application startup.
* **Storage**: The cache is stored in application memory (`app.state.BASE_MODELS`).
* **Cache Hit**: Subsequent requests for models return the cached list without contacting external endpoints.
* **Cache Refresh**: The cache is refreshed when:  
   * The application restarts  
   * The connection settings are saved in the **Admin Panel > Settings > Connections** (clicking the **Save** button on the bottom right will trigger a refresh and update the cache with the newly fetched models)
* **No TTL**: There is no automatic time-based expiration.

Performance Consideration

Enable this setting in production environments where model lists are relatively stable. For development environments or when frequently adding/removing models from Ollama, you may prefer to leave it disabled for real-time model discovery.

#### `MODELS_CACHE_TTL`[​](#models%5Fcache%5Fttl "Direct link to models_cache_ttl")

* Type: `int`
* Default: `1`
* Description: Sets the cache time-to-live in seconds for model list responses from OpenAI and Ollama endpoints. This reduces API calls by caching the available models list for the specified duration. Set to empty string to disable caching entirely.

This caches the external model lists retrieved from configured OpenAI-compatible and Ollama API endpoints (not Open WebUI's internal model configurations). Higher values improve performance by reducing redundant API requests to external providers but may delay visibility of newly added or removed models on those endpoints. A value of 0 disables caching and forces fresh API calls each time.

High-Traffic Recommendation

In high-traffic scenarios, increasing this value (e.g., to 300 seconds) can significantly reduce load on external API endpoints while still providing reasonably fresh model data.

Two Caching Mechanisms

Open WebUI has **two model caching mechanisms** that work independently:

| Setting                     | Type      | Default  | Refresh Trigger             |
| --------------------------- | --------- | -------- | --------------------------- |
| ENABLE\_BASE\_MODELS\_CACHE | In-memory | False    | App restart OR Admin Save   |
| MODELS\_CACHE\_TTL          | TTL-based | 1 second | Automatic after TTL expires |

For maximum performance, enable both: `ENABLE_BASE_MODELS_CACHE=True` with `MODELS_CACHE_TTL=300`.

#### `JWT_EXPIRES_IN`[​](#jwt%5Fexpires%5Fin "Direct link to jwt_expires_in")

* Type: `str`
* Default: `4w`
* Description: Sets the JWT expiration time in seconds. Valid time units: `s`, `m`, `h`, `d`, `w` or `-1` for no expiration.
* Persistence: This environment variable is a `PersistentConfig` variable.

warning

Setting `JWT_EXPIRES_IN` to `-1` disables JWT expiration, making issued tokens valid forever. **This is extremely dangerous in production** and exposes your system to severe security risks if tokens are leaked or compromised.

**Always set a reasonable expiration time in production environments (e.g., `3600s`, `1h`, `7d` etc.) to limit the lifespan of authentication tokens.**

**NEVER use `-1` in a production environment.**

If you have already deployed with `JWT_EXPIRES_IN=-1`, you can rotate or change your `WEBUI_SECRET_KEY` to immediately invalidate all existing tokens.

## Security Variables[​](#security-variables "Direct link to Security Variables")

#### `ENABLE_FORWARD_USER_INFO_HEADERS`[​](#enable%5Fforward%5Fuser%5Finfo%5Fheaders "Direct link to enable_forward_user_info_headers")

* type: `bool`
* Default: `False`
* Description: Forwards user and session information as HTTP headers to OpenAI API, Ollama API, MCP servers, and Tool servers. If enabled, the following headers are forwarded:  
   * `X-OpenWebUI-User-Name`  
   * `X-OpenWebUI-User-Id`  
   * `X-OpenWebUI-User-Email`  
   * `X-OpenWebUI-User-Role`  
   * `X-OpenWebUI-Chat-Id`  
   * `X-OpenWebUI-Message-Id`

This enables per-user authorization, auditing, rate limiting, and request tracing on external services. The chat and message ID headers are also required for [external tool event emitting](/features/extensibility/plugin/development/events#-external-tool-events).

#### `FORWARD_USER_INFO_HEADER_USER_NAME`[​](#forward%5Fuser%5Finfo%5Fheader%5Fuser%5Fname "Direct link to forward_user_info_header_user_name")

* Type: `str`
* Default: `X-OpenWebUI-User-Name`
* Description: Customizes the header name used to forward the user's display name. Change this if your infrastructure requires a specific header prefix.

#### `FORWARD_USER_INFO_HEADER_USER_ID`[​](#forward%5Fuser%5Finfo%5Fheader%5Fuser%5Fid "Direct link to forward_user_info_header_user_id")

* Type: `str`
* Default: `X-OpenWebUI-User-Id`
* Description: Customizes the header name used to forward the user's ID.

#### `FORWARD_USER_INFO_HEADER_USER_EMAIL`[​](#forward%5Fuser%5Finfo%5Fheader%5Fuser%5Femail "Direct link to forward_user_info_header_user_email")

* Type: `str`
* Default: `X-OpenWebUI-User-Email`
* Description: Customizes the header name used to forward the user's email address.

#### `FORWARD_USER_INFO_HEADER_USER_ROLE`[​](#forward%5Fuser%5Finfo%5Fheader%5Fuser%5Frole "Direct link to forward_user_info_header_user_role")

* Type: `str`
* Default: `X-OpenWebUI-User-Role`
* Description: Customizes the header name used to forward the user's role.

#### `FORWARD_SESSION_INFO_HEADER_CHAT_ID`[​](#forward%5Fsession%5Finfo%5Fheader%5Fchat%5Fid "Direct link to forward_session_info_header_chat_id")

* Type: `str`
* Default: `X-OpenWebUI-Chat-Id`
* Description: Customizes the header name used to forward the current chat/session ID.

#### `FORWARD_SESSION_INFO_HEADER_MESSAGE_ID`[​](#forward%5Fsession%5Finfo%5Fheader%5Fmessage%5Fid "Direct link to forward_session_info_header_message_id")

* Type: `str`
* Default: `X-OpenWebUI-Message-Id`
* Description: Customizes the header name used to forward the current message ID. This header is required for [external tool event emitting](/features/extensibility/plugin/development/events#-external-tool-events).

Custom Header Prefix

Use these variables when integrating with services that require specific header naming conventions. For example, AWS Bedrock AgentCore requires headers prefixed with `X-Amzn-Bedrock-AgentCore-Runtime-Custom-`:

```
FORWARD_USER_INFO_HEADER_USER_NAME=X-Amzn-Bedrock-AgentCore-Runtime-Custom-User-Name
FORWARD_USER_INFO_HEADER_USER_ID=X-Amzn-Bedrock-AgentCore-Runtime-Custom-User-Id
FORWARD_USER_INFO_HEADER_USER_EMAIL=X-Amzn-Bedrock-AgentCore-Runtime-Custom-User-Email
FORWARD_USER_INFO_HEADER_USER_ROLE=X-Amzn-Bedrock-AgentCore-Runtime-Custom-User-Role
FORWARD_SESSION_INFO_HEADER_CHAT_ID=X-Amzn-Bedrock-AgentCore-Runtime-Custom-Chat-Id
FORWARD_SESSION_INFO_HEADER_MESSAGE_ID=X-Amzn-Bedrock-AgentCore-Runtime-Custom-Message-Id
```

#### `ENABLE_WEB_LOADER_SSL_VERIFICATION`[​](#enable%5Fweb%5Floader%5Fssl%5Fverification "Direct link to enable_web_loader_ssl_verification")

* Type: `bool`
* Default: `True`
* Description: Bypass SSL Verification for RAG on Websites.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `WEBUI_SESSION_COOKIE_SAME_SITE`[​](#webui%5Fsession%5Fcookie%5Fsame%5Fsite "Direct link to webui_session_cookie_same_site")

* Type: `str`
* Options:  
   * `lax` \- Sets the `SameSite` attribute to lax, allowing session cookies to be sent with requests initiated by third-party websites.  
   * `strict` \- Sets the `SameSite` attribute to strict, blocking session cookies from being sent with requests initiated by third-party websites.  
   * `none` \- Sets the `SameSite` attribute to none, allowing session cookies to be sent with requests initiated by third-party websites, but only over HTTPS.
* Default: `lax`
* Description: Sets the `SameSite` attribute for session cookies.

warning

When `ENABLE_OAUTH_SIGNUP` is enabled, setting `WEBUI_SESSION_COOKIE_SAME_SITE` to `strict` can cause login failures. This is because Open WebUI uses a session cookie to validate the callback from the OAuth provider, which helps prevent CSRF attacks.

However, a `strict` session cookie is not sent with the callback request, leading to potential login issues. If you experience this problem, use the default `lax` value instead.

#### `WEBUI_SESSION_COOKIE_SECURE`[​](#webui%5Fsession%5Fcookie%5Fsecure "Direct link to webui_session_cookie_secure")

* Type: `bool`
* Default: `False`
* Description: Sets the `Secure` attribute for session cookies if set to `True`.

#### `WEBUI_AUTH_COOKIE_SAME_SITE`[​](#webui%5Fauth%5Fcookie%5Fsame%5Fsite "Direct link to webui_auth_cookie_same_site")

* Type: `str`
* Options:  
   * `lax` \- Sets the `SameSite` attribute to lax, allowing auth cookies to be sent with requests initiated by third-party websites.  
   * `strict` \- Sets the `SameSite` attribute to strict, blocking auth cookies from being sent with requests initiated by third-party websites.  
   * `none` \- Sets the `SameSite` attribute to none, allowing auth cookies to be sent with requests initiated by third-party websites, but only over HTTPS.
* Default: `lax`
* Description: Sets the `SameSite` attribute for auth cookies.

info

If the value is not set, `WEBUI_SESSION_COOKIE_SAME_SITE` will be used as a fallback.

#### `WEBUI_AUTH_COOKIE_SECURE`[​](#webui%5Fauth%5Fcookie%5Fsecure "Direct link to webui_auth_cookie_secure")

* Type: `bool`
* Default: `False`
* Description: Sets the `Secure` attribute for auth cookies if set to `True`.

info

If the value is not set, `WEBUI_SESSION_COOKIE_SECURE` will be used as a fallback.

#### `WEBUI_AUTH`[​](#webui%5Fauth "Direct link to webui_auth")

* Type: `bool`
* Default: `True`
* Description: This setting enables or disables authentication.

danger

If set to `False`, authentication will be disabled for your Open WebUI instance. However, it's important to note that turning off authentication is only possible for fresh installations without any existing users. If there are already users registered, you cannot disable authentication directly. Ensure that no users are present in the database if you intend to turn off `WEBUI_AUTH`.

#### `ENABLE_PASSWORD_VALIDATION`[​](#enable%5Fpassword%5Fvalidation "Direct link to enable_password_validation")

* Type: `bool`
* Default: `False`
* Description: Enables password complexity validation for user accounts. When enabled, passwords must meet the complexity requirements defined by `PASSWORD_VALIDATION_REGEX_PATTERN` during signup, password updates, and user creation operations. This helps enforce stronger password policies across the application.

info

Password validation is applied to:

* New user registration (signup)
* Password changes through user settings
* Admin-initiated user creation
* Password resets

Existing users with passwords that don't meet the new requirements are **not automatically forced to update their passwords**, but will need to meet the requirements when they next change their password.

#### `PASSWORD_VALIDATION_REGEX_PATTERN`[​](#password%5Fvalidation%5Fregex%5Fpattern "Direct link to password_validation_regex_pattern")

* Type: `str`
* Default: `^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s]).{8,}$`
* Description: Regular expression pattern used to validate password complexity when `ENABLE_PASSWORD_VALIDATION` is enabled. The default pattern requires passwords to be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one digit, and one special character.

warning

**Custom Pattern Considerations**

When defining a custom regex pattern, ensure it:

* Is a valid regular expression that Python's `re` module can compile
* Balances security requirements with user experience
* Is thoroughly tested before deployment to avoid locking users out

Invalid regex patterns will cause password validation to fail, potentially preventing user registration and password changes.

#### `PASSWORD_VALIDATION_HINT`[​](#password%5Fvalidation%5Fhint "Direct link to password_validation_hint")

* Type: `str`
* Default: `""` (empty string)
* Description: Custom hint message displayed to users when their password fails validation. This message appears in error dialogs during signup, password changes, and admin user creation when the password doesn't meet the requirements defined by `PASSWORD_VALIDATION_REGEX_PATTERN`. Use this to explain your specific password requirements in user-friendly terms.
* Example: `Password must be at least 12 characters with uppercase, lowercase, number, and special character.`

tip

When setting a custom `PASSWORD_VALIDATION_REGEX_PATTERN`, always set `PASSWORD_VALIDATION_HINT` to explain the requirements in plain language. Without a hint, users will only see a generic "Invalid password" error with no guidance on what's required.

#### `WEBUI_SECRET_KEY`[​](#webui%5Fsecret%5Fkey "Direct link to webui_secret_key")

* Type: `str`
* Default: Automatically generated (see below)
* Description: The secret key used for signing JSON Web Tokens (JWTs) and **encrypting sensitive data** at rest (including OAuth tokens for MCP). Can be set via the `WEBUI_SECRET_KEY` environment variable or the legacy `WEBUI_JWT_SECRET_KEY` variable (deprecated).

How the secret key is generated

You do **not** need to manually set this variable for a secure installation — **all standard launch methods automatically generate and persist a cryptographically random key on first start:**

| Launch method                                    | Auto-generates? | Persisted to                                      |
| ------------------------------------------------ | --------------- | ------------------------------------------------- |
| **Docker** (start.sh)                            | ✅ Yes           | .webui\_secret\_key file inside the container     |
| **pip install** (open-webui serve)               | ✅ Yes           | .webui\_secret\_key file in the working directory |
| **Development** (open-webui dev, direct uvicorn) | ❌ No            | N/A — uses the code-level fallback                |

The code-level fallback value (`t0p-s3cr3t`) exists **only** for development convenience and is **never used** when Open WebUI is launched through the standard Docker or `open-webui serve` methods. Both of those methods check for the environment variable first, and if it is not set, generate a secure random key, save it to a file, and inject it into the environment — all before the application starts.

Recommended: Set an explicit, persistent value

While the auto-generated key is secure, it is tied to a file inside the container or working directory. **If the container is recreated (not just restarted) and the key file is not in a persisted volume, a new key is generated**, which causes:

1. **All existing user sessions become invalid** (users are logged out).
2. **All OAuth sessions become invalid.**
3. **MCP Tools break** (Error: `Error decrypting tokens`) because tokens encrypted with the previous key cannot be decrypted.

To avoid this, explicitly set `WEBUI_SECRET_KEY` to a secure, persistent value that survives container recreates:

```
# Generate a secure key
openssl rand -hex 32
```

Then pass it as an environment variable in your Docker Compose or deployment configuration.

warning

**Required for Multi-Worker and Multi-Node Deployments AND HIGHLY RECOMMENDED IN SINGLE-WORKER ENVIRONMENTS**

When deploying Open WebUI with `UVICORN_WORKERS > 1` or in a multi-node/worker cluster with a load balancer (e.g. helm/kubectl/kubernetes/k8s), you **must** set this variable to the **same value across all replicas**. Without it, the following issues will occur:

* Session management will fail across workers
* Application state will be inconsistent between instances
* Websocket connections will not function properly in distributed setups
* Users may experience intermittent authentication failures

#### `ENABLE_VERSION_UPDATE_CHECK`[​](#enable%5Fversion%5Fupdate%5Fcheck "Direct link to enable_version_update_check")

* Type: `bool`
* Default: `True`
* Description: When enabled, the application makes automatic update checks and notifies you about version updates.

info

If `OFFLINE_MODE` is enabled, this `ENABLE_VERSION_UPDATE_CHECK` flag is always set to `false` automatically.

#### `OFFLINE_MODE`[​](#offline%5Fmode "Direct link to offline_mode")

* Type: `bool`
* Default: `False`
* Description: Disables Open WebUI's network connections for update checks and automatic model downloads.

info

**Disabled when enabled:**

* Automatic version update checks (see flag `ENABLE_VERSION_UPDATE_CHECK`)
* Downloads of embedding models from Hugging Face Hub  
   * If you did not download an embedding model prior to activating `OFFLINE_MODE` any RAG, web search and document analysis functionality may not work properly
* Update notifications in the UI (see flag `ENABLE_VERSION_UPDATE_CHECK`)

**Still functional:**

* External LLM API connections (OpenAI, etc.)
* OAuth authentication providers
* Web search and RAG with external APIs

Read more about `offline mode` in the [offline mode guide](/tutorials/maintenance/offline-mode).

#### `HF_HUB_OFFLINE`[​](#hf%5Fhub%5Foffline "Direct link to hf_hub_offline")

* Type: `int`
* Default: `0`
* Description: Tells Hugging Face whether we want to launch in offline mode, so to not connect to hugging face and prevent all automatic model downloads

info

Downloads of models, sentence transformers and other configurable items will NOT WORK when this is set to `1`. RAG will also not work on a default installation, if this is set to `True`.

#### `RESET_CONFIG_ON_START`[​](#reset%5Fconfig%5Fon%5Fstart "Direct link to reset_config_on_start")

* Type: `bool`
* Default: `False`
* Description: Resets the `config.json` file on startup.

#### `SAFE_MODE`[​](#safe%5Fmode "Direct link to safe_mode")

* Type: `bool`
* Default: `False`
* Description: Enables safe mode, which disables potentially unsafe features, deactivating all functions.

#### `CORS_ALLOW_ORIGIN`[​](#cors%5Fallow%5Forigin "Direct link to cors_allow_origin")

* Type: `str`
* Default: `*`
* Description: Sets the allowed origins for Cross-Origin Resource Sharing (CORS). Smicolon ';' separated list of allowed origins.

warning

**This variable is required to be set**, otherwise you may experience Websocket issues and weird "{}" responses or "Unexpected token 'd', "data: {"id"... is not valid JSON".

info

If you experience Websocket issues, check the logs of Open WebUI. If you see lines like this `engineio.base_server:_log_error_once:354 - https://yourdomain.com is not an accepted origin.` then you need to configure your CORS\_ALLOW\_ORIGIN more broadly.

Example: CORS\_ALLOW\_ORIGIN: "<https://yourdomain.com;http://yourdomain.com;https://yourhostname;http://youripaddress;http://localhost:3000>"

Add all valid IPs, Domains and Hostnames one might access your Open WebUI to the variable. Once you did, no more websocket issues or warnings in the console should occur.

#### `CORS_ALLOW_CUSTOM_SCHEME`[​](#cors%5Fallow%5Fcustom%5Fscheme "Direct link to cors_allow_custom_scheme")

* Type `str`
* Default: `""` (empty string)
* Description: Sets a list of further allowed schemes for Cross-Origin Resource Sharing (CORS). Allows you to specify additional custom URL schemes, beyond the standard `http` and `https`, that are permitted as valid origins for Cross-Origin Resource Sharing (CORS).

info

This is particularly useful for scenarios such as:

* Integrating with desktop applications that use custom protocols (e.g., `app://`, `custom-app-scheme://`).
* Local development environments or testing setups that might employ non-standard schemes (e.g., `file://` if applicable, or `electron://`).

Provide a semicolon-separated list of scheme names without the `://`. For example: `app;file;electron;my-custom-scheme`.

When configured, these custom schemes will be validated alongside `http` and `https` for any origins specified in `CORS_ALLOW_ORIGIN`.

#### `RAG_EMBEDDING_MODEL_TRUST_REMOTE_CODE`[​](#rag%5Fembedding%5Fmodel%5Ftrust%5Fremote%5Fcode "Direct link to rag_embedding_model_trust_remote_code")

* Type: `bool`
* Default: `False`
* Description: Determines whether to allow custom models defined on the Hub in their own modeling files.

#### `RAG_RERANKING_MODEL_TRUST_REMOTE_CODE`[​](#rag%5Freranking%5Fmodel%5Ftrust%5Fremote%5Fcode "Direct link to rag_reranking_model_trust_remote_code")

* Type: `bool`
* Default: `False`
* Description: Determines whether to allow custom models defined on the Hub in their own. modeling files for reranking.

#### `RAG_EMBEDDING_MODEL_AUTO_UPDATE`[​](#rag%5Fembedding%5Fmodel%5Fauto%5Fupdate "Direct link to rag_embedding_model_auto_update")

* Type: `bool`
* Default: `True`
* Description: Toggles automatic update of the Sentence-Transformer model.

#### `RAG_RERANKING_MODEL_AUTO_UPDATE`[​](#rag%5Freranking%5Fmodel%5Fauto%5Fupdate "Direct link to rag_reranking_model_auto_update")

* Type: `bool`
* Default: `True`
* Description: Toggles automatic update of the reranking model.

## Vector Database[​](#vector-database "Direct link to Vector Database")

#### `VECTOR_DB`[​](#vector%5Fdb "Direct link to vector_db")

* Type: `str`
* Options:
* `chroma`, `elasticsearch`, `mariadb-vector`, `milvus`, `opensearch`, `pgvector`, `qdrant`, `pinecone`, `s3vector`, `oracle23ai`, `weaviate`
* Default: `chroma`
* Description: Specifies which vector database system to use. This setting determines which vector storage system will be used for managing embeddings.

ChromaDB (Default) Is Not Safe for Multi-Worker or Multi-Replica Deployments

The default ChromaDB configuration uses a **local `PersistentClient`** backed by **SQLite**. SQLite is not fork-safe — when uvicorn forks multiple worker processes (`UVICORN_WORKERS > 1`), each worker inherits a copy of the same SQLite connection. Concurrent writes from these forked processes cause immediate crashes (`Child process died`) or database corruption.

**This also applies to multi-replica deployments** (Kubernetes, Docker Swarm) where multiple containers point at the same ChromaDB data directory.

If you need multiple workers or replicas, you **must** either:

1. **Switch to a client-server vector database** such as [PGVector](/reference/env-configuration#pgvector%5Fdb%5Furl), [MariaDB Vector](/reference/env-configuration#mariadb%5Fvector%5Fdb%5Furl), Milvus, or Qdrant (recommended).
2. **Run ChromaDB as a separate HTTP server** and configure [CHROMA\_HTTP\_HOST](/reference/env-configuration#chroma%5Fhttp%5Fhost) / [CHROMA\_HTTP\_PORT](/reference/env-configuration#chroma%5Fhttp%5Fport) so that Open WebUI uses an `HttpClient` instead of the local `PersistentClient`.

See the [Scaling & HA guide](/troubleshooting/multi-replica) for full details.

note

PostgreSQL Dependencies To use `pgvector`, ensure you have PostgreSQL dependencies installed:

```
pip install open-webui[all]
```

info

Only PGVector and ChromaDB will be consistently maintained by the Open WebUI team. The other vector stores are community-added vector databases.

### ChromaDB[​](#chromadb "Direct link to ChromaDB")

Local vs. HTTP Mode

By default (when `CHROMA_HTTP_HOST` is **not** set), ChromaDB runs as a local `PersistentClient` using SQLite for storage. This mode is **only safe for single-worker, single-instance deployments** (`UVICORN_WORKERS=1`, one replica).

For multi-worker or multi-replica setups, you **must** configure `CHROMA_HTTP_HOST` and `CHROMA_HTTP_PORT` to point to a standalone ChromaDB server, or switch to a different vector database entirely. See the [VECTOR\_DB](#vector%5Fdb) warning above.

#### `CHROMA_TENANT`[​](#chroma%5Ftenant "Direct link to chroma_tenant")

* Type: `str`
* Default: The value of `chromadb.DEFAULT_TENANT` (a constant in the `chromadb` module)
* Description: Sets the tenant for ChromaDB to use for RAG embeddings.

#### `CHROMA_DATABASE`[​](#chroma%5Fdatabase "Direct link to chroma_database")

* Type: `str`
* Default: The value of `chromadb.DEFAULT_DATABASE` (a constant in the `chromadb` module)
* Description: Sets the database in the ChromaDB tenant to use for RAG embeddings.

#### `CHROMA_HTTP_HOST`[​](#chroma%5Fhttp%5Fhost "Direct link to chroma_http_host")

* Type: `str`
* Description: Specifies the hostname of a remote ChromaDB Server. Uses a local ChromaDB instance if not set. **Setting this variable is required for multi-worker or multi-replica deployments** — it switches ChromaDB from the local SQLite-backed `PersistentClient` to a fork-safe `HttpClient`.

#### `CHROMA_HTTP_PORT`[​](#chroma%5Fhttp%5Fport "Direct link to chroma_http_port")

* Type: `int`
* Default: `8000`
* Description: Specifies the port of a remote ChromaDB Server.

#### `CHROMA_HTTP_HEADERS`[​](#chroma%5Fhttp%5Fheaders "Direct link to chroma_http_headers")

* Type: `str`
* Description: A comma-separated list of HTTP headers to include with every ChromaDB request.
* Example: `Authorization=Bearer heuhagfuahefj,User-Agent=OpenWebUI`.

#### `CHROMA_HTTP_SSL`[​](#chroma%5Fhttp%5Fssl "Direct link to chroma_http_ssl")

* Type: `bool`
* Default: `False`
* Description: Controls whether or not SSL is used for ChromaDB Server connections.

#### `CHROMA_CLIENT_AUTH_PROVIDER`[​](#chroma%5Fclient%5Fauth%5Fprovider "Direct link to chroma_client_auth_provider")

* Type: `str`
* Description: Specifies an authentication provider for remote ChromaDB Server.
* Example: `chromadb.auth.basic_authn.BasicAuthClientProvider`

#### `CHROMA_CLIENT_AUTH_CREDENTIALS`[​](#chroma%5Fclient%5Fauth%5Fcredentials "Direct link to chroma_client_auth_credentials")

* Type: `str`
* Description: Specifies auth credentials for remote ChromaDB Server.
* Example: `username:password`

### Elasticsearch[​](#elasticsearch "Direct link to Elasticsearch")

#### `ELASTICSEARCH_API_KEY`[​](#elasticsearch%5Fapi%5Fkey "Direct link to elasticsearch_api_key")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the Elasticsearch API key.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ELASTICSEARCH_CA_CERTS`[​](#elasticsearch%5Fca%5Fcerts "Direct link to elasticsearch_ca_certs")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the path to the CA certificates for Elasticsearch.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ELASTICSEARCH_CLOUD_ID`[​](#elasticsearch%5Fcloud%5Fid "Direct link to elasticsearch_cloud_id")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the Elasticsearch cloud ID.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ELASTICSEARCH_INDEX_PREFIX`[​](#elasticsearch%5Findex%5Fprefix "Direct link to elasticsearch_index_prefix")

* Type: `str`
* Default: `open_webui_collections`
* Description: Specifies the prefix for the Elasticsearch index.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ELASTICSEARCH_PASSWORD`[​](#elasticsearch%5Fpassword "Direct link to elasticsearch_password")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the password for Elasticsearch.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ELASTICSEARCH_URL`[​](#elasticsearch%5Furl "Direct link to elasticsearch_url")

* Type: `str`
* Default: `https://localhost:9200`
* Description: Specifies the URL for the Elasticsearch instance.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ELASTICSEARCH_USERNAME`[​](#elasticsearch%5Fusername "Direct link to elasticsearch_username")

* Type: `str`
* Default: Empty string (' '), since `None` is set as default.
* Description: Specifies the username for Elasticsearch.
* Persistence: This environment variable is a `PersistentConfig` variable.

### Milvus[​](#milvus "Direct link to Milvus")

warning

Milvus is not actively maintained by the Open WebUI team. It is an addition by the community and is maintained by the community. If you want to use Milvus, be careful when upgrading Open WebUI (crate backups and snapshots for rollbacks) in case internal changes in Open WebUI lead to breakage.

#### `MILVUS_URI` **(Required)**[​](#milvus%5Furi-required "Direct link to milvus_uri-required")

* Type: `str`
* Default: `${DATA_DIR}/vector_db/milvus.db`
* Example (Remote): `http://your-server-ip:19530`
* Description: Specifies the URI for connecting to the Milvus vector database. This can point to a local or remote Milvus server based on the deployment configuration.

#### `MILVUS_DB`[​](#milvus%5Fdb "Direct link to milvus_db")

* Type: `str`
* Default: `default`
* Example: `default`
* Description: Specifies the database to connect to within a Milvus instance.

#### `MILVUS_TOKEN` **(Required for remote connections with authentication)**[​](#milvus%5Ftoken-required-for-remote-connections-with-authentication "Direct link to milvus_token-required-for-remote-connections-with-authentication")

* Type: `str`
* Default: `None`
* Example: `root:password` (format: `username:password`)
* Description: Specifies an optional connection token for Milvus. Required when connecting to a remote Milvus server with authentication enabled. Format is `username:password`.

#### `MILVUS_INDEX_TYPE`[​](#milvus%5Findex%5Ftype "Direct link to milvus_index_type")

* Type: `str`
* Default: `HNSW`
* Options: `AUTOINDEX`, `FLAT`, `IVF_FLAT`, `HNSW`, `DISKANN`
* Description: Specifies the index type to use when creating a new collection in Milvus. `AUTOINDEX` is generally recommended for Milvus standalone. `HNSW` may offer better performance but requires a clustered Milvus setup and is not meant for standalone setups.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `MILVUS_METRIC_TYPE`[​](#milvus%5Fmetric%5Ftype "Direct link to milvus_metric_type")

* Type: `str`
* Default: `COSINE`
* Options: `COSINE`, `IP`, `L2`
* Description: Specifies the metric type for vector similarity search in Milvus.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `MILVUS_HNSW_M`[​](#milvus%5Fhnsw%5Fm "Direct link to milvus_hnsw_m")

* Type: `int`
* Default: `16`
* Description: Specifies the `M` parameter for the HNSW index type in Milvus. This influences the number of bi-directional links created for each new element during construction. Only applicable if `MILVUS_INDEX_TYPE` is `HNSW`.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `MILVUS_HNSW_EFCONSTRUCTION`[​](#milvus%5Fhnsw%5Fefconstruction "Direct link to milvus_hnsw_efconstruction")

* Type: `int`
* Default: `100`
* Description: Specifies the `efConstruction` parameter for the HNSW index type in Milvus. This influences the size of the dynamic list for the nearest neighbors during index construction. Only applicable if `MILVUS_INDEX_TYPE` is `HNSW`.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `MILVUS_IVF_FLAT_NLIST`[​](#milvus%5Fivf%5Fflat%5Fnlist "Direct link to milvus_ivf_flat_nlist")

* Type: `int`
* Default: `128`
* Description: Specifies the `nlist` parameter for the IVF\_FLAT index type in Milvus. This is the number of cluster units. Only applicable if `MILVUS_INDEX_TYPE` is `IVF_FLAT`.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `MILVUS_DISKANN_MAX_DEGREE`[​](#milvus%5Fdiskann%5Fmax%5Fdegree "Direct link to milvus_diskann_max_degree")

* Type: `int`
* Default: `56`
* Description: Sets the max degree for Milvus if Milvus is in DISKANN indexing mode. Generally recommended to leave as is.

#### `MILVUS_DISKANN_SEARCH_LIST_SIZE`[​](#milvus%5Fdiskann%5Fsearch%5Flist%5Fsize "Direct link to milvus_diskann_search_list_size")

* Type: `int`
* Default: `100`
* Description: Sets the Milvus DISKANN search list size. Generally recommended to leave as is.

#### `ENABLE_MILVUS_MULTITENANCY_MODE`[​](#enable%5Fmilvus%5Fmultitenancy%5Fmode "Direct link to enable_milvus_multitenancy_mode")

* Type: `bool`
* Default: `false`
* Description: Enables multitenancy pattern for Milvus collections management, which significantly reduces RAM usage and computational overhead by consolidating similar vector data structures. Controls whether Milvus uses multitenancy collection architecture. When enabled, all vector data is consolidated into 5 shared collections (memories, knowledge, files, web\_search, hash\_based) instead of creating individual collections per resource. Data isolation is achieved via a resource\_id field rather than collection-level separation.

info

**Benefits of multitenancy mode:**

* Significantly reduced RAM consumption (5 collections vs potentially hundreds)
* Lower computational overhead from collection management
* Faster cold-start times
* Reduced index maintenance burden

**Technical implementation:**

* All memories go into `{prefix}_memories`
* All knowledge bases go into `{prefix}_knowledge`
* All uploaded files go into `{prefix}_files`
* Web search results go into `{prefix}_web_search`
* Hash-based collections go into `{prefix}_hash_based`
* Each entry includes a resource\_id field matching the original collection name
* Queries automatically filter by resource\_id to maintain data isolation

| Collection Variable     | Default Name (Suffix) | Trigger / Routing Logic in the Code                        | Purpose                                                                     |
| ----------------------- | --------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------------- |
| HASH\_BASED\_COLLECTION | \_hash\_based         | Collection name is a **63-char hex string** (SHA256 hash). | Caching direct URL fetches (Websites) with the # feature.                   |
| MEMORY\_COLLECTION      | \_memories            | Collection name starts with **user-memory-**.              | Storing user-specific long-term memories of the experimental memory system. |
| FILE\_COLLECTION        | \_files               | Collection name starts with **file-**.                     | Storing uploaded documents (PDFs, DOCX, etc.).                              |
| WEB\_SEARCH\_COLLECTION | \_web\_search         | Collection name starts with **web-search-**.               | Storing transient results from search engine queries.                       |
| KNOWLEDGE\_COLLECTION   | \_knowledge           | **Everything else** (Default fallback).                    | Storing explicitly created Knowledge Bases.                                 |

info

**Migration from Legacy Mode to Multitenancy**

**What happens when you enable multitenancy when you already have a normal milvus database with data in it:**

* Existing collections (pattern: `open_webui_{collection_name}`) remain in Milvus but **become inaccessible** to Open WebUI
* New data is written to the 5 shared multitenancy collections
* Application treats knowledge bases as empty until reindexed
* Files and memories are NOT automatically migrated to the new collection schema and will appear missing

**Clean migration path from normal Milvus to multitenancy milvus:**

* Before enabling multitenancy, export any critical knowledge content from the UI if possible
* Set `ENABLE_MILVUS_MULTITENANCY_MODE=true` and restart Open WebUI
* Navigate to `Admin Settings > Documents > Click Reindex Knowledge Base`

**This rebuilds ONLY knowledge base vectors into the new multitenancy collections** **Files, user memories, and web search history are NOT migrated by this operation**

**Verify knowledge bases are accessible and functional**

* Re-upload files if file-based retrieval is critical (file metadata remains but vectors are not migrated)
* User chat memories will need to be regenerated through new conversations

**Cleaning up legacy collections:**After successful migration (from milvus to multitenancy milvus), legacy collections still consume resources. Remove them manually:

* Connect to Milvus using the native client (pymilvus or Attu UI)
* Delete all old collections

**Current UI limitations:**

* No one-click "migrate and cleanup" button exists
* Vector DB reset from UI (Admin Settings > Documents > Reset Vector Storage/Knowledge) only affects the active mode's collections
* Legacy collections require manual cleanup via Milvus client tools

warning

**Critical Considerations**

**Before enabling multitenancy on an existing installation:**

* Data loss risk: File vectors and user memory vectors are NOT migrated automatically. Only knowledge base content can be reindexed (migrated).
* Collection naming dependency: Multitenancy relies on Open WebUI's internal collection naming conventions (user-memory-, file-, web-search-, hash patterns). **If Open WebUI changes these conventions in future updates, multitenancy routing may break, causing data corruption or incorrect data retrieval across isolated resources.**
* No automatic rollback: Disabling multitenancy after data is written will not restore access to the shared collections. Data would need manual extraction and re-import.

For fresh installations, no migration concerns exist

**For existing installations with valuable data:**

* Do not migrate to multitenancy mode if you do not want to handle migration and risk data loss
* Understand that files and memories require re-upload/regeneration
* Test migration on a backup/staging environment first
* Consider if RAM savings justify the migration effort for your use case

**To perform a full reset and switch to multitenancy:**

* Backup any critical knowledge base content externally
* Navigate to `Admin Settings > Documents`
* Click `Reset Vector Storage/Knowledge` (this deletes all active mode collections and stored knowledge metadata)
* Set `ENABLE_MILVUS_MULTITENANCY_MODE=true`
* Restart Open WebUI
* Re-upload/re-create knowledge bases from scratch

warning

The mapping of multitenancy relies on current Open WebUI naming conventions for collection names.

If Open WebUI changes how it generates collection names (e.g., "user-memory-" prefix, "file-" prefix, web search patterns, or hash formats), this mapping will break and route data to incorrect collections. POTENTIALLY CAUSING HUGE DATA CORRUPTION, DATA CONSISTENCY ISSUES AND INCORRECT DATA MAPPING INSIDE THE DATABASE.

If you use Multitenancy Mode, you should always check for any changes to the collection names and data mapping before upgrading, and upgrade carefully (snapshots and backups for rollbacks)!

#### `MILVUS_COLLECTION_PREFIX`[​](#milvus%5Fcollection%5Fprefix "Direct link to milvus_collection_prefix")

* Type: `str`
* Default: `open_webui`
* Description: Sets the prefix for Milvus collection names. In multitenancy mode, collections become `{prefix}_memories`, `{prefix}_knowledge`, etc. In legacy mode, collections are `{prefix}_{collection_name}`. Changing this value creates an entirely separate namespace—existing collections with the old prefix become invisible to Open WebUI but remain in Milvus consuming resources. Use this for true multi-instance isolation on a shared Milvus server, not for migration between modes. Milvus only accepts underscores, hyphens/dashes are not possible and will cause errors.

### MariaDB Vector[​](#mariadb-vector "Direct link to MariaDB Vector")

warning

MariaDB Vector is not actively maintained by the Open WebUI team. It is an addition by the community and is maintained by the community. If you want to use MariaDB Vector, be careful when upgrading Open WebUI (create backups and snapshots for rollbacks) in case internal changes in Open WebUI lead to breakage.

note

MariaDB Dependencies

The `mariadb` Python connector is **not included by default** — it was removed from the bundled dependencies. To use `mariadb-vector`, you must install it explicitly:

```
pip install open-webui[mariadb]
```

The official Docker image includes the system-level C library (`libmariadb-dev`) needed to compile the connector, so `pip install open-webui[mariadb]` will work inside the container without additional system packages. For non-Docker deployments, you must install the MariaDB C connector library (`libmariadb-dev` on Debian/Ubuntu) before installing the Python driver.

info

MariaDB Vector requires the **official MariaDB connector** (`mariadb+mariadbconnector://...`) as the connection scheme. This is mandatory because the official driver provides the correct `qmark` paramstyle and proper binary binding for `VECTOR(n)` float32 payloads. Other MySQL-compatible drivers will not work.

Your MariaDB server must support `VECTOR` and `VECTOR INDEX` features (MariaDB 11.7+).

#### `MARIADB_VECTOR_DB_URL`[​](#mariadb%5Fvector%5Fdb%5Furl "Direct link to mariadb_vector_db_url")

* Type: `str`
* Default: Empty string (`""`)
* Description: Sets the database URL for MariaDB Vector storage. Must use the `mariadb+mariadbconnector://` scheme (official MariaDB driver).
* Example: `mariadb+mariadbconnector://user:password@localhost:3306/openwebui`

#### `MARIADB_VECTOR_INITIALIZE_MAX_VECTOR_LENGTH`[​](#mariadb%5Fvector%5Finitialize%5Fmax%5Fvector%5Flength "Direct link to mariadb_vector_initialize_max_vector_length")

* Type: `int`
* Default: `1536`
* Description: Specifies the maximum vector length (number of dimensions) for the `VECTOR(n)` column. Must match the dimensionality of your embedding model. Once the table is created, changing this value requires data migration — the backend will refuse to start if the configured dimension differs from the stored column dimension.

#### `MARIADB_VECTOR_DISTANCE_STRATEGY`[​](#mariadb%5Fvector%5Fdistance%5Fstrategy "Direct link to mariadb_vector_distance_strategy")

* Type: `str`
* Options:  
   * `cosine` \- Uses `vec_distance_cosine()` for similarity measurement.  
   * `euclidean` \- Uses `vec_distance_euclidean()` for similarity measurement.
* Default: `cosine`
* Description: Controls which distance function is used for the `VECTOR INDEX` and similarity search queries.

#### `MARIADB_VECTOR_INDEX_M`[​](#mariadb%5Fvector%5Findex%5Fm "Direct link to mariadb_vector_index_m")

* Type: `int`
* Default: `8`
* Description: HNSW index parameter that controls the maximum number of bi-directional connections per layer during index construction (`M=<int>` in the MariaDB `VECTOR INDEX` definition). Higher values improve recall but increase index size and build time.

#### `MARIADB_VECTOR_POOL_SIZE`[​](#mariadb%5Fvector%5Fpool%5Fsize "Direct link to mariadb_vector_pool_size")

* Type: `int`
* Default: `None`
* Description: Sets the number of connections to maintain in the MariaDB Vector database connection pool. If not set, uses SQLAlchemy defaults. Setting this to `0` disables connection pooling entirely (uses `NullPool`).

#### `MARIADB_VECTOR_POOL_MAX_OVERFLOW`[​](#mariadb%5Fvector%5Fpool%5Fmax%5Foverflow "Direct link to mariadb_vector_pool_max_overflow")

* Type: `int`
* Default: `0`
* Description: Specifies the maximum number of connections that can be created beyond `MARIADB_VECTOR_POOL_SIZE` when the pool is exhausted.

#### `MARIADB_VECTOR_POOL_TIMEOUT`[​](#mariadb%5Fvector%5Fpool%5Ftimeout "Direct link to mariadb_vector_pool_timeout")

* Type: `int`
* Default: `30`
* Description: Sets the timeout in seconds for acquiring a connection from the MariaDB Vector pool.

#### `MARIADB_VECTOR_POOL_RECYCLE`[​](#mariadb%5Fvector%5Fpool%5Frecycle "Direct link to mariadb_vector_pool_recycle")

* Type: `int`
* Default: `3600`
* Description: Specifies the time in seconds after which connections are recycled in the MariaDB Vector pool to prevent stale connections.

### OpenSearch[​](#opensearch "Direct link to OpenSearch")

#### `OPENSEARCH_CERT_VERIFY`[​](#opensearch%5Fcert%5Fverify "Direct link to opensearch_cert_verify")

* Type: `bool`
* Default: `False`
* Description: Enables or disables OpenSearch certificate verification.

#### `OPENSEARCH_PASSWORD`[​](#opensearch%5Fpassword "Direct link to opensearch_password")

* Type: `str`
* Default: `None`
* Description: Sets the password for OpenSearch.

#### `OPENSEARCH_SSL`[​](#opensearch%5Fssl "Direct link to opensearch_ssl")

* Type: `bool`
* Default: `True`
* Description: Enables or disables SSL for OpenSearch.

#### `OPENSEARCH_URI`[​](#opensearch%5Furi "Direct link to opensearch_uri")

* Type: `str`
* Default: `https://localhost:9200`
* Description: Sets the URI for OpenSearch.

#### `OPENSEARCH_USERNAME`[​](#opensearch%5Fusername "Direct link to opensearch_username")

* Type: `str`
* Default: `None`
* Description: Sets the username for OpenSearch.

### PGVector[​](#pgvector "Direct link to PGVector")

note

PostgreSQL Dependencies To use `pgvector`, ensure you have PostgreSQL dependencies installed:

```
pip install open-webui[all]
```

#### `PGVECTOR_DB_URL`[​](#pgvector%5Fdb%5Furl "Direct link to pgvector_db_url")

* Type: `str`
* Default: The value of the `DATABASE_URL` environment variable
* Description: Sets the database URL for model storage.

#### `PGVECTOR_INITIALIZE_MAX_VECTOR_LENGTH`[​](#pgvector%5Finitialize%5Fmax%5Fvector%5Flength "Direct link to pgvector_initialize_max_vector_length")

* Type: `str`
* Default: `1536`
* Description: Specifies the maximum vector length for PGVector initialization.

#### `PGVECTOR_CREATE_EXTENSION`[​](#pgvector%5Fcreate%5Fextension "Direct link to pgvector_create_extension")

* Type: `str`
* Default `true`
* Description: Creates the vector extension in the database

info

If set to `false`, open-webui will assume the postgreSQL database where embeddings will be stored is pre-configured with the `vector` extension. This also allows open-webui to run as a non superuser database user.

#### `PGVECTOR_INDEX_METHOD`[​](#pgvector%5Findex%5Fmethod "Direct link to pgvector_index_method")

* Type: `str`
* Options:  
   * `ivfflat` \- Uses inverted file with flat compression, better for datasets with many dimensions.  
   * `hnsw` \- Uses Hierarchical Navigable Small World graphs, generally provides better query performance.
* Default: Not specified (pgvector will use its default)
* Description: Specifies the index method for pgvector. The choice affects query performance and index build time.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

When choosing an index method, consider your dataset size and query patterns. HNSW generally provides better query performance but uses more memory, while IVFFlat can be more memory-efficient for larger datasets.

#### `PGVECTOR_HNSW_M`[​](#pgvector%5Fhnsw%5Fm "Direct link to pgvector_hnsw_m")

* Type: `int`
* Default: `16`
* Description: HNSW index parameter that controls the maximum number of bi-directional connections per layer during index construction. Higher values improve recall but increase index size and build time. Only applicable when `PGVECTOR_INDEX_METHOD` is set to `hnsw`.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PGVECTOR_HNSW_EF_CONSTRUCTION`[​](#pgvector%5Fhnsw%5Fef%5Fconstruction "Direct link to pgvector_hnsw_ef_construction")

* Type: `int`
* Default: `64`
* Description: HNSW index parameter that controls the size of the dynamic candidate list during index construction. Higher values improve index quality but increase build time. Only applicable when `PGVECTOR_INDEX_METHOD` is set to `hnsw`.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PGVECTOR_IVFFLAT_LISTS`[​](#pgvector%5Fivfflat%5Flists "Direct link to pgvector_ivfflat_lists")

* Type: `int`
* Default: `100`
* Description: IVFFlat index parameter that specifies the number of inverted lists (clusters) to create. A good starting point is `rows / 1000` for up to 1M rows and `sqrt(rows)` for over 1M rows. Only applicable when `PGVECTOR_INDEX_METHOD` is set to `ivfflat`.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

For IVFFlat indexes, choosing the right number of lists is crucial for query performance. Too few lists will result in slow queries, while too many will increase index size without significant performance gains.

#### `PGVECTOR_USE_HALFVEC`[​](#pgvector%5Fuse%5Fhalfvec "Direct link to pgvector_use_halfvec")

* Type: `bool`
* Default: `False`
* Description: Enables the use of `halfvec` data type instead of `vector` for storing embeddings. Required when `PGVECTOR_INITIALIZE_MAX_VECTOR_LENGTH` exceeds 2000 dimensions, as the `vector` type has a 2000-dimension limit.

#### `PGVECTOR_PGCRYPTO`[​](#pgvector%5Fpgcrypto "Direct link to pgvector_pgcrypto")

* Type: `bool`
* Default: `False`
* Description: Enables pgcrypto extension for encrypting sensitive data within PGVector. When enabled, `PGVECTOR_PGCRYPTO_KEY` must be set.

#### `PGVECTOR_PGCRYPTO_KEY`[​](#pgvector%5Fpgcrypto%5Fkey "Direct link to pgvector_pgcrypto_key")

* Type: `str`
* Default: `None`
* Description: Specifies the encryption key for pgcrypto when `PGVECTOR_PGCRYPTO` is enabled. Must be a secure, randomly generated key.

#### `PGVECTOR_POOL_SIZE`[​](#pgvector%5Fpool%5Fsize "Direct link to pgvector_pool_size")

* Type: `int`
* Default: `None`
* Description: Sets the number of connections to maintain in the PGVector database connection pool. If not set, uses SQLAlchemy defaults.

#### `PGVECTOR_POOL_MAX_OVERFLOW`[​](#pgvector%5Fpool%5Fmax%5Foverflow "Direct link to pgvector_pool_max_overflow")

* Type: `int`
* Default: `0`
* Description: Specifies the maximum number of connections that can be created beyond `PGVECTOR_POOL_SIZE` when the pool is exhausted.

#### `PGVECTOR_POOL_TIMEOUT`[​](#pgvector%5Fpool%5Ftimeout "Direct link to pgvector_pool_timeout")

* Type: `int`
* Default: `30`
* Description: Sets the timeout in seconds for acquiring a connection from the PGVector pool.

#### `PGVECTOR_POOL_RECYCLE`[​](#pgvector%5Fpool%5Frecycle "Direct link to pgvector_pool_recycle")

* Type: `int`
* Default: `3600`
* Description: Specifies the time in seconds after which connections are recycled in the PGVector pool to prevent stale connections.

### Qdrant[​](#qdrant "Direct link to Qdrant")

warning

Qdrant is not actively maintained by the Open WebUI team. It is an addition by the community and is maintained by the community. If you want to use Qdrant, be careful when upgrading Open WebUI (crate backups and snapshots for rollbacks) in case internal changes in Open WebUI lead to breakage.

#### `QDRANT_API_KEY`[​](#qdrant%5Fapi%5Fkey "Direct link to qdrant_api_key")

* Type: `str`
* Description: Sets the API key for Qdrant.

#### `QDRANT_URI`[​](#qdrant%5Furi "Direct link to qdrant_uri")

* Type: `str`
* Description: Sets the URI for Qdrant.

#### `QDRANT_ON_DISK`[​](#qdrant%5Fon%5Fdisk "Direct link to qdrant_on_disk")

* Type: `bool`
* Default: `False`
* Description: Enable the usage of memmap(also known as on-disk) storage

#### `QDRANT_PREFER_GRPC`[​](#qdrant%5Fprefer%5Fgrpc "Direct link to qdrant_prefer_grpc")

* Type: `bool`
* Default: `False`
* Description: Use gPRC interface whenever possible.

info

If set to `True`, and `QDRANT_URI` points to a self-hosted server with TLS enabled and certificate signed by a private CA, set the environment variable `GRPC_DEFAULT_SSL_ROOTS_FILE_PATH` to the path of your PEM-encoded CA certificates file. See the [gRPC Core Docs](https://grpc.github.io/grpc/core/md%5Fdoc%5Fenvironment%5Fvariables.html) for more information.

#### `QDRANT_GRPC_PORT`[​](#qdrant%5Fgrpc%5Fport "Direct link to qdrant_grpc_port")

* Type: `int`
* Default: `6334`
* Description: Sets the gRPC port number for Qdrant.

#### `QDRANT_TIMEOUT`[​](#qdrant%5Ftimeout "Direct link to qdrant_timeout")

* Type: `int`
* Default: `5`
* Description: Sets the timeout in seconds for all requests made to the Qdrant server, helping to prevent long-running queries from stalling the application.

#### `QDRANT_HNSW_M`[​](#qdrant%5Fhnsw%5Fm "Direct link to qdrant_hnsw_m")

* Type: `int`
* Default: `16`
* Description: Controls the HNSW (Hierarchical Navigable Small World) index construction. In standard mode, this sets the `m` parameter. In multi-tenancy mode, this value is used for the `payload_m` parameter to build indexes on the payload, as the global `m` is disabled for performance, following Qdrant best practices.

#### `ENABLE_QDRANT_MULTITENANCY_MODE`[​](#enable%5Fqdrant%5Fmultitenancy%5Fmode "Direct link to enable_qdrant_multitenancy_mode")

* Type: `bool`
* Default: `True`
* Description: Enables multitenancy pattern for Qdrant collections management, which significantly reduces RAM usage and computational overhead by consolidating similar vector data structures. Recommend turn on

info

This will disconect all Qdrant collections created in the previous pattern, which is non-multitenancy. Go to `Admin Settings` \> `Documents` \> `Reindex Knowledge Base` to migrate existing knowledges.

The Qdrant collections created in the previous pattern will still consume resources.

Currently, there is no button in the UI to only reset the vector DB. If you want to migrate knowledge to multitenancy:

* Remove all collections with the `open_webui-knowledge` prefix (or `open_webui` prefix to remove all collections related to Open WebUI) using the native Qdrant client
* Go to `Admin Settings` \> `Documents` \> `Reindex Knowledge Base` to migrate existing knowledge base

`Reindex Knowledge Base` will ONLY migrate the knowledge base

danger

If you decide to use the multitenancy pattern as your default and you don't need to migrate old knowledge, go to `Admin Settings` \> `Documents` to reset vector and knowledge, which will delete all collections with the `open_webui` prefix and all stored knowledge.

warning

The mapping of multitenancy relies on current Open WebUI naming conventions for collection names.

If Open WebUI changes how it generates collection names (e.g., "user-memory-" prefix, "file-" prefix, web search patterns, or hash formats), this mapping will break and route data to incorrect collections. POTENTIALLY CAUSING HUGE DATA CORRUPTION, DATA CONSISTENCY ISSUES AND INCORRECT DATA MAPPING INSIDE THE DATABASE.

If you use Multitenancy Mode, you should always check for any changes to the collection names and data mapping before upgrading, and upgrade carefully (snapshots and backups for rollbacks)!

#### `QDRANT_COLLECTION_PREFIX`[​](#qdrant%5Fcollection%5Fprefix "Direct link to qdrant_collection_prefix")

* Type: `str`
* Default: `open-webui`
* Description: Sets the prefix for Qdrant collection names. Useful for namespacing or isolating collections, especially in multitenancy mode. Changing this value will cause the application to use a different set of collections in Qdrant. Existing collections with a different prefix will not be affected.

### Pinecone[​](#pinecone "Direct link to Pinecone")

When using Pinecone as the vector store, the following environment variables are used to control its behavior. Make sure to set these variables in your `.env` file or deployment environment.

#### `PINECONE_API_KEY`[​](#pinecone%5Fapi%5Fkey "Direct link to pinecone_api_key")

* Type: `str`
* Default: `None`
* Description: Sets the API key used to authenticate with the Pinecone service.

#### `PINECONE_ENVIRONMENT`[​](#pinecone%5Fenvironment "Direct link to pinecone_environment")

* Type: `str`
* Default: `None`
* Description: Specifies the Pinecone environment to connect to (e.g., `us-west1-gcp`, `gcp-starter`, etc.).

#### `PINECONE_INDEX_NAME`[​](#pinecone%5Findex%5Fname "Direct link to pinecone_index_name")

* Type: `str`
* Default: `open-webui-index`
* Description: Defines the name of the Pinecone index that will be used to store and query vector embeddings.

#### `PINECONE_DIMENSION`[​](#pinecone%5Fdimension "Direct link to pinecone_dimension")

* Type: `int`
* Default: `1536`
* Description: The dimensionality of the vector embeddings. Must match the dimension expected by the index (commonly 768, 1024, 1536, or 3072 based on model used).

#### `PINECONE_METRIC`[​](#pinecone%5Fmetric "Direct link to pinecone_metric")

* Type: `str`
* Default: `cosine`
* Options: `cosine`, `dotproduct`, `euclidean`
* Description: Specifies the similarity metric to use for vector comparisons within the Pinecone index.

#### `PINECONE_CLOUD`[​](#pinecone%5Fcloud "Direct link to pinecone_cloud")

* Type: `str`
* Default: `aws`
* Options: `aws`, `gcp`, `azure`
* Description: Specifies the cloud provider where the Pinecone index is hosted.

### Weaviate[​](#weaviate "Direct link to Weaviate")

info

**Self-Hosted and Cloud Deployments**

Open WebUI uses `connect_to_custom` for Weaviate connections, which supports both locally hosted and remote Weaviate instances. This is essential for self-hosted deployments where HTTP and gRPC endpoints may be on different ingresses or hostnames, which is common in container orchestration platforms like Kubernetes or Azure Container Apps.

#### `WEAVIATE_HTTP_HOST`[​](#weaviate%5Fhttp%5Fhost "Direct link to weaviate_http_host")

* Type: `str`
* Default: Empty string (' ')
* Description: Specifies the hostname of the Weaviate server for HTTP connections. For self-hosted deployments, this is typically your Weaviate HTTP endpoint hostname.

#### `WEAVIATE_GRPC_HOST`[​](#weaviate%5Fgrpc%5Fhost "Direct link to weaviate_grpc_host")

* Type: `str`
* Default: Empty string (' ')
* Description: Specifies the hostname of the Weaviate server for gRPC connections. This can be different from `WEAVIATE_HTTP_HOST` when HTTP and gRPC are served on separate ingresses, which is common in container orchestration environments.

#### `WEAVIATE_HTTP_PORT`[​](#weaviate%5Fhttp%5Fport "Direct link to weaviate_http_port")

* Type: `int`
* Default: `8080`
* Description: Specifies the HTTP port for connecting to the Weaviate server.

#### `WEAVIATE_GRPC_PORT`[​](#weaviate%5Fgrpc%5Fport "Direct link to weaviate_grpc_port")

* Type: `int`
* Default: `50051`
* Description: Specifies the gRPC port for connecting to the Weaviate server.

#### `WEAVIATE_HTTP_SECURE`[​](#weaviate%5Fhttp%5Fsecure "Direct link to weaviate_http_secure")

* Type: `bool`
* Default: `False`
* Description: Enables HTTPS for HTTP connections to the Weaviate server. Set to `true` when connecting to a Weaviate instance with TLS enabled on the HTTP endpoint.

#### `WEAVIATE_GRPC_SECURE`[​](#weaviate%5Fgrpc%5Fsecure "Direct link to weaviate_grpc_secure")

* Type: `bool`
* Default: `False`
* Description: Enables TLS for gRPC connections to the Weaviate server. Set to `true` when connecting to a Weaviate instance with TLS enabled on the gRPC endpoint.

#### `WEAVIATE_API_KEY`[​](#weaviate%5Fapi%5Fkey "Direct link to weaviate_api_key")

* Type: `str`
* Default: `None`
* Description: Sets the API key for authenticating with Weaviate server.

#### `WEAVIATE_SKIP_INIT_CHECKS`[​](#weaviate%5Fskip%5Finit%5Fchecks "Direct link to weaviate_skip_init_checks")

* Type: `bool`
* Default: `False`
* Description: Skips Weaviate initialization checks when connecting. This can be useful in certain network configurations where the checks may fail but the connection itself works.

### Oracle 23ai Vector Search (oracle23ai)[​](#oracle-23ai-vector-search-oracle23ai "Direct link to Oracle 23ai Vector Search (oracle23ai)")

#### `ORACLE_DB_USE_WALLET`[​](#oracle%5Fdb%5Fuse%5Fwallet "Direct link to oracle_db_use_wallet")

* **Type**: `bool`
* **Default**: `false`
* **Description**: Determines the connection method to the Oracle Database.  
   * Set to `false` for direct connections (e.g., to Oracle Database 23ai Free or DBCS instances) using host, port, and service name in `ORACLE_DB_DSN`.  
   * Set to `true` for wallet-based connections (e.g., to Oracle Autonomous Database (ADW/ATP)). When `true`, `ORACLE_WALLET_DIR` and `ORACLE_WALLET_PASSWORD` must also be configured.

#### `ORACLE_DB_USER`[​](#oracle%5Fdb%5Fuser "Direct link to oracle_db_user")

* **Type**: `str`
* **Default**: `DEMOUSER`
* **Description**: Specifies the username used to connect to the Oracle Database.

#### `ORACLE_DB_PASSWORD`[​](#oracle%5Fdb%5Fpassword "Direct link to oracle_db_password")

* **Type**: `str`
* **Default**: `Welcome123456`
* **Description**: Specifies the password for the `ORACLE_DB_USER`.

#### `ORACLE_DB_DSN`[​](#oracle%5Fdb%5Fdsn "Direct link to oracle_db_dsn")

* **Type**: `str`
* **Default**: `localhost:1521/FREEPDB1`
* **Description**: Defines the Data Source Name for the Oracle Database connection.  
   * If `ORACLE_DB_USE_WALLET` is `false`, this should be in the format `hostname:port/service_name` (e.g., `localhost:1521/FREEPDB1`).  
   * If `ORACLE_DB_USE_WALLET` is `true`, this can be a TNS alias (e.g., `medium` for ADW/ATP), or a full connection string.

#### `ORACLE_WALLET_DIR`[​](#oracle%5Fwallet%5Fdir "Direct link to oracle_wallet_dir")

* **Type**: `str`
* **Default**: Empty string (' ')
* **Description**: **Required when `ORACLE_DB_USE_WALLET` is `true`**. Specifies the absolute path to the directory containing the Oracle Cloud Wallet files (e.g., `cwallet.sso`, `sqlnet.ora`, `tnsnames.ora`).

#### `ORACLE_WALLET_PASSWORD`[​](#oracle%5Fwallet%5Fpassword "Direct link to oracle_wallet_password")

* **Type**: `str`
* **Default**: Empty string (' ')
* **Description**: **Required when `ORACLE_DB_USE_WALLET` is `true`**. Specifies the password for the Oracle Cloud Wallet.

#### `ORACLE_VECTOR_LENGTH`[​](#oracle%5Fvector%5Flength "Direct link to oracle_vector_length")

* **Type**: `int`
* **Default**: `768`
* **Description**: Sets the expected dimension or length of the vector embeddings stored in the Oracle Database. This must match the embedding model used.

#### `ORACLE_DB_POOL_MIN`[​](#oracle%5Fdb%5Fpool%5Fmin "Direct link to oracle_db_pool_min")

* **Type**: `int`
* **Default**: `2`
* **Description**: The minimum number of connections to maintain in the Oracle Database connection pool.

#### `ORACLE_DB_POOL_MAX`[​](#oracle%5Fdb%5Fpool%5Fmax "Direct link to oracle_db_pool_max")

* **Type**: `int`
* **Default**: `10`
* **Description**: The maximum number of connections allowed in the Oracle Database connection pool.

#### `ORACLE_DB_POOL_INCREMENT`[​](#oracle%5Fdb%5Fpool%5Fincrement "Direct link to oracle_db_pool_increment")

* **Type**: `int`
* **Default**: `1`
* **Description**: The number of connections to create when the pool needs to grow.

### S3 Vector Bucket[​](#s3-vector-bucket "Direct link to S3 Vector Bucket")

When using S3 Vector Bucket as the vector store, the following environment variables are used to control its behavior. Make sure to set these variables in your `.env` file or deployment environment.

info

Note: this configuration assumes that AWS credentials will be available to your Open WebUI environment. This could be through environment variables like `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, or through IAM role permissions.

#### `S3_VECTOR_BUCKET_NAME`[​](#s3%5Fvector%5Fbucket%5Fname "Direct link to s3_vector_bucket_name")

* Type: `str`
* Description: Specifies the name of the S3 Vector Bucket to store vectors in.

#### `S3_VECTOR_REGION`[​](#s3%5Fvector%5Fregion "Direct link to s3_vector_region")

* Type: `str`
* Description: Specifies the AWS region where the S3 Vector Bucket is hosted.

## RAG Content Extraction Engine[​](#rag-content-extraction-engine "Direct link to RAG Content Extraction Engine")

#### `CONTENT_EXTRACTION_ENGINE`[​](#content%5Fextraction%5Fengine "Direct link to content_extraction_engine")

* Type: `str`
* Options:  
   * Leave empty to use default  
   * `external` \- Use external loader  
   * `tika` \- Use a local Apache Tika server  
   * `docling` \- Use Docling engine  
   * `document_intelligence` \- Use Document Intelligence engine  
   * `mistral_ocr` \- Use Mistral OCR engine  
   * `datalab_marker` \- Use Datalab Marker engine  
   * `mineru` \- Use MinerU engine  
   * `paddleocr_vl` \- Use a PaddleOCR-vl server (requires `PADDLEOCR_VL_TOKEN`; see below)
* Description: Sets the content extraction engine to use for document ingestion.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `MISTRAL_OCR_API_KEY`[​](#mistral%5Focr%5Fapi%5Fkey "Direct link to mistral_ocr_api_key")

* Type: `str`
* Default: `None`
* Description: Specifies the Mistral OCR API key to use.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `MISTRAL_OCR_API_BASE_URL`[​](#mistral%5Focr%5Fapi%5Fbase%5Furl "Direct link to mistral_ocr_api_base_url")

* Type: `str`
* Default: `https://api.mistral.ai/v1`
* Description: Configures custom Mistral OCR API endpoints for flexible deployment options, allowing users to point to self-hosted or alternative Mistral OCR instances.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `EXTERNAL_DOCUMENT_LOADER_URL`[​](#external%5Fdocument%5Floader%5Furl "Direct link to external_document_loader_url")

* Type: `str`
* Default: `None`
* Description: Sets the URL for the external document loader service.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `EXTERNAL_DOCUMENT_LOADER_API_KEY`[​](#external%5Fdocument%5Floader%5Fapi%5Fkey "Direct link to external_document_loader_api_key")

* Type: `str`
* Default: `None`
* Description: Sets the API key for authenticating with the external document loader service.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `TIKA_SERVER_URL`[​](#tika%5Fserver%5Furl "Direct link to tika_server_url")

* Type: `str`
* Default: `http://localhost:9998`
* Description: Sets the URL for the Apache Tika server.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DOCLING_SERVER_URL`[​](#docling%5Fserver%5Furl "Direct link to docling_server_url")

* Type: `str`
* Default: `http://docling:5001`
* Description: Specifies the URL for the Docling server. Requires Docling version 2.0.0 or later for full compatibility with the new parameter-based configuration system.
* Persistence: This environment variable is a `PersistentConfig` variable.

warning

**Docling 2.0.0+ Required**

The Docling integration has been refactored to use server-side parameter passing. If you are using Docling:

1. Upgrade to Docling server version 2.0.0 or later
2. Migrate all individual `DOCLING_*` configuration variables to the `DOCLING_PARAMS` JSON object
3. Remove all deprecated `DOCLING_*` environment variables from your configuration
4. Add `DOCLING_API_KEY` if your server requires authentication

The old individual environment variables (`DOCLING_OCR_ENGINE`, `DOCLING_OCR_LANG`, etc.) are no longer supported and will be ignored.

#### `DOCLING_API_KEY`[​](#docling%5Fapi%5Fkey "Direct link to docling_api_key")

* Type: `str`
* Default: `None`
* Description: Sets the API key for authenticating with the Docling server. Required when the Docling server has authentication enabled.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DOCLING_PARAMS`[​](#docling%5Fparams "Direct link to docling_params")

* Type: `str` (JSON)
* Default: `{}`
* Description: Specifies all Docling processing parameters in JSON format. This is the primary configuration method for Docling processing options. All previously individual Docling settings are now configured through this single JSON object.  
**Supported Parameters:**  
   * `do_ocr` (bool): Enable OCR processing.  
   * `force_ocr` (bool): Force OCR even when text layer exists.  
   * `ocr_engine` (str): OCR engine to use. Options: `tesseract`, `easyocr`, `ocrmac`, `rapidocr`, `tesserocr`.  
   * `ocr_lang` (list\[str\]): OCR language codes. Note: Format depends on engine (e.g., `["eng", "fra"]` for Tesseract; `["en", "fr"]` for EasyOCR).  
   * `pdf_backend` (str): PDF processing backend. Options: `dlparse_v1`, `dlparse_v2`, `dlparse_v4`, `pypdfium2`.  
   * `table_mode` (str): Table extraction mode. Options: `fast`, `accurate`.  
   * `pipeline` (str): Processing pipeline to use. Options: `fast`, `standard`.  
   * `do_picture_description` (bool): Enable image description generation.  
   * `picture_description_mode` (str): Mode for picture descriptions. Options: `local`, `api`.  
   * `picture_description_local` (str): Local model configuration object for picture descriptions.  
   * `picture_description_api` (str): API endpoint configuration object for picture descriptions.  
   * `vlm_pipeline_model_api` (str): Vision-language model API configuration. (e.g., `openai://gpt-4o`).
* Example:

```
{
  "do_ocr": true,
  "ocr_engine": "tesseract",
  "ocr_lang": ["eng", "fra", "deu", "spa"],
  "force_ocr": false,
  "pdf_backend": "dlparse_v4",
  "table_mode": "accurate",
  "do_picture_description": true,
  "picture_description_mode": "api",
  "vlm_pipeline_model_api": "openai://gpt-4o"
}
```

tip

**dlparse** vs **dbparse**: Note that the backend names use **`dlparse`** (Deep Learning Parse), not `dbparse`. For modern Docling (v2+), `dlparse_v4` is generally recommended for the best balance of features.

* Persistence: This environment variable is a `PersistentConfig` variable.

info

**Migration from Individual Docling Variables**

If you were previously using individual `DOCLING_*` environment variables (such as `DOCLING_OCR_ENGINE`, `DOCLING_OCR_LANG`, etc.), these are now deprecated. You must migrate to using `DOCLING_PARAMS` as a single JSON configuration object.

**Example Migration:**

```
# Old configuration (deprecated)
DOCLING_OCR_ENGINE=tesseract
DOCLING_OCR_LANG=eng,fra
DOCLING_DO_OCR=true

# New configuration (required)
DOCLING_PARAMS='{"do_ocr": true, "ocr_engine": "tesseract", "ocr_lang": "eng,fra"}'
```

warning

When setting this environment variable in a `.env` file, ensure proper JSON formatting and escape quotes as needed:

```
DOCLING_PARAMS="{\"do_ocr\": true, \"ocr_engine\": \"tesseract\", \"ocr_lang\": \"eng,fra,deu,spa\"}"

```

#### `MINERU_API_TIMEOUT`[​](#mineru%5Fapi%5Ftimeout "Direct link to mineru_api_timeout")

* Type: `str`
* Default: `300`
* Description: Sets the timeout in seconds for MinerU API requests during document processing.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PADDLEOCR_VL_BASE_URL`[​](#paddleocr%5Fvl%5Fbase%5Furl "Direct link to paddleocr_vl_base_url")

* Type: `str`
* Default: `http://localhost:8080`
* Description: Base URL of the PaddleOCR-vl server used when `CONTENT_EXTRACTION_ENGINE=paddleocr_vl`. Documents and images are POSTed to `{base_url}/layout-parsing` and the response's `layoutParsingResults[].markdown.text` is ingested page-by-page.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PADDLEOCR_VL_TOKEN`[​](#paddleocr%5Fvl%5Ftoken "Direct link to paddleocr_vl_token")

* Type: `str`
* Default: `""` (empty)
* Description: Authentication token for the PaddleOCR-vl server. Sent as `Authorization: token <value>` on every layout-parsing request. **The PaddleOCR-vl engine is skipped at runtime if this value is empty** — the loader falls back to the default PyPDFLoader for the current document even when `CONTENT_EXTRACTION_ENGINE=paddleocr_vl` is set. Set this to activate the engine.
* Persistence: This environment variable is a `PersistentConfig` variable.

Supported file types

PaddleOCR-vl handles both documents and images. Extensions treated as images and dispatched with `fileType=1`: `png`, `jpg`, `jpeg`, `bmp`, `tiff`, `webp`. Everything else is dispatched with `fileType=0` (document, e.g. PDFs). Output is per-page Markdown, so downstream chunking behaves the same as other engines.

## Retrieval Augmented Generation (RAG)[​](#retrieval-augmented-generation-rag "Direct link to Retrieval Augmented Generation (RAG)")

### Core Configuration[​](#core-configuration "Direct link to Core Configuration")

#### `RAG_EMBEDDING_ENGINE`[​](#rag%5Fembedding%5Fengine "Direct link to rag_embedding_engine")

* Type: `str`
* Options:  
   * Leave empty for `Default (SentenceTransformers)` \- Uses SentenceTransformers for embeddings.  
   * `ollama` \- Uses the Ollama API for embeddings.  
   * `openai` \- Uses the OpenAI API for embeddings.  
   * `azure_openai` \- Uses Azure OpenAI Services for embeddings.
* Description: Selects an embedding engine to use for RAG.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_EMBEDDING_MODEL`[​](#rag%5Fembedding%5Fmodel "Direct link to rag_embedding_model")

* Type: `str`
* Default: `sentence-transformers/all-MiniLM-L6-v2`
* Description: Sets a model for embeddings. Locally, a Sentence-Transformer model is used.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_TOP_K`[​](#rag%5Ftop%5Fk "Direct link to rag_top_k")

* Type: `int`
* Default: `3`
* Description: Sets the default number of results to consider for the embedding when using RAG.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_TOP_K_RERANKER`[​](#rag%5Ftop%5Fk%5Freranker "Direct link to rag_top_k_reranker")

* Type: `int`
* Default: `3`
* Description: Sets the default number of results to consider for the reranker when using RAG.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_RELEVANCE_THRESHOLD`[​](#rag%5Frelevance%5Fthreshold "Direct link to rag_relevance_threshold")

* Type: `float`
* Default: `0.0`
* Description: Sets the relevance threshold to consider for documents when used with reranking.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_RAG_HYBRID_SEARCH`[​](#enable%5Frag%5Fhybrid%5Fsearch "Direct link to enable_rag_hybrid_search")

* Type: `bool`
* Default: `False`
* Description: Enables the use of ensemble search with `BM25` \+ `ChromaDB`, with reranking using `sentence_transformers` models. When enabled, this applies to both the standard RAG retrieval pipeline and the native knowledge tools used in agentic mode.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_HYBRID_BM25_WEIGHT`[​](#rag%5Fhybrid%5Fbm25%5Fweight "Direct link to rag_hybrid_bm25_weight")

* Type: `float`
* Default: `0.5`
* Description: Sets the weight given to the keyword search (BM25) during hybrid search. 1 means only keyword search, 0 means only vector search.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_RAG_HYBRID_SEARCH_ENRICHED_TEXTS`[​](#enable%5Frag%5Fhybrid%5Fsearch%5Fenriched%5Ftexts "Direct link to enable_rag_hybrid_search_enriched_texts")

* Type: `bool`
* Default: `False`
* Description: Enhances BM25 hybrid search by enriching indexed text with document metadata including filenames, titles, sections, and snippets. This improves keyword recall for metadata-based queries, allowing searches to match on document names and structural elements in addition to content.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

Enabling this feature increases the text volume indexed by BM25, which may impact storage requirements and indexing performance. However, it significantly improves search results when users query based on document names, titles, or structural elements rather than just content.

#### `RAG_TEMPLATE`[​](#rag%5Ftemplate "Direct link to rag_template")

* Type: `str`
* Default: The value of `DEFAULT_RAG_TEMPLATE` environment variable.

`DEFAULT_RAG_TEMPLATE`:

```

### Task:
Respond to the user query using the provided context, incorporating inline citations in the format [id] **only when the <source> tag includes an explicit id attribute** (e.g., <source id="1">).

### Guidelines:
- If you don't know the answer, clearly state that.
- If uncertain, ask the user for clarification.
- Respond in the same language as the user's query.
- If the context is unreadable or of poor quality, inform the user and provide the best possible answer.
- If the answer isn't present in the context but you possess the knowledge, explain this to the user and provide the answer using your own understanding.
- **Only include inline citations using [id] (e.g., [1], [2]) when the <source> tag includes an id attribute.**
- Do not cite if the <source> tag does not contain an id attribute.
- Do not use XML tags in your response.
- Ensure citations are concise and directly related to the information provided.

### Example of Citation:
If the user asks about a specific topic and the information is found in a source with a provided id attribute, the response should include the citation like in the following example:
* "According to the study, the proposed method increases efficiency by 20% [1]."

### Output:
Provide a clear and direct response to the user's query, including inline citations in the format [id] only when the <source> tag with id attribute is present in the context.

<context>
{{CONTEXT}}
</context>

<user_query>
{{QUERY}}
</user_query>

```

* Description: Template to use when injecting RAG documents into chat completion.
* Persistence: This environment variable is a `PersistentConfig` variable.

### Document Processing[​](#document-processing "Direct link to Document Processing")

#### `CHUNK_SIZE`[​](#chunk%5Fsize "Direct link to chunk_size")

* Type: `int`
* Default: `1000`
* Description: Sets the document chunk size for embeddings.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CHUNK_OVERLAP`[​](#chunk%5Foverlap "Direct link to chunk_overlap")

* Type: `int`
* Default: `100`
* Description: Specifies how much overlap there should be between chunks.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `CHUNK_MIN_SIZE_TARGET`[​](#chunk%5Fmin%5Fsize%5Ftarget "Direct link to chunk_min_size_target")

* Type: `int`
* Default: `0`
* Description: Chunks smaller than this threshold will be intelligently merged with neighboring chunks when possible. This helps prevent tiny, low-quality fragments that can hurt retrieval performance and waste embedding resources. This feature only works when `ENABLE_MARKDOWN_HEADER_TEXT_SPLITTER` is enabled. Set to `0` to disable merging. For more information on the benefits and configuration, see the [RAG guide](/features/chat-conversations/rag#chunking-configuration).
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_TEXT_SPLITTER`[​](#rag%5Ftext%5Fsplitter "Direct link to rag_text_splitter")

* Type: `str`
* Options:  
   * `character`  
   * `token`
* Default: `character`
* Description: Sets the text splitter for RAG models. Use `character` for RecursiveCharacterTextSplitter or `token` for TokenTextSplitter (Tiktoken-based).
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_MARKDOWN_HEADER_TEXT_SPLITTER`[​](#enable%5Fmarkdown%5Fheader%5Ftext%5Fsplitter "Direct link to enable_markdown_header_text_splitter")

* Type: `bool`
* Default: `True`
* Description: Enables markdown header text splitting as a preprocessing step before character or token splitting. When enabled, documents are first split by markdown headers (h1-h6), then the resulting chunks are further processed by the configured text splitter (`RAG_TEXT_SPLITTER`). This helps preserve document structure and context across chunks.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

**Migration from `markdown_header` TEXT\_SPLITTER**

The `markdown_header` option has been removed from `RAG_TEXT_SPLITTER`. Markdown header splitting is now a preprocessing step controlled by `ENABLE_MARKDOWN_HEADER_TEXT_SPLITTER`. If you were using `RAG_TEXT_SPLITTER=markdown_header`, switch to `character` or `token` and ensure `ENABLE_MARKDOWN_HEADER_TEXT_SPLITTER` is enabled (it is enabled by default).

#### `TIKTOKEN_CACHE_DIR`[​](#tiktoken%5Fcache%5Fdir "Direct link to tiktoken_cache_dir")

* Type: `str`
* Default: `{CACHE_DIR}/tiktoken`
* Description: Sets the directory for TikToken cache.

#### `TIKTOKEN_ENCODING_NAME`[​](#tiktoken%5Fencoding%5Fname "Direct link to tiktoken_encoding_name")

* Type: `str`
* Default: `cl100k_base`
* Description: Sets the encoding name for TikToken.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PDF_EXTRACT_IMAGES`[​](#pdf%5Fextract%5Fimages "Direct link to pdf_extract_images")

* Type: `bool`
* Default: `False`
* Description: Extracts images from PDFs using OCR when loading documents.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PDF_LOADER_MODE`[​](#pdf%5Floader%5Fmode "Direct link to pdf_loader_mode")

* Type: `str`
* Options:  
   * `page` \- Creates one document per page (default).  
   * `single` \- Combines all pages into one document for better chunking across page boundaries.
* Default: `page`
* Description: Controls how PDFs are loaded and split into documents when using the **default content extraction engine** (PyPDFLoader). Page mode creates one document per page, while single mode combines all pages into one document, which can improve chunking quality when content spans across page boundaries. This setting has no effect when using external content extraction engines like Tika, Docling, Document Intelligence, MinerU, or Mistral OCR, as those engines have their own document handling logic.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_FILE_MAX_SIZE`[​](#rag%5Ffile%5Fmax%5Fsize "Direct link to rag_file_max_size")

* Type: `int`
* Description: Sets the maximum size of a file in megabytes that can be uploaded for document ingestion.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_FILE_MAX_COUNT`[​](#rag%5Ffile%5Fmax%5Fcount "Direct link to rag_file_max_count")

* Type: `int`
* Description: Sets the maximum number of files that can be uploaded at once for document ingestion.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_ALLOWED_FILE_EXTENSIONS`[​](#rag%5Fallowed%5Ffile%5Fextensions "Direct link to rag_allowed_file_extensions")

* Type: `list` of `str`
* Default: `[]` (which means all supported file types are allowed)
* Description: Specifies which file extensions are permitted for upload.

```
["pdf,docx,txt"]
```

* Persistence: This environment variable is a `PersistentConfig` variable.

info

When configuring `RAG_FILE_MAX_SIZE` and `RAG_FILE_MAX_COUNT`, ensure that the values are reasonable to prevent excessive file uploads and potential performance issues.

### Embedding Engine Configuration[​](#embedding-engine-configuration "Direct link to Embedding Engine Configuration")

#### General Embedding Settings[​](#general-embedding-settings "Direct link to General Embedding Settings")

#### `RAG_EMBEDDING_BATCH_SIZE`[​](#rag%5Fembedding%5Fbatch%5Fsize "Direct link to rag_embedding_batch_size")

* Type: `int`
* Default: `1`
* Description: Controls how many text chunks are embedded in a single API request when using external embedding providers (Ollama, OpenAI, or Azure OpenAI). Higher values (20-100+; max 16000 (not recommended)) may process documents faster by sending less, but larger API requests. Some external APIs do not support batching or sending more than 1 chunk per request. In such casey you must leave this at `1`. Default is 1 (safest option if the API does not support batching / more than 1 chunk per request). This setting only applies to external embedding engines, not the default SentenceTransformers engine.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

Check if your API and embedding model supports batched processing. Only increase this variable's value if it does - otherwise you might run into unexpected issues.

#### `ENABLE_ASYNC_EMBEDDING`[​](#enable%5Fasync%5Fembedding "Direct link to enable_async_embedding")

* Type: `bool`
* Default: `true`
* Description: Runs embedding tasks asynchronously (parallelized) for maximum performance. Only works for Ollama, OpenAI and Azure OpenAI, does not affect sentence transformer setups.
* Persistence: This environment variable is a `PersistentConfig` variable.

tip

It may be needed to increase the value of `THREAD_POOL_SIZE` if many other users are simultaneously using your Open WebUI instance while having async embeddings turned on to prevent

warning

Enabling this will potentially send thousands of requests per minute. If you are embedding locally, ensure that you can handle this amount of requests, otherwise turn this off to return to sequential embedding (slower but will always work). If you are embedding externally via API, ensure your rate limits are high enough to handle parallel embedding. (Usually, OpenAI can handle thousands of embedding requests per minute, even on the lowest API tier).

#### `RAG_EMBEDDING_CONCURRENT_REQUESTS`[​](#rag%5Fembedding%5Fconcurrent%5Frequests "Direct link to rag_embedding_concurrent_requests")

* Type: `int`
* Default: `0`
* Description: Limits the number of concurrent embedding API requests when async embedding is enabled. Uses an asyncio semaphore to throttle parallel requests. Set to `0` for unlimited concurrency (default behavior), or set to a positive integer to cap simultaneous requests. Useful for respecting rate limits on external embedding APIs or reducing load on local embedding servers.
* Persistence: This environment variable is a `PersistentConfig` variable.

tip

If you are hitting rate limits from your embedding provider (e.g., 429 errors), set this to a value that keeps you within your API tier's rate limit (e.g., `5` or `10`). This is especially helpful when uploading large documents that generate many embedding batches.

#### `RAG_EMBEDDING_TIMEOUT`[​](#rag%5Fembedding%5Ftimeout "Direct link to rag_embedding_timeout")

* Type: `int` (seconds)
* Default: `None` (no timeout)
* Description: Sets an optional timeout in seconds for embedding operations during document upload. When set, embedding requests that exceed this duration will be aborted with a timeout error. When unset (default), embedding operations run without a time limit. This setting is primarily relevant for deployments using the default **SentenceTransformers** embedding engine, where embeddings run locally and can take longer on slower hardware. External embedding engines (Ollama, OpenAI, Azure OpenAI) have their own timeout mechanisms and are generally not affected by this setting.

info

This variable was introduced alongside a fix for **uvicorn worker death during document uploads**. Previously, local embedding operations could block the worker thread long enough to trigger uvicorn's health check timeout (default: 5 seconds), causing the worker process to be killed. The underlying fix uses `run_coroutine_threadsafe` to keep the main event loop responsive to health checks regardless of this timeout setting. The timeout is purely a safety net for aborting abnormally long embedding operations — it does not affect worker health check behavior.

#### `RAG_EMBEDDING_CONTENT_PREFIX`[​](#rag%5Fembedding%5Fcontent%5Fprefix "Direct link to rag_embedding_content_prefix")

* Type: `str`
* Default: `None`
* Description: Sets the prefix string prepended to document content before generating embeddings. Some embedding models (e.g., nomic-embed-text) require task-specific prefixes to differentiate between content being stored vs. queries being searched. For nomic-embed-text, set this to `search_document: `. Only needed if your embedding model's documentation specifies a content/document prefix.

#### `RAG_EMBEDDING_QUERY_PREFIX`[​](#rag%5Fembedding%5Fquery%5Fprefix "Direct link to rag_embedding_query_prefix")

* Type: `str`
* Default: `None`
* Description: Sets the prefix string prepended to user queries before generating embeddings for retrieval. This is the counterpart to `RAG_EMBEDDING_CONTENT_PREFIX`. For nomic-embed-text, set this to `search_query: `. Only needed if your embedding model's documentation specifies a query prefix.

#### `RAG_EMBEDDING_PREFIX_FIELD_NAME`[​](#rag%5Fembedding%5Fprefix%5Ffield%5Fname "Direct link to rag_embedding_prefix_field_name")

* Type: `str`
* Default: `None`
* Description: Specifies the JSON field name used to pass the prefix to the embedding API request body. When set along with a prefix value, the prefix is sent as a separate field in the API request rather than being prepended to the text. Required for embedding APIs that accept the prefix as a dedicated parameter instead of inline text.

#### OpenAI Embeddings[​](#openai-embeddings "Direct link to OpenAI Embeddings")

#### `RAG_OPENAI_API_BASE_URL`[​](#rag%5Fopenai%5Fapi%5Fbase%5Furl "Direct link to rag_openai_api_base_url")

* Type: `str`
* Default: `${OPENAI_API_BASE_URL}`
* Description: Sets the OpenAI base API URL to use for RAG embeddings.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_OPENAI_API_KEY`[​](#rag%5Fopenai%5Fapi%5Fkey "Direct link to rag_openai_api_key")

* Type: `str`
* Default: `${OPENAI_API_KEY}`
* Description: Sets the OpenAI API key to use for RAG embeddings.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_EMBEDDING_OPENAI_BATCH_SIZE`[​](#rag%5Fembedding%5Fopenai%5Fbatch%5Fsize "Direct link to rag_embedding_openai_batch_size")

* Type: `int`
* Default: `1`
* Description: Sets the batch size for OpenAI embeddings.

#### Azure OpenAI Embeddings[​](#azure-openai-embeddings "Direct link to Azure OpenAI Embeddings")

#### `RAG_AZURE_OPENAI_BASE_URL`[​](#rag%5Fazure%5Fopenai%5Fbase%5Furl "Direct link to rag_azure_openai_base_url")

* Type: `str`
* Default: `None`
* Description: Sets the base URL for Azure OpenAI Services when using Azure OpenAI for RAG embeddings. Should be in the format `https://{your-resource-name}.openai.azure.com`.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_AZURE_OPENAI_API_KEY`[​](#rag%5Fazure%5Fopenai%5Fapi%5Fkey "Direct link to rag_azure_openai_api_key")

* Type: `str`
* Default: `None`
* Description: Sets the API key for Azure OpenAI Services when using Azure OpenAI for RAG embeddings.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_AZURE_OPENAI_API_VERSION`[​](#rag%5Fazure%5Fopenai%5Fapi%5Fversion "Direct link to rag_azure_openai_api_version")

* Type: `str`
* Default: `None`
* Description: Sets the API version for Azure OpenAI Services when using Azure OpenAI for RAG embeddings. Common values include `2023-05-15`, `2023-12-01-preview`, or `2024-02-01`.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### Ollama Embeddings[​](#ollama-embeddings "Direct link to Ollama Embeddings")

#### `RAG_OLLAMA_BASE_URL`[​](#rag%5Follama%5Fbase%5Furl "Direct link to rag_ollama_base_url")

* Type: `str`
* Description: Sets the base URL for Ollama API used in RAG models.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_OLLAMA_API_KEY`[​](#rag%5Follama%5Fapi%5Fkey "Direct link to rag_ollama_api_key")

* Type: `str`
* Description: Sets the API key for Ollama API used in RAG models.
* Persistence: This environment variable is a `PersistentConfig` variable.

### Reranking[​](#reranking "Direct link to Reranking")

#### `RAG_RERANKING_ENGINE`[​](#rag%5Freranking%5Fengine "Direct link to rag_reranking_engine")

* Type: `str`
* Options: `external`, or empty for local Sentence-Transformer CrossEncoder
* Default: Empty string (local reranking)
* Description: Specifies the reranking engine to use. Set to `external` to use an external reranker API (requires `RAG_EXTERNAL_RERANKER_URL`). Leave empty to use a local Sentence-Transformer CrossEncoder model.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_RERANKING_MODEL`[​](#rag%5Freranking%5Fmodel "Direct link to rag_reranking_model")

* Type: `str`
* Description: Sets a model for reranking results. Locally, a Sentence-Transformer model is used.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_RERANKING_BATCH_SIZE`[​](#rag%5Freranking%5Fbatch%5Fsize "Direct link to rag_reranking_batch_size")

* Type: `int`
* Default: `32`
* Description: Controls how many query–document pairs are scored in a single batch during local reranking. Higher values use more memory but can be faster on GPUs with sufficient VRAM. This applies to the local ColBERT/CrossEncoder reranking model's `predict()` call.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SENTENCE_TRANSFORMERS_CROSS_ENCODER_SIGMOID_ACTIVATION_FUNCTION`[​](#sentence%5Ftransformers%5Fcross%5Fencoder%5Fsigmoid%5Factivation%5Ffunction "Direct link to sentence_transformers_cross_encoder_sigmoid_activation_function")

* Type: `bool`
* Default: `True`
* Description: When enabled (default), applies sigmoid normalization to local CrossEncoder reranking scores to ensure they fall within the 0-1 range. This allows the relevance threshold setting to work correctly with models like MS MARCO that output raw logits.

#### `RAG_EXTERNAL_RERANKER_TIMEOUT`[​](#rag%5Fexternal%5Freranker%5Ftimeout "Direct link to rag_external_reranker_timeout")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the timeout in seconds for external reranker API requests during RAG document retrieval. Leave empty to use default timeout behavior.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_EXTERNAL_RERANKER_URL`[​](#rag%5Fexternal%5Freranker%5Furl "Direct link to rag_external_reranker_url")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the **full URL** for the external reranking API.
* Persistence: This environment variable is a `PersistentConfig` variable.

warning

You **MUST** provide the full URL, including the endpoint path (e.g., `https://api.yourprovider.com/v1/rerank`). The system does **not** automatically append `/v1/rerank` or any other path to the base URL you provide.

#### `RAG_EXTERNAL_RERANKER_API_KEY`[​](#rag%5Fexternal%5Freranker%5Fapi%5Fkey "Direct link to rag_external_reranker_api_key")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the API key for the external reranking API.
* Persistence: This environment variable is a `PersistentConfig` variable.

### Query Generation[​](#query-generation "Direct link to Query Generation")

#### `ENABLE_RETRIEVAL_QUERY_GENERATION`[​](#enable%5Fretrieval%5Fquery%5Fgeneration "Direct link to enable_retrieval_query_generation")

* Type: `bool`
* Default: `True`
* Description: Enables or disables retrieval query generation.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_QUERIES_CACHE`[​](#enable%5Fqueries%5Fcache "Direct link to enable_queries_cache")

* Type: `bool`
* Default: `False`
* Description: Enables request-scoped caching of LLM-generated search queries. When enabled, queries generated for web search are **cached** and automatically **reused** for file/knowledge base retrieval within the same request. This **eliminates duplicate LLM calls** when both web search and RAG are active, **reducing token usage and latency** while maintaining search quality. It is highly recommended to enable this especially in larger setups.

#### `QUERY_GENERATION_PROMPT_TEMPLATE`[​](#query%5Fgeneration%5Fprompt%5Ftemplate "Direct link to query_generation_prompt_template")

* Type: `str`
* Default: The value of `DEFAULT_QUERY_GENERATION_PROMPT_TEMPLATE` environment variable.

`DEFAULT_QUERY_GENERATION_PROMPT_TEMPLATE`:

```

### Task:
Analyze the chat history to determine the necessity of generating search queries, in the given language. By default, **prioritize generating 1-3 broad and relevant search queries** unless it is absolutely certain that no additional information is required. The aim is to retrieve comprehensive, updated, and valuable information even with minimal uncertainty. If no search is unequivocally needed, return an empty list.

### Guidelines:
- Respond **EXCLUSIVELY** with a JSON object. Any form of extra commentary, explanation, or additional text is strictly prohibited.
- When generating search queries, respond in the format: { "queries": ["query1", "query2"] }, ensuring each query is distinct, concise, and relevant to the topic.
- If and only if it is entirely certain that no useful results can be retrieved by a search, return: { "queries": [] }.
- Err on the side of suggesting search queries if there is **any chance** they might provide useful or updated information.
- Be concise and focused on composing high-quality search queries, avoiding unnecessary elaboration, commentary, or assumptions.
- Today's date is: {{CURRENT_DATE}}.
- Always prioritize providing actionable and broad queries that maximize informational coverage.

### Output:
Strictly return in JSON format:
{
  "queries": ["query1", "query2"]
}

### Chat History:
<chat_history>
{{MESSAGES:END:6}}
</chat_history>

```

* Description: Sets the prompt template for query generation.
* Persistence: This environment variable is a `PersistentConfig` variable.

### Document Intelligence (Azure)[​](#document-intelligence-azure "Direct link to Document Intelligence (Azure)")

#### `DOCUMENT_INTELLIGENCE_ENDPOINT`[​](#document%5Fintelligence%5Fendpoint "Direct link to document_intelligence_endpoint")

* Type: `str`
* Default: `None`
* Description: Specifies the endpoint for document intelligence.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DOCUMENT_INTELLIGENCE_KEY`[​](#document%5Fintelligence%5Fkey "Direct link to document_intelligence_key")

* Type: `str`
* Default: `None`
* Description: Specifies the key for document intelligence.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DOCUMENT_INTELLIGENCE_MODEL`[​](#document%5Fintelligence%5Fmodel "Direct link to document_intelligence_model")

* Type: `str`
* Default: `None`
* Description: Specifies the model for document intelligence.
* Persistence: This environment variable is a `PersistentConfig` variable.

### Advanced Settings[​](#advanced-settings "Direct link to Advanced Settings")

#### `BYPASS_EMBEDDING_AND_RETRIEVAL`[​](#bypass%5Fembedding%5Fand%5Fretrieval "Direct link to bypass_embedding_and_retrieval")

* Type: `bool`
* Default: `False`
* Description: Bypasses the embedding and retrieval process.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_FULL_CONTEXT`[​](#rag%5Ffull%5Fcontext "Direct link to rag_full_context")

* Type: `bool`
* Default: `False`
* Description: Specifies whether to use the full context for RAG.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `RAG_SYSTEM_CONTEXT`[​](#rag%5Fsystem%5Fcontext "Direct link to rag_system_context")

* Type: `bool`
* Default: `False`
* Description: When enabled, injects RAG context into the **system message** instead of the user message. This is highly recommended for optimizing performance when using models that support **KV prefix caching** or **Prompt Caching**. This includes local engines (like Ollama, llama.cpp, or vLLM) and cloud providers / Model-as-a-Service providers (like OpenAI and Vertex AI). By placing the context in the system message, it remains at a stable position at the start of the conversation, allowing the cache to persist across multiple turns. When disabled (default), context is injected into the user message, which shifts position each turn and invalidates the cache.

#### `ENABLE_RAG_LOCAL_WEB_FETCH`[​](#enable%5Frag%5Flocal%5Fweb%5Ffetch "Direct link to enable_rag_local_web_fetch")

* Type: `bool`
* Default: `False`
* Description: Controls whether RAG web fetch operations can access URLs that resolve to private/local network IP addresses.
* Persistence: This environment variable is a `PersistentConfig` variable.

When disabled (default), Open WebUI blocks web fetch requests to URLs that resolve to private IP addresses, including:

* IPv4 private ranges (`10.x.x.x`, `172.16.x.x`\-`172.31.x.x`, `192.168.x.x`, `127.x.x.x`)
* IPv6 private ranges

This is a **Server-Side Request Forgery (SSRF) protection**. Without this safeguard, a malicious user could provide URLs that appear external but resolve to internal addresses, potentially exposing internal services, cloud metadata endpoints, or other sensitive resources.

warning

Only enable this setting if you need to fetch content from internal network resources (e.g., an internal wiki or intranet) **and** you trust all users with access to your Open WebUI instance. Enabling this in a multi-tenant or public-facing deployment introduces significant security risk.

### Google Drive[​](#google-drive "Direct link to Google Drive")

#### `ENABLE_GOOGLE_DRIVE_INTEGRATION`[​](#enable%5Fgoogle%5Fdrive%5Fintegration "Direct link to enable_google_drive_integration")

* Type: `bool`
* Default: `False`
* Description: Enables or disables Google Drive integration. If set to true, and `GOOGLE_DRIVE_CLIENT_ID` & `GOOGLE_DRIVE_API_KEY` are both configured, Google Drive will appear as an upload option in the chat UI.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

When enabling `GOOGLE_DRIVE_INTEGRATION`, ensure that you have configured `GOOGLE_DRIVE_CLIENT_ID` and `GOOGLE_DRIVE_API_KEY` correctly, and have reviewed Google's terms of service and usage guidelines.

#### `GOOGLE_DRIVE_CLIENT_ID`[​](#google%5Fdrive%5Fclient%5Fid "Direct link to google_drive_client_id")

* Type: `str`
* Description: Sets the client ID for Google Drive (client must be configured with Drive API and Picker API enabled).
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `GOOGLE_DRIVE_API_KEY`[​](#google%5Fdrive%5Fapi%5Fkey "Direct link to google_drive_api_key")

* Type: `str`
* Description: Sets the API key for Google Drive integration.
* Persistence: This environment variable is a `PersistentConfig` variable.

### OneDrive[​](#onedrive "Direct link to OneDrive")

info

For a step-by-step setup guide, check out our tutorial: [Configuring OneDrive & SharePoint Integration](https://docs.openwebui.com/tutorials/integrations/onedrive-sharepoint/).

#### `ENABLE_ONEDRIVE_INTEGRATION`[​](#enable%5Fonedrive%5Fintegration "Direct link to enable_onedrive_integration")

* Type: `bool`
* Default: `False`
* Description: Enables or disables the Microsoft OneDrive integration feature globally.
* Persistence: This environment variable is a `PersistentConfig` variable.

warning

Configuring OneDrive integration is a multi-step process that requires creating and correctly configuring an Azure App Registration. The authentication flow also depends on a browser pop-up window. Please ensure that your browser's pop-up blocker is disabled for your Open WebUI domain to allow the authentication and file selection window to appear.

#### `ENABLE_ONEDRIVE_PERSONAL`[​](#enable%5Fonedrive%5Fpersonal "Direct link to enable_onedrive_personal")

* Type: `bool`
* Default: `True`
* Description: Controls whether the "Personal OneDrive" option appears in the attachment menu. Requires `ONEDRIVE_PERSONAL_CLIENT_ID` to be configured.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_ONEDRIVE_BUSINESS`[​](#enable%5Fonedrive%5Fbusiness "Direct link to enable_onedrive_business")

* Type: `bool`
* Default: `True`
* Description: Controls whether the "Work/School OneDrive" option appears in the attachment menu. Requires `ONEDRIVE_CLIENT_ID` to be configured.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ONEDRIVE_CLIENT_ID`[​](#onedrive%5Fclient%5Fid "Direct link to onedrive_client_id")

* Type: `str`
* Default: `None`
* Description: Generic environment variable for the OneDrive Client ID. You should rather use the specific `ONEDRIVE_CLIENT_ID_PERSONAL` or `ONEDRIVE_CLIENT_ID_BUSINESS` variables. This exists as a legacy option for backwards compatibility.

#### `ONEDRIVE_CLIENT_ID_PERSONAL`[​](#onedrive%5Fclient%5Fid%5Fpersonal "Direct link to onedrive_client_id_personal")

* Type: `str`
* Default: `None`
* Description: Specifies the Application (client) ID for the **Personal OneDrive** integration. This requires a separate Azure App Registration configured to support personal Microsoft accounts. **Do not put the business OneDrive client ID here!**

#### `ONEDRIVE_CLIENT_ID_BUSINESS`[​](#onedrive%5Fclient%5Fid%5Fbusiness "Direct link to onedrive_client_id_business")

* Type: `str`
* Default: `None`
* Description: Specifies the Application (client) ID for the **Work/School (Business) OneDrive** integration. This requires a separate Azure App Registration configured to support personal Microsoft accounts. **Do not put the personal OneDrive client ID here!**

info

This Client ID (also known as Application ID) is obtained from an Azure App Registration within your Microsoft Entra ID (formerly Azure AD) tenant. When configuring the App Registration in Azure, the Redirect URI must be set to the URL of your Open WebUI instance and configured as a **Single-page application (SPA)** type for the authentication to succeed.

#### `ONEDRIVE_SHAREPOINT_URL`[​](#onedrive%5Fsharepoint%5Furl "Direct link to onedrive_sharepoint_url")

* Type: `str`
* Default: `None`
* Description: Specifies the root SharePoint site URL for the work/school integration, e.g., `https://companyname.sharepoint.com`.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

This variable is essential for the work/school integration. It should point to the root SharePoint site associated with your tenant, enabling access to SharePoint document libraries.

#### `ONEDRIVE_SHAREPOINT_TENANT_ID`[​](#onedrive%5Fsharepoint%5Ftenant%5Fid "Direct link to onedrive_sharepoint_tenant_id")

* Type: `str`
* Default: `None`
* Description: Specifies the Directory (tenant) ID for the work/school integration. This is obtained from your business-focused Azure App Registration.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

This Tenant ID (also known as Directory ID) is required for the work/school integration. You can find this value on the main overview page of your Azure App Registration in the Microsoft Entra ID portal.

## Web Search[​](#web-search "Direct link to Web Search")

#### `ENABLE_WEB_SEARCH`[​](#enable%5Fweb%5Fsearch "Direct link to enable_web_search")

* Type: `bool`
* Default: `False`
* Description: Enable web search toggle.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `ENABLE_SEARCH_QUERY_GENERATION`[​](#enable%5Fsearch%5Fquery%5Fgeneration "Direct link to enable_search_query_generation")

* Type: `bool`
* Default: `True`
* Description: Only applies to Default Function Calling mode, which is legacy and no longer supported. If True: an LLM generates optimized, distilled search queries from the conversation context. If False: the user's last message is used verbatim as the web search query. Native Mode (the supported mode) uses the model's own `search_web` tool call and does not consult this setting.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `WEB_SEARCH_TRUST_ENV`[​](#web%5Fsearch%5Ftrust%5Fenv "Direct link to web_search_trust_env")

* Type: `bool`
* Default: `False`
* Description: Enables proxy set by `http_proxy` and `https_proxy` during web search content fetching.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `WEB_FETCH_FILTER_LIST`[​](#web%5Ffetch%5Ffilter%5Flist "Direct link to web_fetch_filter_list")

* Type: `string` (comma-separated list)
* Default: `""` (empty, but default blocklist is always applied)
* Description: Configures additional URL filtering rules for web fetch operations to prevent Server-Side Request Forgery (SSRF) attacks. The system includes a default blocklist that protects against access to cloud metadata endpoints (AWS, Google Cloud, Azure, Alibaba Cloud). Entries without a ! prefix are treated as an allow list (only these domains are permitted), while entries with a ! prefix are added to the block list (these domains are always denied). The default blocklist includes !169.254.169.254, !fd00:ec2::254, !metadata.google.internal, !metadata.azure.com, and !100.100.100.200\. Custom entries are merged with the default blocklist.

info

Example:

Block additional domains: WEB\_FETCH\_FILTER\_LIST="!internal.company.com,!192.168.1.1" Allow only specific domains: WEB\_FETCH\_FILTER\_LIST="example.com,trusted-site.org"

#### `WEB_SEARCH_DOMAIN_FILTER_LIST`[​](#web%5Fsearch%5Fdomain%5Ffilter%5Flist "Direct link to web_search_domain_filter_list")

* Type: `list` of `str`
* Default: `[]`
* Description: Comma-separated list of domains to filter web search results. Domains prefixed with `!` are blocked; domains without prefix create an allowlist (only those domains permitted).
* Example: `wikipedia.org,github.com,!malicious-site.com`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `WEB_SEARCH_RESULT_COUNT`[​](#web%5Fsearch%5Fresult%5Fcount "Direct link to web_search_result_count")

* Type: `int`
* Default: `3`
* Description: Maximum number of web search results to crawl. In Native/Agentic tool calling, this is also the default `search_web` result count when the model omits `count`, and the maximum cap when the model provides `count`.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `WEB_SEARCH_CONCURRENT_REQUESTS`[​](#web%5Fsearch%5Fconcurrent%5Frequests "Direct link to web_search_concurrent_requests")

* Type: `int`
* Default: `0`
* Description: Limits the number of concurrent search requests to the search engine provider. Set to `0` for unlimited concurrency (default). Set to `1` for sequential execution to prevent rate limiting errors (e.g., Brave Free Tier).
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `WEB_FETCH_MAX_CONTENT_LENGTH`[​](#web%5Ffetch%5Fmax%5Fcontent%5Flength "Direct link to web_fetch_max_content_length")

* Type: `int`
* Default: None (no limit)
* Description: Maximum number of characters to return from fetched URLs. When set, content exceeding this limit is truncated. Previously hardcoded at 50,000 characters. Leave empty or unset to return full content without truncation. Useful for controlling context window usage with large web pages.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `WEB_LOADER_CONCURRENT_REQUESTS`[​](#web%5Floader%5Fconcurrent%5Frequests "Direct link to web_loader_concurrent_requests")

* Type: `int`
* Default: `10`
* Description: Specifies the number of concurrent requests used by the web loader to fetch content from web pages returned by search results. This directly impacts how many pages can be crawled simultaneously.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

"WEB\_LOADER\_CONCURRENT\_REQUESTS" was previously named "WEB\_SEARCH\_CONCURRENT\_REQUESTS". The variable "WEB\_SEARCH\_CONCURRENT\_REQUESTS" has been repurposed to control the concurrency of the search engine requests (see above). To control the web _loader_ concurrency (fetching content from results), you MUST use "WEB\_LOADER\_CONCURRENT\_REQUESTS".

#### `WEB_SEARCH_ENGINE`[​](#web%5Fsearch%5Fengine "Direct link to web_search_engine")

* Type: `str`
* Options:  
   * `searxng` \- Uses the [SearXNG](https://github.com/searxng/searxng) search engine.  
   * `google_pse` \- Uses the [Google Programmable Search Engine](https://programmablesearchengine.google.com/about/).  
   * `brave` \- Uses the [Brave search engine](https://brave.com/search/api/).  
   * `kagi` \- Uses the [Kagi](https://www.kagi.com/) search engine.  
   * `mojeek` \- Uses the [Mojeek](https://www.mojeek.com/) search engine.  
   * `bocha` \- Uses the Bocha search engine.  
   * `serpstack` \- Uses the [Serpstack](https://serpstack.com/) search engine.  
   * `serper` \- Uses the [Serper](https://serper.dev/) search engine.  
   * `serply` \- Uses the [Serply](https://serply.io/) search engine.  
   * `searchapi` \- Uses the [SearchAPI](https://www.searchapi.io/) search engine.  
   * `serpapi` \- Uses the [SerpApi](https://serpapi.com/) search engine.  
   * `duckduckgo` \- Uses the [DuckDuckGo](https://duckduckgo.com/) search engine.  
   * `tavily` \- Uses the [Tavily](https://tavily.com/) search engine.  
   * `jina` \- Uses the [Jina](https://jina.ai/) search engine.  
   * `bing` \- Uses the [Bing](https://www.bing.com/) search engine.  
   * `exa` \- Uses the [Exa](https://exa.ai/) search engine.  
   * `perplexity` \- Uses the [Perplexity API](https://www.perplexity.ai/) to access perplexity's AI models. Calls their AI models, which execute a search and also return a full response.  
   * `perplexity_search` \- Uses the [Perplexity Search API](https://www.perplexity.ai/) search engine. In contrast to the `perplexity` option, this uses Perplexity's web search API for searching the web and retrieving results.  
   * `sougou` \- Uses the [Sougou](https://www.sogou.com/) search engine.  
   * `ollama_cloud` \- Uses the [Ollama Cloud](https://ollama.com/blog/web-search) search engine.  
   * `azure_ai_search`  
   * `yacy`  
   * `yandex` \- Uses the [Yandex Search API](https://yandex.cloud/en/docs/search-api/api-ref/WebSearch/search).  
   * `youcom` \- Uses the [You.com](https://you.com/) YDC Index API for web search.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `DDGS_BACKEND`[​](#ddgs%5Fbackend "Direct link to ddgs_backend")

* Type: `str`
* Default: `auto`
* Options: `auto` (Random), `bing`, `brave`, `duckduckgo`, `google`, `grokipedia`, `mojeek`, `wikipedia`, `yahoo`, `yandex`.
* Description: Specifies the backend to be used by the DDGS engine.
* Persistence: This environment variable is a `PersistentConfig` variable. It can be configured in the **Admin Panel > Settings > Web Search > DDGS Backend** when DDGS is selected as the search engine.

#### `BYPASS_WEB_SEARCH_EMBEDDING_AND_RETRIEVAL`[​](#bypass%5Fweb%5Fsearch%5Fembedding%5Fand%5Fretrieval "Direct link to bypass_web_search_embedding_and_retrieval")

* Type: `bool`
* Default: `False`
* Description: Bypasses the web search embedding and retrieval process.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `BYPASS_WEB_SEARCH_WEB_LOADER`[​](#bypass%5Fweb%5Fsearch%5Fweb%5Floader "Direct link to bypass_web_search_web_loader")

* Type: `bool`
* Default: `False`
* Description: Bypasses the web loader when performing web search. When enabled, only snippets from the search engine are used, and the full page content is not fetched.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SEARXNG_QUERY_URL`[​](#searxng%5Fquery%5Furl "Direct link to searxng_query_url")

* Type: `str`
* Description: The [SearXNG search API](https://docs.searxng.org/dev/search%5Fapi.html) URL supporting JSON output. `<query>` is replaced with the search query. Example: `http://searxng.local/search?q=<query>`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SEARXNG_LANGUAGE`[​](#searxng%5Flanguage "Direct link to searxng_language")

* Type: `str`
* Default: `all`
* Description: This variable is used in the request to searxng as the "search language" (arguement "language").
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `GOOGLE_PSE_API_KEY`[​](#google%5Fpse%5Fapi%5Fkey "Direct link to google_pse_api_key")

* Type: `str`
* Description: Sets the API key for the Google Programmable Search Engine (PSE) service.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `GOOGLE_PSE_ENGINE_ID`[​](#google%5Fpse%5Fengine%5Fid "Direct link to google_pse_engine_id")

* Type: `str`
* Description: The engine ID for the Google Programmable Search Engine (PSE) service.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `BRAVE_SEARCH_API_KEY`[​](#brave%5Fsearch%5Fapi%5Fkey "Direct link to brave_search_api_key")

* Type: `str`
* Description: Sets the API key for the Brave Search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

Brave's free tier enforces a rate limit of 1 request per second. Open WebUI automatically retries requests that receive HTTP 429 rate limit errors after a 1-second delay. For free tier users, set `WEB_SEARCH_CONCURRENT_REQUESTS` to `1` to ensure sequential request processing. See the [Brave web search documentation](/features/chat-conversations/web-search/providers/brave) for more details.

#### `KAGI_SEARCH_API_KEY`[​](#kagi%5Fsearch%5Fapi%5Fkey "Direct link to kagi_search_api_key")

* Type: `str`
* Description: Sets the API key for Kagi Search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `MOJEEK_SEARCH_API_KEY`[​](#mojeek%5Fsearch%5Fapi%5Fkey "Direct link to mojeek_search_api_key")

* Type: `str`
* Description: Sets the API key for Mojeek Search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SERPSTACK_API_KEY`[​](#serpstack%5Fapi%5Fkey "Direct link to serpstack_api_key")

* Type: `str`
* Description: Sets the API key for Serpstack search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SERPSTACK_HTTPS`[​](#serpstack%5Fhttps "Direct link to serpstack_https")

* Type: `bool`
* Default: `True`
* Description: Configures the use of HTTPS for Serpstack requests. Free tier requests are restricted to HTTP only.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SERPER_API_KEY`[​](#serper%5Fapi%5Fkey "Direct link to serper_api_key")

* Type: `str`
* Description: Sets the API key for Serper search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SERPLY_API_KEY`[​](#serply%5Fapi%5Fkey "Direct link to serply_api_key")

* Type: `str`
* Description: Sets the API key for Serply search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SEARCHAPI_API_KEY`[​](#searchapi%5Fapi%5Fkey "Direct link to searchapi_api_key")

* Type: `str`
* Description: Sets the API key for SearchAPI.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SEARCHAPI_ENGINE`[​](#searchapi%5Fengine "Direct link to searchapi_engine")

* Type: `str`
* Description: Sets the SearchAPI engine.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `TAVILY_API_KEY`[​](#tavily%5Fapi%5Fkey "Direct link to tavily_api_key")

* Type: `str`
* Description: Sets the API key for Tavily search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `JINA_API_KEY`[​](#jina%5Fapi%5Fkey "Direct link to jina_api_key")

* Type: `str`
* Description: Sets the API key for Jina.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `JINA_API_BASE_URL`[​](#jina%5Fapi%5Fbase%5Furl "Direct link to jina_api_base_url")

* Type: `str`
* Default: `https://s.jina.ai/`
* Description: Sets the Base URL for Jina Search API. Useful for specifying custom or regional endpoints (e.g., `https://eu-s-beta.jina.ai/`).
* Persistence: This environment variable is a `PersistentConfig` variable. It can be configured in the **Admin Panel > Settings > Web Search > Jina API Base URL**.

#### `BING_SEARCH_V7_ENDPOINT`[​](#bing%5Fsearch%5Fv7%5Fendpoint "Direct link to bing_search_v7_endpoint")

* Type: `str`
* Description: Sets the endpoint for Bing Search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `BING_SEARCH_V7_SUBSCRIPTION_KEY`[​](#bing%5Fsearch%5Fv7%5Fsubscription%5Fkey "Direct link to bing_search_v7_subscription_key")

* Type: `str`
* Default: `https://api.bing.microsoft.com/v7.0/search`
* Description: Sets the subscription key for Bing Search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `BOCHA_SEARCH_API_KEY`[​](#bocha%5Fsearch%5Fapi%5Fkey "Direct link to bocha_search_api_key")

* Type: `str`
* Default: `None`
* Description: Sets the API key for Bocha Search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `EXA_API_KEY`[​](#exa%5Fapi%5Fkey "Direct link to exa_api_key")

* Type: `str`
* Default: `None`
* Description: Sets the API key for Exa search API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SERPAPI_API_KEY`[​](#serpapi%5Fapi%5Fkey "Direct link to serpapi_api_key")

* Type: `str`
* Default: `None`
* Description: Sets the API key for SerpAPI.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SERPAPI_ENGINE`[​](#serpapi%5Fengine "Direct link to serpapi_engine")

* Type: `str`
* Default: `None`
* Description: Specifies the search engine to use for SerpAPI.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `AZURE_AI_SEARCH_API_KEY`[​](#azure%5Fai%5Fsearch%5Fapi%5Fkey "Direct link to azure_ai_search_api_key")

* Type: `str`
* Default: `None`
* Description: API key (query key or admin key) for authenticating with Azure AI Search service. Required for using Azure AI Search as a web search provider.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `AZURE_AI_SEARCH_ENDPOINT`[​](#azure%5Fai%5Fsearch%5Fendpoint "Direct link to azure_ai_search_endpoint")

* Type: `str`
* Default: `None`
* Description: Azure Search service endpoint URL. Specifies which Azure Search service instance to connect to.
* Example: `https://myservice.search.windows.net`, `https://company-search.search.windows.net`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `AZURE_AI_SEARCH_INDEX_NAME`[​](#azure%5Fai%5Fsearch%5Findex%5Fname "Direct link to azure_ai_search_index_name")

* Type: `str`
* Default: `None`
* Description: Name of the search index to query within your Azure Search service. Different indexes can contain different types of searchable content.
* Example: `my-search-index`, `documents-index`, `knowledge-base`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SOUGOU_API_SID`[​](#sougou%5Fapi%5Fsid "Direct link to sougou_api_sid")

* Type: `str`
* Default: `None`
* Description: Sets the Sogou API SID.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `SOUGOU_API_SK`[​](#sougou%5Fapi%5Fsk "Direct link to sougou_api_sk")

* Type: `str`
* Default: `None`
* Description: Sets the Sogou API SK.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `OLLAMA_CLOUD_WEB_SEARCH_API_KEY`[​](#ollama%5Fcloud%5Fweb%5Fsearch%5Fapi%5Fkey "Direct link to ollama_cloud_web_search_api_key")

* Type: `str`
* Default: `None`
* Description: Sets the Ollama Cloud Web Search API Key.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `TAVILY_EXTRACT_DEPTH`[​](#tavily%5Fextract%5Fdepth "Direct link to tavily_extract_depth")

* Type: `str`
* Default: `basic`
* Description: Specifies the extract depth for Tavily search results.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `YACY_QUERY_URL`[​](#yacy%5Fquery%5Furl "Direct link to yacy_query_url")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the query URL for YaCy search engine integration. Should point to a YaCy instance's search API endpoint.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `YACY_USERNAME`[​](#yacy%5Fusername "Direct link to yacy_username")

* Type: `str`
* Default: Empty string (' ')
* Description: Specifies the username for authenticated access to YaCy search engine.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `YACY_PASSWORD`[​](#yacy%5Fpassword "Direct link to yacy_password")

* Type: `str`
* Default: Empty string (' ')
* Description: Specifies the password for authenticated access to YaCy search engine.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `EXTERNAL_WEB_SEARCH_URL`[​](#external%5Fweb%5Fsearch%5Furl "Direct link to external_web_search_url")

* Type: `str`
* Default: Empty string (' ')
* Description: Specifies the URL of an external web search service API endpoint for custom search integrations.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `EXTERNAL_WEB_SEARCH_API_KEY`[​](#external%5Fweb%5Fsearch%5Fapi%5Fkey "Direct link to external_web_search_api_key")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the API key for authenticating with the external web search service.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `EXTERNAL_WEB_LOADER_URL`[​](#external%5Fweb%5Floader%5Furl "Direct link to external_web_loader_url")

* Type: `str`
* Default: Empty string (' ')
* Description: Specifies the URL of an external web content loader service for fetching and processing web pages.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `EXTERNAL_WEB_LOADER_API_KEY`[​](#external%5Fweb%5Floader%5Fapi%5Fkey "Direct link to external_web_loader_api_key")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the API key for authenticating with the external web loader service.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `YANDEX_WEB_SEARCH_URL`[​](#yandex%5Fweb%5Fsearch%5Furl "Direct link to yandex_web_search_url")

* Type: `str`
* Default: `https://searchapi.api.cloud.yandex.net/v2/web/search`
* Description: Specifies the URL of the Yandex Web Search service API endpoint.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `YANDEX_WEB_SEARCH_API_KEY`[​](#yandex%5Fweb%5Fsearch%5Fapi%5Fkey "Direct link to yandex_web_search_api_key")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the API key for authenticating with the Yandex Web Search service.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `YANDEX_WEB_SEARCH_CONFIG`[​](#yandex%5Fweb%5Fsearch%5Fconfig "Direct link to yandex_web_search_config")

* Type: `str`
* Default: Empty string (' ')
* Description: Optional JSON configuration string for Yandex Web Search. Can be used to set parameters like `searchType` or `region` as per the Yandex API documentation.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PERPLEXITY_API_KEY`[​](#perplexity%5Fapi%5Fkey "Direct link to perplexity_api_key")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the API key for Perplexity API.
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PERPLEXITY_SEARCH_API_URL`[​](#perplexity%5Fsearch%5Fapi%5Furl "Direct link to perplexity_search_api_url")

* Type: `str`
* Default: `https://api.perplexity.ai/search`
* Description: Configures the API endpoint for Perplexity Search. Allows using custom or self-hosted Perplexity-compatible API endpoints (such as LiteLLM's `/search` endpoint) instead of the hardcoded default for the official Perplexity API. This enables flexibility in routing search requests to alternative providers or internal proxies. **Note: If using LiteLLM, append the specific provider name to the URL path.**
* Example: `http://my-litellm-server.com/search/perplexity-search`
* Persistence: This environment variable is a `PersistentConfig` variable.

#### `PERPLEXITY_MODEL`[​](#perplexity%5Fmodel "Direct link to perplexity_model")

* Type: `str`
* Default: `sonar`
* Description: Specifies the Perplexity AI model to use for search queries when using `Perplexity` as the web search engine.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

`Perplexity` is different from `perplexity_search`. If you use `perplexity_search`, this variable is not relevant to you.

#### `PERPLEXITY_SEARCH_CONTEXT_USAGE`[​](#perplexity%5Fsearch%5Fcontext%5Fusage "Direct link to perplexity_search_context_usage")

* Type: `str`
* Default: `medium`
* Description: Controls the amount of search context used by Perplexity AI. Options typically include `low`, `medium`, `high`.
* Persistence: This environment variable is a `PersistentConfig` variable.

info

`Perplexity` is different from `perplexity_search`. If you use `perplexity`, this variable is not relevant to you.

#### `YOUCOM_API_KEY`[​](#youcom%5Fapi%5Fkey "Direct link to youcom_api_key")

* Type: `str`
* Default: Empty string (' ')
* Description: Sets the API key for [You.com](https://you.com/) YDC Index API web search. Required when `WEB_SEARCH_ENGINE` is set to `youcom`. Obtain an API key from [You.com API](https://you.com/api).
* Persistence: This environment variable is a `PersistentConfig` variable.

### Web Loader Configuration[​](#web-loader-configuration "Direct link to Web Loader Configuration")

#### `WEB_LOADER_ENGINE`[