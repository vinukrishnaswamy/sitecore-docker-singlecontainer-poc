
# start the service
Write-Verbose "Starting SQL Server"
start-service MSSQLSERVER

if($env:sql_sa_password -eq "_") {
    Write-Verbose "WARN: Using default SA password"
}

if($env:sql_sa_password -ne "_")
{
    Write-Verbose "Changing SA login credentials"
    $sqlcmd = "ALTER LOGIN sa with password=" +"'" + $env:sql_sa_password + "'" + ";ALTER LOGIN sa ENABLE;"
    & sqlcmd -Q $sqlcmd
}

Write-Verbose "Started SQL Server."

C:\ServiceMonitor.exe w3svc