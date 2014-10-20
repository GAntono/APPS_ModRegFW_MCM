ScriptName APPS_ModRegFW_MCM Extends SKI_ConfigBase
APPS_FW_Core Property Core Auto
Int FileLogLevel
String[] Ordering
String[] LogLevel
String Property SUKEY_REGISTERED_MODS = "APPS.RegisteredMods" AutoReadOnly Hidden
String Property SUKEY_MENU_OPTIONS = "APPS.MCM.RegisteredMods" AutoReadOnly Hidden
String Property SUKEY_INSTALL_MODS = "APPS.InstallMods" AutoReadOnly Hidden
String Property SUKEY_INSTALL_MODS_TOOLTIP = "APPS.InstallMods.Tooltip" AutoReadOnly Hidden
String Property SUKEY_UNINSTALL_MODS = "APPS.UninstallMods" AutoReadOnly Hidden
Int Property MOVE_TOP = 0 AutoReadOnly Hidden
Int Property MOVE_UP = 1 AutoReadOnly Hidden
Int Property MOVE_DOWN = 2 AutoReadOnly Hidden
Int Property MOVE_BOTTOM = 3 AutoReadOnly Hidden
Int Property INITIALIZE_MOD = 5 AutoReadOnly Hidden
Int Property InitControlFlags Auto Hidden
Int Property UninstallControlFlags Auto Hidden
Float Property TimeToNextInit = 1.0 Auto Hidden
Bool Property SafetyLock = False Auto Hidden



Event OnConfigInit()
	Pages = new String[3]
	Pages[0] = "$LOGGING"
	Pages[1] = "$REGISTRY"
	Pages[2] = "$INSTALL_MANAGER"
	Pages[3] = "$UNINSTALL_MANAGER"
	
	Ordering = New String[5]
	Ordering[0] = "$MOVE_TOP"
	Ordering[1] = "$MOVE_UP"
	Ordering[2] = "$CHANGE_NOTHING"
	Ordering[3] = "$MOVE_DOWN"
	Ordering[4] = "$MOVE_BOTTOM"
	Ordering[5] = "--------------"
	Ordering[6] = "$INITIALIZE_MOD"
	
	LogLevel = New String[4]
	LogLevel[0] = "$EVERYTHING"
	LogLevel[1] = "$WARNINGS_AND_ERRORS"
	LogLevel[2] = "$ONLY_ERRORS"
	LogLevel[3] = "$NOTHING"
EndEvent

Event OnPageReset(String asPage)
	StorageUtil.IntListClear(None, SUKEY_MENU_OPTIONS)
	StorageUtil.StringListClear(None, SUKEY_MENU_OPTIONS)

	If(asPage == Pages[0])	;logging
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("$LOG_OVERVIEW")
		AddToggleOptionST("EnableLogs", "$ENABLE_LOGS", Utility.GetINIBool("bEnableLogging:Papyrus"))
		AddMenuOptionST("LogLevelFile", "$LOG_LEVEL", LogLevel[FileLogLevel])
		AddHeaderOption("$DISPLAY_MESSAGES")
		AddToggleOptionST("DisplayInfoMessage", "$DISPLAY_INFO_MSG", Core.DisplayInfo)
		AddToggleOptionST("DisplayWarningMessage", "$DISPLAY_WARNING_MSG", Core.DisplayWarning)
		AddToggleOptionST("DisplayErrorMessage", "$DISPLAY_ERROR_MSG", Core.DisplayError)
		AddHeaderOption("$ERROR_REDIRECT")
		AddMenuOptionST("LogRedirectMenu", "$LOG_REDIRECT_MENU", "Nothing")
	ElseIf (asPage == Pages[1])	;registry
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("$REGISTERED_MODS")
		AddEmptyOption()
		
		Int RegisteredMods = StorageUtil.StringListCount(None, SUKEY_REGISTERED_MODS)
		Int i = RegisteredMods
		
		While (i > 0)
			AddTextOption(StorageUtil.StringListGet(None, SUKEY_REGISTERED_MODS, i - 1), "")
			i -= 1
		EndWhile		
	ElseIf (asPage == Pages[2])	;install manager
		If (SafetyLock || StorageUtil.StringListCount(None, SUKEY_INSTALL_MODS) == 0) 
			InitControlFlags = OPTION_FLAG_DISABLED
		Else
			InitControlFlags = OPTION_FLAG_NONE
		EndIf
			
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddSliderOptionST("WaitingTimeBetweenInits", "$WAITING_TIME_BETWEEN_INITS", 1.0, "{1} seconds")
		AddTextOptionST("StartInitialization", "$START_INITIALIZATION_SEQUENCE", "$GO", InitControlFlags)
		AddEmptyOption()
		AddHeaderOption("$INITIALIZATION_ORDER")
		AddEmptyOption()
		
		Int InstalledMods = StorageUtil.FormListCount(None, SUKEY_INSTALL_MODS)
		Int i = InstalledMods
		
		While (i > 0)
			StorageUtil.IntListAdd(None, SUKEY_MENU_OPTIONS, AddMenuOption(StorageUtil.StringListGet(None, SUKEY_INSTALL_MODS, i - 1), "#" + (InstalledMods + 1 - i) As String + ": ", InitControlFlags))
			StorageUtil.StringListAdd(None, SUKEY_MENU_OPTIONS, StorageUtil.StringListGet(None, SUKEY_INSTALL_MODS, i - 1))
			i -= 1
		EndWhile
	ElseIf (asPage == Pages[3])	;uninstall manager
		If (SafetyLock || StorageUtil.StringListCount(None, SUKEY_UNINSTALL_MODS) == 0)
			UninstallControlFlags = OPTION_FLAG_DISABLED
		Else
			UninstallControlFlags = OPTION_FLAG_NONE
		EndIf
	
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddTextOptionST("UninstallAll", "$UNINSTALL_ALL", "$GO", UninstallControlFlags)
		AddEmptyOption()
		AddHeaderOption("$MODS_WITH_UNINSTALL_FEATURE")
		AddEmptyOption()
		
		Int UninstallMods = StorageUtil.FormListCount(None, SUKEY_UNINSTALL_MODS)
		Int i = UninstallMods
		
		While (i > 0)
			StorageUtil.IntListAdd(None, SUKEY_MENU_OPTIONS, AddToggleOption(StorageUtil.StringListGet(None, SUKEY_UNINSTALL_MODS, i - 1), true, UninstallControlFlags))
			StorageUtil.StringListAdd(None, SUKEY_MENU_OPTIONS, StorageUtil.StringListGet(None, SUKEY_UNINSTALL_MODS, i - 1))
			i -= 1
		EndWhile		
	EndIf
EndEvent

State EnableLogs
	Event OnSelectST()
		Utility.SetINIBool("bEnableLogging:Papyrus", !Utility.GetINIBool("bEnableLogging:Papyrus"))
		SetToggleOptionValueST(Utility.GetINIBool("bEnableLogging:Papyrus"))
	EndEvent
	
	Event OnHighlightST()
		SetInfoText("$EXPLAIN_ENABLE_LOGS")
	EndEvent
EndState

State DisplayInfoMessage
	Event OnSelectST()
		Core.DisplayInfo = !Core.DisplayInfo
		SetToggleOptionValueST(Core.DisplayInfo)
	EndEvent
EndState

State DisplayWarningMessage
	Event OnSelectST()
		Core.DisplayInfo = !Core.DisplayWarning
		SetToggleOptionValueST(Core.DisplayWarning)
	EndEvent
EndState

State DisplayErrorMessage
	Event OnSelectST()
		Core.DisplayInfo = !Core.DisplayError
		SetToggleOptionValueST(Core.DisplayError)
	EndEvent
EndState

State WaitingTimeBetweenInits
	Event OnSliderOpenST()
		SetSliderDialogStartValue(TimeToNextInit)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 5.0)
		SetSliderDialogInterval(0.1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		If (a_value < 0.5)	;waiting times < 0.5 seconds are prone to errors (Heromaster)
			TimeToNextInit = 0.0
		Else
			TimeToNextInit = a_value
		EndIf
		
		SetSliderOptionValueST(TimeToNextInit, "{1} seconds")
	EndEvent

	Event OnHighlightST()
		SetInfoText("$EXPLAIN_WAITING_TIME_BETWEEN_INITS")
	EndEvent
EndState

State StartInitialization
	Event OnHighlightST()
		SetInfoText("$EXPLAIN_START_INITIALIZATION")
	EndEvent
	
	Event OnSelectST()
		If (ShowMessage("$START_INITIALIZATION_CONFIRMATION") == true)
			SafetyLock = true
			SetTextOptionValueST("$INITIALIZING")
			ForcePageReset()	;this ensures install order is displayed again with OPTION_FLAG_DISABLED
			
			While (StorageUtil.StringListCount(None, SUKEY_INSTALL_MODS) > 0)
				String ModName = StorageUtil.StringListGet(None, SUKEY_INSTALL_MODS, 0)
				InitializeMod(ModName)
				Utility.WaitMenuMode(TimeToNextInit)
			EndWhile
			
			ShowMessage("$INITIALIZATION_SEQUENCE_COMPLETE")
			
			SafetyLock = false
			SetTextOptionValueST("$GO")
			ForcePageReset()
		EndIf
	EndEvent
EndState

State UninstallAll
	Event OnHighlightST()
		SetInfoText("$EXPLAIN_UNINSTALL_ALL")
	EndEvent
	
	Event OnSelectST()
		If (ShowMessage("$UNINSTALL_ALL_CONFIRMATION") == true)
			SafetyLock = true
			SetTextOptionValueST("$UNINSTALLING")
			ForcePageReset()	;this ensures uninstall list is displayed again with OPTION_FLAG_DISABLED
			
			While (StorageUtil.StringListCount(None, SUKEY_UNINSTALL_MODS) > 0)
				String ModName = StorageUtil.StringListGet(None, SUKEY_UNINSTALL_MODS, 0)
				UninstallMod(ModName)
			EndWhile
			
			ShowMessage("$UNINSTALL_SEQUENCE_COMPLETE")
			
			SafetyLock = false
			SetTextOptionValueST("$GO")
			ForcePageReset()
		EndIf
	EndEvent
EndState			

Event OnOptionHighlight(Int aiOption)
		Int i
		
		While (i < StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS))
			If (aiOption == StorageUtil.IntListGet(None, SUKEY_MENU_OPTIONS, i))
				If (CurrentPage == Pages[2])
					SetInfoText(StorageUtil.StringListGet(None, SUKEY_INSTALL_MODS_TOOLTIP, i))
					i = StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS)
				ElseIf (CurrentPage == Pages[3])
					SetInfoText("$EXPLAIN_UNINSTALL")
					i = StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS)
				EndIf
			Else
				i += 1
			EndIf
		EndWhile
EndEvent
			
Event OnOptionMenuOpen(Int aiOption)
	Int i

	While(i < StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS))
		If(aiOption == StorageUtil.IntListGet(None, SUKEY_MENU_OPTIONS, i))
			SetMenuDialogDefaultIndex(2)
			SetMenuDialogStartIndex(2)
			SetMenuDialogOptions(Ordering)
			i = StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS)
		Else
			i += 1
		EndIf
	EndWhile
EndEvent

Event OnOptionMenuAccept(Int aiOpenedMenu, Int aiSelectedOption)
	Int i
	
	While (i < StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS))
		If(aiOpenedMenu == StorageUtil.IntListGet(None, SUKEY_MENU_OPTIONS, i))
			If (aiSelectedOption == MOVE_TOP || aiSelectedOption == MOVE_UP || aiSelectedOption == MOVE_DOWN || aiSelectedOption == MOVE_BOTTOM)
				ChangeInitOrder(StorageUtil.StringListGet(None, SUKEY_MENU_OPTIONS, i), aiSelectedOption)
				i = StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS)
			ElseIf (aiSelectedOption == INITIALIZE_MOD)
				If (ShowMessage("$INITIALIZE_MOD_CONFIRMATION") == true)
					InitializeMod(StorageUtil.StringListGet(None, SUKEY_MENU_OPTIONS, i))
					i = StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS)
				EndIf
			EndIf
		Else
			i += 1
		EndIf
	EndWhile

	ForcePageReset()
EndEvent

Event OnOptionSelect(Int aiOption)
	Int i
	
	While (i < StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS))
		If (aiOption == StorageUtil.IntListGet(None, SUKEY_MENU_OPTIONS, i))
			If (ShowMessage("$UNINSTALL_MOD_CONFIRMATION") == true)
				UninstallMod(StorageUtil.StringListGet(None, SUKEY_MENU_OPTIONS, i))
				i = StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS)
			EndIf
		Else	
			i += 1
		EndIf
	EndWhile
EndEvent

Function ChangeInitOrder(String asModName, Int aiPositionChange)
	Int ModIndex = StorageUtil.StringListFind(None, SUKEY_INSTALL_MODS, asModName)
	Form InitQuest = StorageUtil.FormListGet(None, SUKEY_INSTALL_MODS, ModIndex)
	Int iSetStage = StorageUtil.IntListGet(None, SUKEY_INSTALL_MODS, ModIndex)

	;ShowMessage("Index: " + ModIndex + "\nQuest: " + (InitQuest As Quest).GetName(), False)

	If(aiPositionChange == MOVE_TOP)
		If(ModIndex == (StorageUtil.StringListCount(None, SUKEY_INSTALL_MODS) - 1))
			Return
		EndIf

		StorageUtil.FormListRemove(None, SUKEY_INSTALL_MODS, InitQuest)
		StorageUtil.FormListAdd(None, SUKEY_INSTALL_MODS, InitQuest)
		
		StorageUtil.StringListRemove(None, SUKEY_INSTALL_MODS, asModName)
		StorageUtil.StringListAdd(None, SUKEY_INSTALL_MODS, asModName)
		
		StorageUtil.IntListRemove(None, SUKEY_INSTALL_MODS, iSetStage)
		StorageUtil.IntListAdd(None, SUKEY_INSTALL_MODS, iSetStage)
	ElseIf(aiPositionChange == MOVE_UP)
		If(ModIndex == (StorageUtil.StringListCount(None, SUKEY_INSTALL_MODS) - 1))
			Return
		EndIf
		
		If(ModIndex == (StorageUtil.StringListCount(None, SUKEY_INSTALL_MODS) - 2)) ;this is equivalent to MOVE_TOP, errors otherwise
		
			StorageUtil.FormListRemove(None, SUKEY_INSTALL_MODS, InitQuest)
			StorageUtil.FormListAdd(None, SUKEY_INSTALL_MODS, InitQuest)
			
			StorageUtil.StringListRemove(None, SUKEY_INSTALL_MODS, asModName)
			StorageUtil.StringListAdd(None, SUKEY_INSTALL_MODS, asModName)

			StorageUtil.IntListRemove(None, SUKEY_INSTALL_MODS, iSetStage)
			StorageUtil.IntListAdd(None, SUKEY_INSTALL_MODS, iSetStage)
		Else
			StorageUtil.FormListRemove(None, SUKEY_INSTALL_MODS, InitQuest)
			StorageUtil.FormListInsert(None, SUKEY_INSTALL_MODS, (ModIndex + 1), InitQuest)
			
			StorageUtil.StringListRemove(None, SUKEY_INSTALL_MODS, asModName)
			StorageUtil.StringListInsert(None, SUKEY_INSTALL_MODS, (ModIndex + 1), asModName)
			
			StorageUtil.IntListRemove(None, SUKEY_INSTALL_MODS, iSetStage)
			StorageUtil.IntListAdd(None, SUKEY_INSTALL_MODS, (ModIndex +1), iSetStage)
		EndIf
	ElseIf(aiPositionChange == MOVE_DOWN)
		If(ModIndex == 0)
			Return
		EndIf
		
		StorageUtil.FormListRemove(None, SUKEY_INSTALL_MODS, InitQuest)
		StorageUtil.FormListInsert(None, SUKEY_INSTALL_MODS, (ModIndex - 1), InitQuest)
		
		StorageUtil.StringListRemove(None, SUKEY_INSTALL_MODS, asModName)
		StorageUtil.StringListInsert(None, SUKEY_INSTALL_MODS, (ModIndex - 1), asModName)
		
		StorageUtil.IntListRemove(None, SUKEY_INSTALL_MODS, iSetStage)
		StorageUtil.IntListAdd(None, SUKEY_INSTALL_MODS, (ModIndex - 1), iSetStage)
	ElseIf(aiPositionChange == MOVE_BOTTOM)
		If(ModIndex == 0)
			Return
		EndIf
		
		StorageUtil.FormListRemove(None, SUKEY_INSTALL_MODS, InitQuest)
		StorageUtil.FormListInsert(None, SUKEY_INSTALL_MODS, 0, InitQuest)
		
		StorageUtil.StringListRemove(None, SUKEY_INSTALL_MODS, asModName)
		StorageUtil.StringListInsert(None, SUKEY_INSTALL_MODS, 0, asModName)
		
		StorageUtil.IntListRemove(None, SUKEY_INSTALL_MODS, iSetStage)
		StorageUtil.IntListAdd(None, SUKEY_INSTALL_MODS, 0, iSetStage)
	EndIf
EndFunction

Function InitializeMod(String asModName)
	Int ModIndex = StorageUtil.StringListFind(None, SUKEY_INSTALL_MODS, asModName)
	Quest InitQuest = StorageUtil.FormListGet(None, SUKEY_INSTALL_MODS, ModIndex) as Quest
	Int iSetStage = StorageUtil.IntListGet(None, SUKEY_INSTALL_MODS, ModIndex)
	
	If (InitQuest.SetStage(iSetStage) == false)
		ShowMessage(asModName + "$MOD_FAILED_TO_INITIALIZE", false, "OK")
		Return
	Else
		StorageUtil.StringListRemove(None, SUKEY_INSTALL_MODS, asModName)
		StorageUtil.FormListRemove(None, SUKEY_INSTALL_MODS, InitQuest)
		StorageUtil.IntListRemove(None, SUKEY_INSTALL_MODS, iSetStage)
	EndIf
EndFunction

Function UninstallMod(String asModName)
	Int ModIndex = StorageUtil.StringListFind(None, SUKEY_UNINSTALL_MODS, asModName)
	Quest UninstallQuest = StorageUtil.FormListGet(None, SUKEY_UNINSTALL_MODS, ModIndex) as Quest
	Int iSetStage = StorageUtil.IntListGet(None, SUKEY_UNINSTALL_MODS, ModIndex)
	
	If (UninstallQuest.SetStage(iSetStage) == false)
		ShowMessage(asModName + "$MOD_FAILED_TO_UNINSTALL", false, "OK")
		Return
	Else
		StorageUtil.StringListRemove(None, SUKEY_UNINSTALL_MODS, asModName)
		StorageUtil.FormListRemove(None, SUKEY_UNINSTALL_MODS, UninstallQuest)
		StorageUtil.IntListRemove(None, SUKEY_UNINSTALL_MODS, iSetStage)
	EndIf
EndFunction

;/
DONE:
Tab: Registry
	- Show a list of all registered mods
Tab: Install Manager
	- Move mods up and down the list to change install order
	- Menu point "Start Initialization" (Maybe with a ShowMessage where the user will be informed)
	- Disable above menu point if Initialize Manager is installing or if list is empty
	- Tooltips of every mod (will contain for some mods messages, in which order they need to be placed)
Tab: Uninstall Manager
	- Shows a list of all registered mods which have an uninstall quest
	
	- ShowMessage(If mod will be uninstalled, it will uninstall completely)
	- Menu point "Uninstall all mods"
	- Disable above menu point if Uninstall Manager is uninstalling or if list is empty
	
TODO:
All tabs:
	- disable everything if any mod is initializing or uninstalling
	- probably  best done through states
Tab: Exception Manager
	- Enable/disable global file logging
	- ShowMessage if file logging is enabled, that it will now be disabled for this game session
	- Enable/disable framework logging
	- LogLevel to write to files (Info, Warning, Error) --> a) Three toggle buttons b) Menu(Everything, Only Warnings and Errors, Only Errors) (for each mod)
	- LogLevel to display MessageBoxes (Info, Warning, Error) --> a) Three toggle buttons b) Menu(Everything, Only Warnings and Errors, Only Errors) (for each mod)
	- Redirect log files to: Papyrus log, APPS - Framework user log, each mod with own user log
	- Mod settings could look like the Profile Menu form SexLab
/;