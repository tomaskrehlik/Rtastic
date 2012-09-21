package_update_logfile = File.open("/Users/tomaskrehlik/Documents/Ruby/Rtastic/log/package_update.log", 'a')
package_update_logfile.sync = true
UPDATE_PACKAGE_LOG = Packageupdatelogger.new(package_update_logfile)