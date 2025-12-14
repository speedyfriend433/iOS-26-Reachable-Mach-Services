// PoC.m - Standalone Objective C code to enumerate reachable Mach services on iOS 26. works on non jb
// Credits to zhuowei (original bootstrap lookup code)
// Compile: clang -o PoC PoC.m -framework Foundation

#import <Foundation/Foundation.h>
#import <mach/mach.h>
#include "bootstrap.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *plistPath = @"/System/Library/xpc/launchd.plist";
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        if (!dict) {
            printf("Failed to load %s\n", [plistPath UTF8String]);
            return 1;
        }

        NSDictionary *launchDaemons = dict[@"LaunchDaemons"];
        if (!launchDaemons) {
            printf("No LaunchDaemons key found\n");
            return 1;
        }

        for (NSString *key in launchDaemons) {
            NSDictionary *job = launchDaemons[key];
            NSDictionary *machServices = job[@"MachServices"];
            if (machServices) {
                for (NSString *serviceName in machServices) {
                    mach_port_t service_port = MACH_PORT_NULL;
                    kern_return_t err = bootstrap_look_up(bootstrap_port, (char *)[serviceName UTF8String], &service_port);
                    if (err == KERN_SUCCESS && service_port != MACH_PORT_NULL) {
                        printf("%s\n", [serviceName UTF8String]);
                        mach_port_deallocate(mach_task_self(), service_port);
                    }
                }
            }
        }
    }
    return 0;
}
