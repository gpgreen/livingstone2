@echo off
rem RCS: @(#) $Id: rmd.bat,v 1.1 2001/10/19 23:40:58 taylor Exp $

if not exist %1\. goto end

echo Removing directory %1

if "%OS%" == "Windows_NT" goto winnt

cd %1
if errorlevel 1 goto end
del *.*
cd ..
rmdir %1
if errorlevel 1 goto end
goto success

:winnt
rmdir %1 /s /q
if errorlevel 1 goto end

:success
echo deleted directory %1

:end
