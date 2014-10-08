''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'EXTファイルの配布スクリプト	2011/05/16
'(c)2011 Hitachi Plant Mechanics Co., Ltd.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

dim strComputer
dim objWMIService
dim colItems
dim objItem
dim objAddress
dim strIPAddress
Dim strIP(3)	'左記で0～3の4つ確保
dim strIPTmp
dim strMyIP
dim strSourceFolder
dim strDestinationFolder
Dim WshShell
Dim FS


'IPアドレス
strIP(0) = "192.1.0.201"
strIP(1) = "192.1.0.202"
strIP(2) = "192.1.0.203"
strIP(3) = "192.1.0.204"

const PCDCS_DATA_FOLDER = "\PC-DCS\Log"


'自IPアドレスをを求める=========================================

strComputer = "."

Set objWMIService = GetObject _
    ("winmgmts:\\" & strComputer & "\root\cimv2")
Set colItems = objWMIService.ExecQuery _
    ("Select * From Win32_NetworkAdapterConfiguration " & _
        "Where IPEnabled = True")
For Each objItem in colItems
'	Wscript.Echo "Caption: " & objItem.Caption
	For Each objAddress in objItem.IPAddress
'		Wscript.Echo "IP Address: " & objAddress

		For Each strIPTmp in strIP
			'比較
			if strIPTmp = objAddress then
				strMyIP = strIPTmp
				Exit For
			end if
		Next
		if strMyIP <> "" then
			exit for
		end if
	Next
	if strMyIP <> "" then
		exit for
	end if
Next

'Wscript.Echo "MYIP: " & strMyIP

'最新EXTファイルのみ上書きコピーを行う。======================================================

For Each strIPTmp in strIP
	Do
		'自IPとの比較
		if strIPTmp = strMyIP then
'			Wscript.Echo "自IPなのでスキップ"
			exit do
		end if 
		'PINGで相手を確認する
		if not(PingCheck(strIPTmp)) then
'			Wscript.Echo "PING 不可なのでスキップ"
			exit do
		end if
		Wscript.Echo "コピーを行う"
		
		'フォルダを作成する
		strSourceFolder = "\\" & strMyIP & PCDCS_DATA_FOLDER & "\*.EXT"
		strDestinationFolder = "\\" & strIPTmp & PCDCS_DATA_FOLDER
		
		'ファイルシステムオブジェクトを生成
		Set FS = CreateObject("Scripting.FileSystemObject")
		'指定フォルダが存在するかを確認
		if not(FS.FolderExists( strDestinationFolder )) then
			Wscript.Echo "コピー先フォルダが存在しないのでスキップ: " & strDestinationFolder
			exit do
		end if

		Set WshShell = CreateObject("WScript.Shell")
		'スペースを含むフォルダを使用する場合はダブルクォート(""")で囲むこと。
		'Wscript.Echo "xcopy """ & strSourceFolder & """ """ & strDestinationFolder & """ /D /Y"
		WshShell.Run "xcopy """ & strSourceFolder & """ """ & strDestinationFolder & """ /D /Y", 0, true

	Loop Until 1
next

Set FS = Nothing
Set WshShell = Nothing
Set colItems = Nothing
Set objWMIService = Nothing

'PING確認
Function PingCheck(ByVal TargetAddress)

	dim objWMISrv
	dim PingSet
	dim Ping
	dim result
	
    Set objWMISrv = GetObject("winmgmts:\\.") 
    Set PingSet = objWMISrv.ExecQuery("Select * From Win32_PingStatus Where Address = '" & TargetAddress & "'") 
    For Each Ping In PingSet 
        Select Case Ping.StatusCode 
            Case 0 
                result = True
            'Case 11010 
                'MsgBox "Request Timed Out"
            Case Else 
                result = False
        End Select 
    Next
    
    Set PingSet = Nothing
    Set objWMISrv = Nothing
    
    PingCheck = result
End Function

