@ECHO OFF
rem Written by m.kochi
rem 共通変数
set ORG-FOLDER=C:\PC-DCS
set BKUP-FOLDER=C:\PC-DCS-BACKUP

rem タイトル
echo ///////////////////////////////////////////////////////////////////////
echo // PC-DCS アップデートツール Ver20111117
echo //
echo // 目的：
echo // USBメモリで持参したPC-DCSデータを[%ORG-FOLDER%]に上書きする。
echo //
echo // 使用方法：
echo // 1)USBメモリにコピー元のPC-DCSフォルダを保存する。
echo // 2)そのフォルダに[UPDATE.BAT(このファイル)]を保存する。
echo // 3)エクスプローラから[UPDATE.BAT(このファイル)]を実行する。
echo //
echo // 備考：
echo // 1)[C:\PC-DCS]フォルダと関連レジストリを[%BKUP-FOLDER%]に
echo //   年月日時分フォルダでバックアップを行います。
echo //   その際、[LOG][CSV][TRIGGER]フォルダは除外します。
echo // 2)USBメモリの[Data][BMP]フォルダを[%ORG-FOLDER%]に上書きしますが
echo //   以下のファイルは除外します。
echo //   [Activation.ini][BASIC.csv][Chart.csv][CSVINI.CSV][DateTime.csv]
echo //   [EvntMark.opt][instrument.csv][kakefuda.csv][Option.csv][Trend.csv]
echo //   [TrendTable.csv][TSaveIni.CSV][Thumbs.db]
echo ///////////////////////////////////////////////////////////////////////
echo;
echo 開始する場合は何かキーを押して下さい。
echo キャンセルする場合はCTRL+Cを押して下さい。
pause>NULL

rem 変数をローカルで使用する
setlocal


rem ///////////////////////////////////////////////////////////////////////
rem //	バックアップ
rem ///////////////////////////////////////////////////////////////////////

REM レジストリバックアップ
regedit /e %ORG-FOLDER%\PC-DCS.REG "HKEY_LOCAL_MACHINE\SOFTWARE\HITACHI KASADO"

rem バックアップ除外ファイル作成
echo \LOG\>.\BACKUPEXCLUDE.DAT
echo \CSV\>>.\BACKUPEXCLUDE.DAT
echo \TRIGGER\>>.\BACKUPEXCLUDE.DAT
echo BACKUPEXCLUDE.DAT>>.\BACKUPEXCLUDE.DAT

rem バックアップフォルダ名準備
set dt=%date%
set time2=%time: =0%
set FName=%BKUP-FOLDER%\%dt:~-10,4%%dt:~-5,2%%dt:~-2,2%-%time2:~0,2%%time2:~3,2%\

rem PC-DCSフォルダバックアップ
xcopy %ORG-FOLDER% %FName% /Y /E /D /EXCLUDE:BACKUPEXCLUDE.DAT

rem 後始末
del .\BACKUPEXCLUDE.DAT


rem ///////////////////////////////////////////////////////////////////////
rem //	上書き
rem ///////////////////////////////////////////////////////////////////////

rem 上書き除外ファイル作成
echo Activation.ini>.\UPDATEEXCLUDE.DAT
echo BASIC.csv>>.\UPDATEEXCLUDE.DAT
echo Chart.csv>>.\UPDATEEXCLUDE.DAT
echo CSVINI.CSV>>.\UPDATEEXCLUDE.DAT
echo DateTime.csv>>.\UPDATEEXCLUDE.DAT
echo EvntMark.opt>>.\UPDATEEXCLUDE.DAT
echo instrument.csv>>.\UPDATEEXCLUDE.DAT
echo kakefuda.csv>>.\UPDATEEXCLUDE.DAT
echo Option.csv>>.\UPDATEEXCLUDE.DAT
echo Trend.csv>>.\UPDATEEXCLUDE.DAT
echo TrendTable.csv>>.\UPDATEEXCLUDE.DAT
echo TSaveIni.CSV>>.\UPDATEEXCLUDE.DAT
echo Thumbs.db>>.\UPDATEEXCLUDE.DAT

rem PC-DCSデータ上書き
xcopy .\Data %ORG-FOLDER%\Data\ /Y /E /EXCLUDE:UPDATEEXCLUDE.DAT
xcopy .\BMP %ORG-FOLDER%\BMP\ /Y /E /EXCLUDE:UPDATEEXCLUDE.DAT

rem 後始末
del .\UPDATEEXCLUDE.DAT

rem ローカル変数を終了する
endlocal


echo;
echo ///////////////////////////////////////////////////////////////////////
echo // 上書きが完了しました。
echo // 何かキーを押して下さい。
echo ///////////////////////////////////////////////////////////////////////
pause>NULL
del .\NULL
