//
//  InjectorWrapper.m
//  Dark
//
//  Created by Erwan Barrier on 8/6/12.
//  Copyright (c) 2012 Erwan Barrier. All rights reserved.
//

#import <ServiceManagement/ServiceManagement.h>
#import <mach/mach_error.h>

#import "DKInjector.h"
#import "DKInjectorProxy.h"

@implementation DKInjectorProxy

+ (void)appendLog:(NSString *)log {
    NSLog(@"LOG injector: %@", log);
}


+ (BOOL)inject:(NSError **)error {
    
    
    xpc_connection_t connection = xpc_connection_create_mach_service("com.erwanb.MachInjectSample.Injector", NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    
    if (!connection) {
        [self appendLog:@"Failed to create XPC connection."];
        return NO;
    }
    
    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        xpc_type_t type = xpc_get_type(event);
        
        if (type == XPC_TYPE_ERROR) {
            
            if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
                [self appendLog:@"XPC connection interupted."];
                
            } else if (event == XPC_ERROR_CONNECTION_INVALID) {
                [self appendLog:@"XPC connection invalid, releasing."];
                xpc_release(connection);
                
            } else {
                [self appendLog:@"Unexpected XPC connection error."];
            }
            
        } else {
            [self appendLog:@"Unexpected XPC connection event."];
        }
    });
    
    xpc_connection_resume(connection);
    
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    const char* request = "Hi there, helper service.";
    xpc_dictionary_set_string(message, "request", request);
    
    [self appendLog:[NSString stringWithFormat:@"Sending request: %s", request]];
    
    xpc_connection_send_message_with_reply(connection, message, dispatch_get_main_queue(), ^(xpc_object_t event) {
        const char* response = xpc_dictionary_get_string(event, "reply");
        [self appendLog:[NSString stringWithFormat:@"Received response: %s.", response]];
    });
    return YES;
    
//    
//    
//    
//  NSConnection *c = [NSConnection connectionWithRegisteredName:@"com.erwanb.MachInjectSample.Injector.mach" host:nil];
//  assert(c != nil);
//
//  DKInjector *injector = (DKInjector *)[c rootProxy];
//  assert(injector != nil);
//
//  pid_t pid = [[[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.finder"]
//                lastObject] processIdentifier];
//  
//  NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Payload" ofType:@"bundle"];
//
//  NSLog(@"Injecting Finder (%@) with %@", [NSNumber numberWithInt:pid], bundlePath);
//
//  mach_error_t err = [injector inject:pid withBundle:[bundlePath fileSystemRepresentation]];
//
//  if (err == 0) {
//    NSLog(@"Injected Finder");
//    return YES;
//  } else {
//    NSLog(@"an error occurred while injecting Finder: %@ (error code: %@)", [NSString stringWithCString:mach_error_string(err) encoding:NSASCIIStringEncoding], [NSNumber numberWithInt:err]);
//
//    *error = [[NSError alloc] initWithDomain:DKErrorDomain
//                                        code:DKErrInjection
//                                    userInfo:@{NSLocalizedDescriptionKey: DKErrInjectionDescription}];
//
//    return NO;
//  }
}

@end
