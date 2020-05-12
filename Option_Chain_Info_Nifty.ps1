<#
.SYNOPSIS
    It captures Option data from Edelweiss for Nifty.

.DESCRIPTION
    It capture Open Interest, IV, Strike Price, Stock Price, Volume, Expiry.

.NOTES
    Ankit Agarwal

.LINK
    https://github.com/ankitpro/Capture-CE-and-PE-of-Nifty
#>

#--------------------------[Initialisation]------------------------------#

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$date_IST = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'India Standard Time')
$url = "https://ewmw.edelweiss.in/api/Market/optionchainguest"
$icon = $scriptPath + "\stock.ico"
$files_folders_location = $scriptPath + "\Data\"
$date_time = $date_IST.Tostring("dd-MM-yyyy hh:mm")
#$date_time_forFile = $date_IST.Tostring("dd-MM-yyyy_hh-mm")
$date_time_forFolder = $date_IST.Tostring("dd-MM-yyyy")


if(!(test-path -Path $files_folders_location)){
    new-item -Path $files_folders_location -ItemType Directory
}

$date_folder = $files_folders_location + $date_time_forFolder
if(!(test-path -path $date_folder)){
        new-item -path $date_folder -ItemType Directory      
}

$subfolder = $date_folder + "\15min"
 if(!(test-path -path $subfolder)){
            new-item -path $subfolder -ItemType Directory 
}

$5m_filename_ce = $subfolder + "\CE_" + $date_time_forFolder + ".csv"
$5m_filename_pe = $subfolder + "\PE_" + $date_time_forFolder + ".csv"


## Calculate the coming Thursday
for($i=1; $i -le 7; $i++)
{        
    if($date_IST.AddDays($i).DayOfWeek -eq 'Thursday')
    {
        $date_IST = $date_IST.AddDays($i)
        break
    }
}
$date = $date_IST.ToString("dd MMM yyyy")



#--------------------------[Script]------------------------------#

$optionChain_nifty = Invoke-WebRequest -Uri $url `
-Method "POST" `
-Headers @{
"Pragma"="no-cache"
  "Cache-Control"="no-cache"
  "sec-ch-ua"="`"Google Chrome 81`""
  "Accept"="application/json, text/plain, */*"
  "DNT"="1"
  "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36"
  "Origin"="https://www.edelweiss.in"
  "Sec-Fetch-Site"="same-site"
  "Sec-Fetch-Mode"="cors"
  "Sec-Fetch-Dest"="empty"
   "Accept-Encoding"="gzip, deflate, br"
  "Accept-Language"="en-IN,en-GB;q=0.9,en-US;q=0.8,en;q=0.7"
} `
-ContentType "application/json;charset=UTF-8" `
-Body "{`"exp`":`"$date`",`"aTyp`":`"OPTIDX`",`"uSym`":`"NIFTY`"}"
 

$json = $optionChain_nifty.Content| ConvertFrom-Json

$ce = $json.opChn.ceQt
$pe = $json.opChn.peQt

$ce | Add-Member -Name Datetime -Value $date_time -MemberType NoteProperty 
$ce | Add-Member -Name Expiry -Value $date -MemberType NoteProperty
$pe | Add-Member -Name Datetime -Value $date_time -MemberType NoteProperty
$pe | Add-Member -Name Expiry -Value $date -MemberType NoteProperty

$ce = $ce | select Datetime, trdSym, ltp, vol, chg, chgP, opInt, opIntChg, askivfut, askivspt, bidivfut, bidivspt, ltpivfut, ltpivspt, Expiry
$pe = $pe | select Datetime, trdSym, ltp, vol, chg, chgP, opInt, opIntChg, askivfut, askivspt, bidivfut, bidivspt, ltpivfut, ltpivspt, Expiry


$ce | Export-CSV $5m_filename_ce -NoTypeInformation -Append
$pe | Export-CSV $5m_filename_pe -NoTypeInformation -Append

write-host $5m_filename_ce
write-host $5m_filename_pe


#--------------------------[Visualization]------------------------------#
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 
$objNotifyIcon.Icon = $icon
#$objNotifyIcon.BalloonTipIcon = "Warning" 
$objNotifyIcon.BalloonTipText = "Data ready for Analysis" 
$objNotifyIcon.BalloonTipTitle = "Data Captured for 15 Mins"
$objNotifyIcon.Visible = $True 
$objNotifyIcon.ShowBalloonTip(5000)
