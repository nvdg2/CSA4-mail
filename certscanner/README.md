# SSL Certificate Scanner

The SSL Certificate Scanner is a Python script that allows you to scan SSL/TLS certificates of remote hosts and store the certificate information, including the certificate itself in Base64 format, into a CSV file. This script is useful for auditing and monitoring SSL certificates on various hosts.

## Requirements

- Python 3.x
- `ssl`, `base64`, `csv`, `socket` (Python standard libraries)

## Usage

1. Make sure you have Python 3.x installed on your system.

2. Create a CSV file (`hosts.csv`) with the list of hosts and ports you want to scan. The CSV file should have two columns: `host` and `port`.

Example `hosts.csv`:
```
host,port
example.com,443
another-example.com,8443
```
3. Execute the script by running the following command:
```shell
python3 ssl_certificate_scanner.py
```

Replace `ssl_certificate_scanner.py` with the actual name of your script.

4. The script will scan the SSL/TLS certificates for the hosts listed in `hosts.csv` and store the certificate information in a new CSV file named `certificates.csv`. The certificate itself will be stored in Base64 format.

## Output

The output CSV file (`certificates.csv`) will contain the following columns:

- `Subject DN`: The Distinguished Name (DN) of the certificate's subject.
- `Issuer DN`: The Distinguished Name (DN) of the certificate's issuer.
- `Serial Number`: The serial number of the certificate.
- `Not Before`: The date and time when the certificate becomes valid.
- `Not After`: The date and time when the certificate expires.
- `Certificate PEM in BASE64`: The certificate itself in Base64 format.

