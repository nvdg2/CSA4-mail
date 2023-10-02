#!/usr/bin/env python3

import csv
import socket
import ssl


def scan_certificate(hostname, port=443):
    try:
        ctx = ssl.create_default_context()
        with ctx.wrap_socket(socket.socket(), server_hostname=hostname) as s:
            s.connect((hostname, 443))
            cert = s.getpeercert()

        subject_cn = dict(x[0] for x in cert['subject']).get('commonName', '')
        issuer_cn = dict(x[0] for x in cert['issuer']).get('commonName', '')
        serial_number = cert['serialNumber']
        not_before = cert['notBefore']
        not_after = cert['notAfter']

        certificate_pem = ssl.get_server_certificate((hostname, port))

        return (subject_cn, issuer_cn, serial_number, not_before, not_after, certificate_pem)

    except Exception as e:
       print(f"Error: {e}")
       return None

def main(hosts_file):
    with open('certificates.csv', 'w', newline='') as csvfile:
        fieldnames = ['Subject CN', 'Issuer CN', 'Serial Number', 'Not Before', 'Not After', 'Certificate PEM']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        with open(hosts_file, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                result = scan_certificate(row["host"], row["port"])
                if result:
                    subject_cn, issuer_cn, serial_number, not_before, not_after, certificate_pem = result
                    certificate_pem = certificate_pem.replace('\n', '')
                    writer.writerow({
                        'Subject CN': subject_cn,
                        'Issuer CN': issuer_cn,
                        'Serial Number': serial_number,
                        'Not Before': not_before,
                        'Not After': not_after,
                        'Certificate PEM': certificate_pem
                    })

if __name__ == '__main__':
    hosts_file = 'hosts.csv'
    main(hosts_file)
