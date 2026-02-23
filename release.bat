@echo off
echo =============================
echo   TIC TAC TOE RELEASE TOOL
echo =============================
echo.

for /f "tokens=2 delims= " %%a in ('findstr "version:" pubspec.yaml') do set version=%%a

echo Detected version: %version%
echo.

echo Building APK...
call flutter build apk --release

echo.
echo Renaming APK...
rename build\app\outputs\flutter-apk\app-release.apk tictactoe-v%version%.apk

echo.
echo Creating Git tag...
git tag v%version%
git push origin v%version%


echo.
echo Uploading release...
gh release create v%version% tictactoe-v%version%.apk --title "v%version%" --notes "Release v%version%"

echo.
echo =============================
echo   RELEASE COMPLETE 🚀
echo =============================
pause