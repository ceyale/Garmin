@echo off
"C:\PROGRA~1\Git\usr\bin\openssl.exe" genrsa -out "C:\Users\franc\Documents\Etienne\Garmin\developer_key.pem" 2048
"C:\PROGRA~1\Git\usr\bin\openssl.exe" rsa -in "C:\Users\franc\Documents\Etienne\Garmin\developer_key.pem" -outform DER -out "C:\Users\franc\Documents\Etienne\Garmin\developer_key"