//
//  main.m
//  Installer
//
//  Created by Erwan Barrier on 8/11/12.
//  Copyright (c) 2012 Erwan Barrier. All rights reserved.
//

#import <launch.h>
#import <Foundation/Foundation.h>

#import "DKFrameworkInstaller.h"


#include <syslog.h>
#include <xpc/xpc.h>




static void __XPC_Peer_Event_Handler(xpc_connection_t connection, xpc_object_t event) {
    syslog(LOG_NOTICE, "Received event in helper.");
    
	xpc_type_t type = xpc_get_type(event);
    
	if (type == XPC_TYPE_ERROR) {
		if (event == XPC_ERROR_CONNECTION_INVALID) {
			// The client process on the other end of the connection has either
			// crashed or cancelled the connection. After receiving this error,
			// the connection is in an invalid state, and you do not need to
			// call xpc_connection_cancel(). Just tear down any associated state
			// here.
            
		} else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
			// Handle per-connection termination cleanup.
		}
        
	} else {
        xpc_connection_t remote = xpc_dictionary_get_remote_connection(event);
        
        const char* response = xpc_dictionary_get_string(event, "request");

        
        NSString *frameworkPath = [NSString stringWithFormat:@"%s", response];

        //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){

        syslog(LOG_NOTICE, "JINX INSTALLATIONS");
        DKFrameworkInstaller *installer = [DKFrameworkInstaller new];
        [installer installFramework:frameworkPath];
        syslog(LOG_NOTICE, "JINX INSTALLATIONS");
        
        //});

        syslog(LOG_NOTICE, "HOLY SHIT");
        syslog(LOG_NOTICE, "HOLY SHIT");
        syslog(LOG_NOTICE, "HOLY SHIT");

        syslog(LOG_NOTICE, [[NSString stringWithFormat:@"%s", response] UTF8String]);
        
        syslog(LOG_NOTICE, "HOLY SHIT");
        syslog(LOG_NOTICE, "HOLY SHIT");
        syslog(LOG_NOTICE, "HOLY SHIT");
        
        
        xpc_object_t reply = xpc_dictionary_create_reply(event);
        xpc_dictionary_set_string(reply, "reply", "Hi there, host application!");
        xpc_connection_send_message(remote, reply);
        xpc_release(reply);
	}
}

static void __XPC_Connection_Handler(xpc_connection_t connection)  {
    syslog(LOG_NOTICE, "Configuring message event handler for helper.");
    
	xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
		__XPC_Peer_Event_Handler(connection, event);
	});
	
	xpc_connection_resume(connection);
}





dispatch_source_t g_timer_source = NULL;

int main(int argc, const char * argv[])
{
    xpc_connection_t service = xpc_connection_create_mach_service("com.erwanb.MachInjectSample.Installer",
                                                                  dispatch_get_main_queue(),
                                                                  XPC_CONNECTION_MACH_SERVICE_LISTENER);
    
    if (!service) {
        syslog(LOG_NOTICE, "Failed to create service.");
        exit(EXIT_FAILURE);
    }
    
    syslog(LOG_NOTICE, "Configuring connection event handler for helper");
    xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {
        __XPC_Connection_Handler(connection);
    });
    
    xpc_connection_resume(service);
    
    dispatch_main();
    
    xpc_release(service);
    
    return EXIT_SUCCESS;

    
    
//    
//  @autoreleasepool {
//    // Init idle-exit timer
//    dispatch_queue_t mq = dispatch_get_main_queue();
//    g_timer_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, mq);
//    assert(g_timer_source != NULL);
//    
//    /* When the idle-exit timer fires, we just call exit(2) with status 0. */
//    dispatch_set_context(g_timer_source, NULL);
//    dispatch_source_set_event_handler_f(g_timer_source, (void (*)(void *))exit);
//    /* We start off with our timer armed. This is for the simple reason that,
//     * upon kicking off the GCD state engine, the first thing we'll get to is
//     * a connection on our socket which will disarm the timer. Remember, handling
//     * new connections and the firing of the idle-exit timer are synchronized.
//     */
//    dispatch_time_t t0 = dispatch_time(DISPATCH_TIME_NOW, 5llu * NSEC_PER_SEC);
//    dispatch_source_set_timer(g_timer_source, t0, 0llu, 0llu);
//    dispatch_resume(g_timer_source);
//    
//    
//    // Check in mach service
//    launch_data_t req = launch_data_new_string(LAUNCH_KEY_CHECKIN);
//    assert(req != NULL);
//
//    launch_data_t resp = launch_msg(req);
//    assert(resp != NULL);
//    assert(launch_data_get_type(resp) == LAUNCH_DATA_DICTIONARY);
//
//    launch_data_t machs = launch_data_dict_lookup(resp, LAUNCH_JOBKEY_MACHSERVICES);
//    assert(machs != NULL);
//    assert(launch_data_get_type(machs) == LAUNCH_DATA_DICTIONARY);
//
//    launch_data_t machPortData = launch_data_dict_lookup(machs, "com.erwanb.MachInjectSample.Installer.mach");
//
//    mach_port_t mp = launch_data_get_machport(machPortData);
//    launch_data_free(req);
//    launch_data_free(resp);
//
//    NSMachPort *rp = [[NSMachPort alloc] initWithMachPort:mp];
//    NSConnection *c = [NSConnection connectionWithReceivePort:rp sendPort:nil];
//
//    DKFrameworkInstaller *installer = [DKFrameworkInstaller new];
//    [c setRootObject:installer];
//
//    [[NSRunLoop currentRunLoop] run];
//
//    return (0);
//  }
}

