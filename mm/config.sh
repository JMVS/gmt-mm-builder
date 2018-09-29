AUTOMOUNT=true
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false
print_modname() {
  ui_print "*******************************"
  ui_print "   Genymobile Tools for OP3T   "
  ui_print " by @J_M_V_S at xda-developers "
  ui_print "*******************************"
}
REPLACE=""
set_permissions() {
  set_perm $MODPATH/system/etc/usb_drivers.iso 0 0 0644
}