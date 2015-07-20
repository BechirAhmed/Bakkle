import smtplib

def prompt(prompt):
    return raw_input(prompt).strip()

fromaddr = 'wongb@rose-hulman.edu'
toaddrs  = 'wongb@rose-hulman.edu'
msg = "Hello, this is dog."

#Change according to your settings
smtp_server = 'email-smtp.us-west-2.amazonaws.com'
smtp_username = 'AKIAIWU57Q5HQBFHEYGQ'
smtp_password = 'Atuz2dvDHbHZCvq7mWZF2cORjZn+XL5TFtYe2VsT2rlf'
smtp_port = '587'
smtp_do_tls = True

server = smtplib.SMTP(
    host = smtp_server,
    port = smtp_port,
    timeout = 10
)

def sendMsg(toaddrs, message):

	# server.set_debuglevel(10)
	server.starttls()
	server.ehlo()
	server.login(smtp_username, smtp_password)
	server.sendmail(fromaddr, toaddrs, msg)
	# print server.quit()

sendMsg(toaddrs, msg)