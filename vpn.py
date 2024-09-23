#!/usr/bin/env python3

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
import os
import subprocess

class VPNManager(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="WireGuard VPN Manager")
        self.set_border_width(10)
        self.set_default_size(300, 200)

        self.vpn_list = self.get_vpn_configs()
        self.current_vpn = None

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add(vbox)

        self.vpn_combo = Gtk.ComboBoxText()
        self.vpn_combo.connect("changed", self.on_vpn_combo_changed)
        for vpn in self.vpn_list:
            self.vpn_combo.append_text(vpn)
        vbox.pack_start(self.vpn_combo, False, False, 0)

        self.status_label = Gtk.Label(label="Select a VPN")
        vbox.pack_start(self.status_label, False, False, 0)

        self.button = Gtk.Button(label="Connect")
        self.button.connect("clicked", self.on_button_clicked)
        vbox.pack_start(self.button, False, False, 0)

    def get_vpn_configs(self):
        try:
            output = subprocess.check_output(["sudo", "ls", "/etc/wireguard"], universal_newlines=True)
            configs = [file[:-5] for file in output.split() if file.endswith(".conf")]
            return configs
        except subprocess.CalledProcessError:
            print("Error: Unable to list WireGuard configurations. Make sure you have the necessary permissions.")
            return []

    def on_vpn_combo_changed(self, combo):
        self.current_vpn = combo.get_active_text()
        status = self.get_vpn_status(self.current_vpn)
        self.status_label.set_text(f"Status: {status}")
        self.button.set_label("Disconnect" if status == "Connected" else "Connect")

    def on_button_clicked(self, button):
        if not self.current_vpn:
            return

        status = self.get_vpn_status(self.current_vpn)
        if status == "Connected":
            self.disconnect_vpn(self.current_vpn)
        else:
            self.connect_vpn(self.current_vpn)

        GLib.timeout_add(1000, self.update_status)

    def get_vpn_status(self, vpn):
        try:
            subprocess.check_output(["sudo", "wg", "show", vpn], stderr=subprocess.DEVNULL)
            return "Connected"
        except subprocess.CalledProcessError:
            return "Disconnected"

    def connect_vpn(self, vpn):
        subprocess.run(["sudo", "wg-quick", "up", vpn])

    def disconnect_vpn(self, vpn):
        subprocess.run(["sudo", "wg-quick", "down", vpn])

    def update_status(self):
        if self.current_vpn:
            status = self.get_vpn_status(self.current_vpn)
            self.status_label.set_text(f"Status: {status}")
            self.button.set_label("Disconnect" if status == "Connected" else "Connect")
        return False

win = VPNManager()
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
