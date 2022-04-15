# escape=`

# https://github.com/microsoft/dotnet-framework-docker/blob/main/samples/aspnetapp/Dockerfile

####################################################################################################
# Start from Dot Net SDK / runtime (SIF requires msbuild)
####################################################################################################

# https://github.com/microsoft/dotnet-framework-docker/blob/main/src/sdk/4.8/windowsservercore-ltsc2019/Dockerfile
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019 AS build

WORKDIR /

ENV sql_sa_password="_" `
    attach_dbs="[]"

####################################################################################################
# Install IIS
####################################################################################################

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# https://github.com/microsoft/dotnet-framework-docker/blob/main/src/aspnet/4.8/windowsservercore-ltsc2019/Dockerfile

RUN Add-WindowsFeature Web-Server; `
    Add-WindowsFeature NET-Framework-45-ASPNET; `
    Add-WindowsFeature Web-Asp-Net45; `
    Remove-Item -Recurse C:\inetpub\wwwroot\*; `
    Invoke-WebRequest -Uri https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.10/ServiceMonitor.exe -OutFile C:\ServiceMonitor.exe; 

####################################################################################################
# Install SQL Server Developer 2017
####################################################################################################

# https://github.com/microsoft/mssql-docker/tree/master/windows/mssql-server-windows-developer

RUN Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=840944" -OutFile SQL.box ; `
    Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=840945" -OutFile SQL.exe ; `
    Start-Process -Wait -FilePath .\SQL.exe -ArgumentList /qs, /x:setup ; `
    .\setup\setup.exe /q /ACTION=Install /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=0 /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE='SQL' /SAPWD='fK6bf9hae1KIHoRFNYS' ; `
    Remove-Item -Recurse -Force SQL.exe, SQL.box, setup

RUN stop-service MSSQLSERVER ; `
    set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value '' ; `
    set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433 ; `
    set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\' -name LoginMode -value 2 ; `
    start-service MSSQLSERVER ;

####################################################################################################
# Install Sitecore Install Framework
####################################################################################################

RUN Install-PackageProvider Nuget -Scope CurrentUser -Force ; `
    Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2 -InstallationPolicy Trusted ; `
    Install-Module SitecoreInstallFramework -Force ;

####################################################################################################
# Get XM1 Resource Files
####################################################################################################

RUN Invoke-WebRequest -Uri "https://sitecoredev.azureedge.net/~/media/C6379FA451CC48318D06D01E1A820256.ashx?date=20211101T110157" -OutFile ResourceFiles.zip ; `
    Expand-Archive -Path "ResourceFiles.zip" -DestinationPath "C:\ResourceFiles" ; `
    Expand-Archive -Path "'C:\ResourceFiles\XM1 Configuration files 10.2.0 rev. 006766.zip'" -DestinationPath "C:\ResourceFiles" ; `
    Remove-Item -Recurse -Force ResourceFiles.zip

# Copy ResourceFiles overrides
COPY .\ResourceFiles\ C:\ResourceFiles\

WORKDIR C:\ResourceFiles

####################################################################################################
# Install Prerequisites
####################################################################################################

RUN Install-SitecoreConfiguration -Path .\Prerequisites.json

####################################################################################################
# Install SOLR
####################################################################################################

RUN Install-SitecoreConfiguration -Path .\Solr-SingleDeveloper.json
 
####################################################################################################
# Install Sitecore
####################################################################################################

RUN .\XM1-SingleDeveloper.ps1

WORKDIR /

COPY start.ps1 /

ENTRYPOINT ["powershell", "./start.ps1"]