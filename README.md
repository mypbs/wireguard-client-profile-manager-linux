The problem with most Wireguard tools is they let you manage multiple "clients" from the server but what if you have one client with multiple servers?  This program will read the configuration files in /etc/wireguard and create a simple menu system to connect/disconnect so you don't have to keep typing sudo wg-quick up {interface} or sudo wg-quick down {interface}.  

You can select your VPN gateway and connect or disconnect as needed.

Note make sure you add yourself to visudo to avoid any issues:
```
your_username ALL=(ALL) NOPASSWD: /usr/bin/wg, /usr/bin/wg-quick 
``` 

And finally make sure your files in /etc/wireguard have names less than 15 characters wg0name1.conf wg0name2.conf...

CLI Screenshot

![wgcli](https://github.com/user-attachments/assets/b38a2377-a14c-475a-b611-20a5fbd17a06)

GUI (Python) Screenshot

![guivpn](https://github.com/user-attachments/assets/05e6f2cd-b296-4c00-afb3-f7a9fc86d328)

For the GUI version simply create a desktop launcher short cut to the PY file and you now have a one click VPN app.
