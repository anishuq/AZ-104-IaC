# Define Resource Group Name
$ResourceGroupName = "AZ104PublicDNSDemo-RG"

# Define Location
$Location = "canadacentral"


#Create Connecttion to Azure Account
Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId


#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location


New-AzDnsZone -Name "dummy-contoso.com" -ResourceGroupName $ResourceGroupName

$PublicDNSZone = Get-AzDnsZone -ResourceGroupName $ResourceGroupName -Name "dummy-contoso.com"

Write-Host "Public DNS Zone created successfully. Name Servers for the zone are: $($PublicDNSZone.NameServers)"


#Adding A record to the DNS Zone
$ARecord = New-AzDnsRecordSet -Name "www" -RecordType A -ZoneName "dummy-contoso.com" -ResourceGroupName $ResourceGroupName -Ttl 3600 -DnsRecords (New-AzDnsRecordConfig -IPv4Address "20.51.230.10")
                     


#Adding CNAME record to the DNS Zone
$CNAMERecord = New-AzDnsRecordSet -Name "blog" -RecordType  CNAME -ZoneName "dummy-contoso.com" -ResourceGroupName $ResourceGroupName -Ttl 3600 -DnsRecords (New-AzDnsRecordConfig -Cname "www.dummy-contoso.com")   

#Adding TXT record to the DNS Zone
$TXTRecord = New-AzDnsRecordSet -Name "txt" -RecordType TXT -ZoneName "dummy-contoso.com" -ResourceGroupName $ResourceGroupName -Ttl 3600 -DnsRecords (New-AzDnsRecordConfig -value "ms-domain-verification=abc123")

#Adding MX record to the DNS Zone
$MXRecord = New-AzDnsRecordSet -Name "mail" -RecordType MX -ZoneName "dummy-contoso.com" -ResourceGroupName $ResourceGroupName -Ttl 3600 -DnsRecords (New-AzDnsRecordConfig -Preference 10 -Exchange "mail.dummy-contoso.com")