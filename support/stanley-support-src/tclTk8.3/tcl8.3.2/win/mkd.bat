@echo off
rem RCS: @(#) $Id: mkd.bat,v 1.2 2001/09/11 00:10:13 taylor Exp $

if exist %1\. goto end

if "%OS%" == "Windows_NT" goto winnt
md %1
if errorlevel 1 goto end

goto success

:winnt
md %1
if errorlevel 1 goto end

:success
echo created directory %1

:end

echo mkd.bat end