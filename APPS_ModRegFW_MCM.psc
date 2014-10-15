ScriptName APPS_ModRegFW_MCM Extends SKI_ConfigBase
APPS_FW_Core Property Core Auto
Int FileLogLevel
String[] Ordering
String[] LogLevel
String Property SUKEY_REGISTERED_MODS = "APPS.RegisteredMods" AutoReadOnly Hidden
String Property SUKEY_MENU_OPTIONS = "APPS.MCM.RegisteredMods" AutoReadOnly Hidden
String Property SUKEY_INSTALL_MODS = "APPS.InstallMods" AutoReadOnly Hidden
Int Property MOVE_TOP = 0 AutoReadOnly Hidden
Int Property MOVE_UP = 1 AutoReadOnly Hidden
Int Property MOVE_DOWN = 2 AutoReadOnly Hidden
Int Property MOVE_BOTTOM = 3 AutoReadOnly Hidden


Event OnConfigInit()
	Pages = new String[2]
	Pages[0] = "$LOGGING"
	Pages[1] = "$INSTALL_MANAGER"
	Ordering = New String[5]
	Ordering[0] = "$MOVE_TOP"
	Ordering[1] = "$MOVE_UP"
	Ordering[2] = "$MOVE_DOWN"
	Ordering[3] = "$MOVE_BOTTOM"
	Ordering[4] = "$CHANGE_NOTHING"
	LogLevel = New String[4]
	LogLevel[0] = "$EVERYTHING"
	LogLevel[1] = "$WARNINGS_AND_ERRORS"
	LogLevel[2] = "$ONLY_ERRORS"
	LogLevel[3] = "$NOTHING"
EndEvent

Event OnPageReset(String asPage)
	StorageUtil.IntListClear(None, SUKEY_MENU_OPTIONS)
	StorageUtil.StringListClear(None, SUKEY_MENU_OPTIONS)

	If(asPage == Pages[0])
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
	ElseIf(asPage == Pages[1])
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("Registered mods")
		AddEmptyOption()
		
		Int InstalledMods = StorageUtil.FormListCount(None, SUKEY_INSTALL_MODS)
		Int i = InstalledMods
		
		;SUKEY_REGISTERED_MODS: [3, 2, 1]
		While(i > 0)
			StorageUtil.IntListAdd(None, SUKEY_MENU_OPTIONS, AddMenuOption(StorageUtil.StringListGet(None, SUKEY_INSTALL_MODS, i - 1), "#" + (InstalledMods + 1 - i) As String + ": ")) ;IntSUKEY_MENU_OPTIONS: [1, 2, 3]
			StorageUtil.StringListAdd(None, SUKEY_MENU_OPTIONS, StorageUtil.StringListGet(None, SUKEY_INSTALL_MODS, i - 1)) ;StringSUKEY_MENU_OPTIONS: [1, 2, 3]
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

Event OnOptionMenuOpen(Int aiOption)
	Int i

	While(i < StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS))
		If(StorageUtil.IntListGet(None, SUKEY_MENU_OPTIONS, i) == aiOption)
			SetMenuDialogDefaultIndex(4)
			SetMenuDialogStartIndex(0)
			SetMenuDialogOptions(Ordering)
			i = StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS)
		Else
			i += 1
		EndIf
	EndWhile
EndEvent

Event OnOptionMenuAccept(Int aiOpenedMenu, Int aiSelectedOption)
	Int i
	
	While(i < StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS))
		If(aiOpenedMenu == StorageUtil.IntListGet(None, SUKEY_MENU_OPTIONS, i))
			ChangeInitOrder(StorageUtil.StringListGet(None, SUKEY_MENU_OPTIONS, i), aiSelectedOption)
			i = StorageUtil.IntListCount(None, SUKEY_MENU_OPTIONS)
		Else
			i += 1
		EndIf
	EndWhile

	ForcePageReset()
EndEvent

;/	|-----------------------------------------------------------------------------------|
	|INTERNAL FUNCTION, NOT PART OF API. DO NOT USE ON ITS OWN.							|
	|Changes the order in which the mods will be initialized.							|
	|-----------------------------------------------------------------------------------|
	|Parameter: asModName																|
	|The name of the mod that we want to change its initialization order.				|
	|-----------------------------------------------------------------------------------|
	|Parameter: aiPositionChange														|
	|The type of position change we want to achieve. This is contained in Ordering[].	|
	|-----------------------------------------------------------------------------------|
/;
Function ChangeInitOrder(String asModName, Int aiPositionChange)
	Int ModIndex = StorageUtil.StringListFind(None, SUKEY_INSTALL_MODS, asModName)
	Form InitQuest = StorageUtil.FormListGet(None, SUKEY_INSTALL_MODS, ModIndex)
	Int iSetStage = StorageUtil.IntListGet(None, SUKEY_INSTALL_MODS, ModIndex)

	ShowMessage("Index: " + ModIndex + "\nQuest: " + (InitQuest As Quest).GetName(), False)

	If(aiPositionChange == MOVE_TOP)
		If(ModIndex == (StorageUtil.StringListCount(None, SUKEY_INSTALLED_MODS) - 1))
			Return
		EndIf

		StorageUtil.FormListRemove(None, SUKEY_INSTALLED_MODS, InitQuest)
		StorageUtil.FormListAdd(None, SUKEY_INSTALLED_MODS, InitQuest)
		
		StorageUtil.StringListRemove(None, SUKEY_INSTALLED_MODS, asModName)
		StorageUtil.StringListAdd(None, SUKEY_INSTALLED_MODS, asModName)
		
		StorageUtil.IntListRemove(None, SUKEY_INSTALLED_MODS, iSetStage)
		StorageUtil.IntListAdd(None, SUKEY_INSTALLED_MODS, iSetStage)
	ElseIf(aiPositionChange == MOVE_UP)
		If(ModIndex == (StorageUtil.StringListCount(None, SUKEY_INSTALLED_MODS) - 1))
			Return
		EndIf
		
		If(ModIndex == (StorageUtil.StringListCount(None, SUKEY_INSTALLED_MODS) - 2)) ;this is equivalent to MOVE_TOP, errors otherwise
		
			StorageUtil.FormListRemove(None, SUKEY_INSTALLED_MODS, InitQuest)
			StorageUtil.FormListAdd(None, SUKEY_INSTALLED_MODS, InitQuest)
			
			StorageUtil.StringListRemove(None, SUKEY_INSTALLED_MODS, asModName)
			StorageUtil.StringListAdd(None, SUKEY_INSTALLED_MODS, asModName)

			StorageUtil.IntListRemove(None, SUKEY_INSTALLED_MODS, iSetStage)
			StorageUtil.IntListAdd(None, SUKEY_INSTALLED_MODS, iSetStage)
		Else
			StorageUtil.FormListRemove(None, SUKEY_INSTALLED_MODS, InitQuest)
			StorageUtil.FormListInsert(None, SUKEY_INSTALLED_MODS, (ModIndex + 1), InitQuest)
			
			StorageUtil.StringListRemove(None, SUKEY_INSTALLED_MODS, asModName)
			StorageUtil.StringListInsert(None, SUKEY_INSTALLED_MODS, (ModIndex + 1), asModName)
			
			StorageUtil.IntListRemove(None, SUKEY_INSTALLED_MODS, iSetStage)
			StorageUtil.IntListAdd(None, SUKEY_INSTALLED_MODS, (ModIndex +1), iSetStage)
		EndIf
	ElseIf(aiPositionChange == MOVE_DOWN)
		If(ModIndex == 0)
			Return
		EndIf
		
		StorageUtil.FormListRemove(None, SUKEY_INSTALLED_MODS, InitQuest)
		StorageUtil.FormListInsert(None, SUKEY_INSTALLED_MODS, (ModIndex - 1), InitQuest)
		
		StorageUtil.StringListRemove(None, SUKEY_INSTALLED_MODS, asModName)
		StorageUtil.StringListInsert(None, SUKEY_INSTALLED_MODS, (ModIndex - 1), asModName)
		
		StorageUtil.IntListRemove(None, SUKEY_INSTALLED_MODS, iSetStage)
		StorageUtil.IntListAdd(None, SUKEY_INSTALLED_MODS, (ModIndex -1), iSetStage)
	ElseIf(aiPositionChange == MOVE_BOTTOM)
		If(ModIndex == 0)
			Return
		EndIf
		
		StorageUtil.FormListRemove(None, SUKEY_INSTALLED_MODS, InitQuest)
		StorageUtil.FormListInsert(None, SUKEY_INSTALLED_MODS, 0, InitQuest)
		
		StorageUtil.StringListRemove(None, SUKEY_INSTALLED_MODS, asModName)
		StorageUtil.StringListInsert(None, SUKEY_INSTALLED_MODS, 0, asModName)
		
		StorageUtil.IntListRemove(None, SUKEY_INSTALLED_MODS, iSetStage)
		StorageUtil.IntListAdd(None, SUKEY_INSTALLED_MODS, 0, iSetStage)
	EndIf
EndFunction
