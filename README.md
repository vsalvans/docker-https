This little project is using code and explanations from:

https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate/43666288#43666288

Thanks to [Brad Parks](https://stackoverflow.com/users/26510/brad-parks)

On the Mac, you can create a certificate that's fully trusted by Chrome and Safari at the system level by doing the following:

**create a root authority cert**
./create_root_cert_and_key.sh

**create a wildcard cert for mysite.com**
./create_certificate_for_domain.sh mysite.com

**or create a cert for www.mysite.com, no wildcards**
./create_certificate_for_domain.sh www.mysite.com www.mysite.com
The above uses the following scripts, and a supporting file v3.ext, to avoid subject alternative name missing errors

One more step - How to make the self signed certs fully trusted in Chrome/Safari
To allow the self signed certificates to be FULLY trusted in Chrome and Safari, you need to import a new certificate authority into your Mac. To do so follow these instructions, or the more detailed instructions on this general process on the mitmproxy website:

You can do this one of 2 ways, at the command line, using this command which will prompt you for your password:

$ sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain rootCA.pem

or by using the Keychain Access app:

Open Keychain Access
Choose "System" in the "Keychains" list
Choose "Certificates" in the "Category" list
Choose "File | Import Items..."
Browse to the file created above, "rootCA.pem", select it, and click "Open"
Select your newly imported certificate in the "Certificates" list.
Click the "i" button, or right click on your certificate, and choose "Get Info"
Expand the "Trust" option
Change "When using this certificate" to "Always Trust"
Close the dialog, and you'll be prompted for your password.
Close and reopen any tabs that are using your target domain, and it'll be loaded securely!
and as a bonus, if you need java clients to trust the certificates, you can do so by importing your certs into the java keystore. Note this will remove the cert from the keystore if it already exists, as it needs to to update it in case things change. It of course only does this for the certs being imported.

**Build your https image**
docker build --build-arg domain={domain} -t https-image .

**Run the container**
docker run -d -p 8443:443 -v $PWD/src:/var/www/html --name https-container https-image

**Add the certificate to the trusted certificates list if it's necessary**

**Add domain used in your hosts files**
127.0.0.1 {domain}

**Open your browser https://{domain}:8443**

