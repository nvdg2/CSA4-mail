$ErrorActionPreference = "Stop"

$envFilePath = ".\.env" 
$pkiDomainName = Get-Content -Path $envFilePath | ForEach-Object {
    if ($_ -match "PKI_DOMAIN_NAME=") {
        $value = $_.Split("=")[1].Trim()
        $value -replace '"', ""
    }
}

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy



# Create a new WebClient instance
$webClient = New-Object System.Net.WebClient

# Create an HttpWebRequest object
$request = [System.Net.HttpWebRequest]::Create("https://ca."+$pkiDomainName+":9000/roots.pem")
$request.Timeout = 60000

## Download the file using the WebClient
$webClient.DownloadFile($request.RequestUri, "root_ca.crt")
#
Import-Certificate -FilePath ./root_ca.crt -CertStoreLocation Cert:\LocalMachine\Root