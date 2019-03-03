OPENSSL_SUBJ=/C=NL/ST=Zuid-Holland/L=Den Haag/O=DigitalCitizen B.V./OU=Public Key Infrastructure/emailAddress=pki@digitalcitizen.one
ROOT_CRT=-CA root.crt
ROOT_KEY=-CAkey root.key


all:
	make root.crt
	make k8s.crt


root.crt:
	openssl req -new -newkey rsa:4096 -nodes -days 3650 -x509\
		-keyout root.key -out root.crt\
		-subj "$(OPENSSL_SUBJ)/CN=Local Root Certificate Authority"


k8s.crt:
	openssl genrsa -out k8s.rsa 4096
	@openssl req -new -sha256 -out k8s.csr -key k8s.rsa\
		-config k8s.conf -extensions v3_req -reqexts v3_req
	@openssl x509 -req -in k8s.csr -days 3650\
		$(ROOT_CRT) $(ROOT_KEY) -set_serial 01 -out k8s.crt\
		-extfile k8s.conf -extensions v3_req


authorized_keys:
	ssh-add -L > authorized_keys
