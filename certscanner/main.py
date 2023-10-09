#!/usr/bin/env python3
import base64
import csv
import socket
import ssl


def scan_certificate(hostname, port=443):
    try:
        ctx = ssl.create_default_context()
        with ctx.wrap_socket(socket.socket(), server_hostname=hostname) as s:
            s.connect((hostname, 443))
            cert = s.getpeercert()

        subject_dn = dict(x[0] for x in cert['subject'])
        issuer_dn = dict(x[0] for x in cert['issuer'])

        subject_cn = dict(x[0] for x in cert['subject']).get('commonName', '')
        issuer_cn = dict(x[0] for x in cert['issuer']).get('commonName', '')

        serial_number = cert['serialNumber']
        not_before = cert['notBefore']
        not_after = cert['notAfter']

        certificate_pem = ssl.get_server_certificate((hostname, port))
        certificate_pem_base64 = base64.b64encode(certificate_pem.encode()).decode('utf-8')  

        return (subject_dn, issuer_dn, serial_number, not_before, not_after, certificate_pem_base64)

    except Exception as e:
       print(f"Error: {e}")
       return None


def main(hosts_file):
    with open('certificates.csv', 'w', newline='') as csvfile:
        fieldnames = ['Subject DN', 'Issuer DN', 'Serial Number', 'Not Before', 'Not After', 'Certificate PEM in BASE64']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        with open(hosts_file, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                result = scan_certificate(row["host"], row["port"])
                if result:
                    subject_dn, issuer_dn, serial_number, not_before, not_after, certificate_pem_base64 = result
                    writer.writerow({
                        'Subject DN': subject_dn,
                        'Issuer DN': issuer_dn,
                        'Serial Number': serial_number,
                        'Not Before': not_before,
                        'Not After': not_after,
                        'Certificate PEM in BASE64': certificate_pem_base64
                    })

if __name__ == '__main__':
    hosts_file = 'hosts.csv'
    main(hosts_file)
