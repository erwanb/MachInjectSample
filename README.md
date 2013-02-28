# Welcome To MachInjectSample

**This project has been merged into the [mach_inject](https://github.com/rentzsch/mach_inject) repo.**

MachInjectSample demonstrate the use of mach inject with the new SMJobBless API. By creating a privileged helper tool with the SMJobBless API, we can avoid asking an admin password each time we need to inject code into a process.

## Description of contents

* MachInjectSample: The app.
* Installer: a helper tool (launch-on-demand) for installing mach_inject_bundle.framework (needed by the injector). This avoid the need to create a pkg installer, as the injector need to know the path to mach_inject_bundle at compile time.
* Injector: a helper tool (launch-on-demand daemon) for injecting code in a process.
* Payload: a bundle running inside the process. For demonstration purpose, it just write a message in /var/log/system.log upon loading.

Before testing, you need to code-sign the app, injector and installer with the same certificate.

For more info about the SMJobBless API, [see here](https://developer.apple.com/library/mac/#documentation/ServiceManagement/Reference/ServiceManagement_header_reference/Reference/reference.html#//apple_ref/doc/uid/TP40012447).
For more info on mach_inject, [see here](https://github.com/rentzsch/mach_inject).


----------------------------------------------------------------
------------------------- Addendum: ----------------------------

Compilation notes -Orbitus007

what I did to get this thing to compile on MacOSX 10.7.5:

----------------------------------------------------------------
on the command line do a:
cd ~/Desktop
git clone https://github.com/erwanb/MachInjectSample.git
cd ./MachInjectSample
git submodule update --init
open MachInjectSample.xcodeproj/

Choose the xcodeproject MachInjectSample
set the exe target com.erwanb.MachInjectSample.Installer to the code signing identity of a mac developer
set the exe target com.erwanb.MachInjectSample.Injector to the same developer
set the App target MachInjectSample to the same developer

search for files with *.plist in the name
goto Installer-Info.plist and set the clients allowed to add/remove to: 
	identifier com.klink.macsync and certificate leaf[subject.CN] = "Mac Developer: Rudy Aramayo (R2287HQBC8)"
	identifier com.klink.macsync and certificate leaf[subject.CN] = "Mac Developer: Rudy Aramayo (R2287HQBC8) Development"

do the same for Injector-Info.plist
	identifier com.klink.macsync and certificate leaf[subject.CN] = "Mac Developer: Rudy Aramayo (R2287HQBC8)"
	identifier com.klink.macsync and certificate leaf[subject.CN] = "Mac Developer: Rudy Aramayo (R2287HQBC8) Development"
*use the App target's bundle id and your own developer information just like this

Select mach_inject_bundle.xcodeproj from the files selection tableview and set architectures build phase of the mach_inject_bundle target to Native Architecture of the Machine

Select the MachInjectSample project and select the MachInjectSample target... goto the summary pane and  set the deployment target to 10.7

goto DKAppDelegate.m and change lines 21-24 to:

  // Install helper tools
  if (//[DKInstaller isInstalled] == NO &&
      [DKInstaller install:&error] == NO) {
    assert(error != nil);

the installation check sets an NSUserDefault that will not get to the hanging code... although the very next line goes into a connection which fails... (not installed) This is a weird case in my machine since I have run this already multiple times and the installation/userdefaults setting that controls the isInstalled response still linger in the system.

----------------------------------------------------------------
