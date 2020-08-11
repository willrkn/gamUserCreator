add-type -AssemblyName System.Web

$fName = Read-Host "First name: "
$lName = Read-Host "Last name: "
$fullName = $fName + " " + $lName
Write-Host "Options: [g]option1, [j]option2, [l]option3, [p]option4"
$org = Read-Host "Organisation: "

If ($org -eq "g"){
    $org = "/option1/"
}
If ($org -eq "j"){
    $org = "/option2/"
}
If ($org -eq "l"){
    $org = "/option3/"
}
If ($org -eq "p"){
    $org = "/option4/"
}

$dep = Read-Host "Department: "
$title = Read-Host "Job Title: "
$mob = Read-Host "Phone Number (Blank if none): "
$lifeSize = Read-Host "Lifesize ID (Blank if none): "

$password = [System.Web.Security.Membership]::GeneratePassword(10, 5)

$emailAddress = $fName + "." + $lName + "@domain.co.uk"
$emailAddress = $emailAddress.ToLower()

gam create user $emailAddress firstname $fName lastname $lName password $password changepassword on org $org

[string]$signature = Get-Content "C:\Users\username\Documents\Scripts\signature.html"
$signature = $signature -replace "fullName", $fullName
$signature = $signature -replace "jobTitle", $title
$signature = $signature -replace "emailAddress", $emailAddress


If (!$mob){
    Write-Host "No number entered"
    $signature = $signature -replace '<span style="font-size:10pt">Tel: telNumber</span>', ''
} else {
    gam update user $emailAddress phone type work value $mob primary
    $signature = $signature -replace "telNumber", $mob
}

If (!$lifeSize){
    Write-Host "No Lifesize ID entered"
    $signature = $signature -replace '<div><div dir="ltr">Call me on Lifesize: <a href="https://call.lifesizecloud.com/lifesizeID" target="_blank">https://call.lifesizecloud.com/lifeSizeID</a><br><span style="font-size:10pt"></span></div></div>', ''
    Write-Host "Lifesize Omitted from Signature"
} else{
    $signature = $signature -replace "lifeSizeID", $lifeSize
}

$signature = $signature -replace "Â", ""

gam update group staff@domain.co.uk add $emailAddress
gam user support@domain.co.uk add drivefileacl 0AF7xrLlRB4NvUk9PVA user $emailAddress role writer
gam user support@domain.co.uk add drivefileacl 0APcuVhn6B72FUk9PVA user $emailAddress role commenter
gam user support@domain.co.uk add drivefileacl 0ANNyf0Dyf20kUk9PVA user $emailAddress role writer

gam user $emailAddress signature $signature

Write-Host Email: $emailAddress
Write-Host Password: $password

Set-Clipboard -Value $password
Write-Host "Passord has been copied to clipboard."

$exit = Read-Host "[e]xit, [s]end user email login info or [d]elete user"

If ($exit -eq "d"){
    gam delete user $emailAddress
    Write-Host 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown');
}