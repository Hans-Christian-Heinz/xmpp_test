# XmppTest

This is a test project for the purpose of learning and practicing the language Elixir.
It is not intended to be used.  
The project consists of three applications:
+ XmppTestServer: listens for tcp-connections, associates connections with users
saved in a MariaDB-database and enables sending messages between users.
+ XmppTestClient: connects to an XmppTestServer, sends messages to it and shows
the responses. (UI: command line)
+ XmppTestParser: generates appropriate data-structures from xmpp-stanzas (xml-blocks)
and vice versa.

## XmppTestServer

When starting the server (*\_build/prod/rel/server/bin/server start* or *cd apps/xmpp_test_server* followed by *mix run --no-halt*) you are asked for some configuration-info:
+ mysql-host: the location of the database-server containing user-information
+ database-name: the name of the database containing user-information
+ mysql-user: the user, that is to access the database
+ mysql-password: the mysql-user's password
+ xmpp-port: the tcp-port on which to listen for connections  

Once the configuration-information is entered, the server is started and listens
for connections. To stop the server, press *ctrl+c*.

## XmppTestClient

When starting the client (*\_build/prod/rel/client/bin/client start* or *cd apps/xmpp_test_client* followed by *mix run --no-halt*) you are asked for some configuration-info:
+ xmpp-server: the location of the XmppTestServer to connect to
+ xmpp-port: the port on which to connect to the server  

Once the configuration-information is entered, the client is started. To stop the
client, press *ctrl+c*.
After starting the XmppTestClient prompts the user for input on the command line.
First is a login or registration prompt. After logging in the following commands
are available:
+ available users: returns a list of all currently logged in users.
+ send message: asks for a username to send a message to and the content of the
message before sending that message.
+ logout: logout of the application.

## XmppTestParser

The XmppTestParser is used by both XmppTestServer and XmppTestClient. It is not
intended to be used on its own.
