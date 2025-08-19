#import "ViewController.h"
#import "bootstrap.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self machServices];
}

- (void)machServices {
    NSDictionary<NSString*, id>* dict = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/xpc/launchd.plist"];
    NSDictionary<NSString*, id>* launchDaemons = dict[@"LaunchDaemons"];
    for (NSString* key in launchDaemons) {
        NSDictionary<NSString*, id>* job = launchDaemons[key];
        NSDictionary<NSString*, id>* machServices = job[@"MachServices"];
        for (NSString* serviceName in machServices) {
            mach_port_t service_port = MACH_PORT_NULL;
            kern_return_t err = bootstrap_look_up(bootstrap_port, serviceName.UTF8String, &service_port);
            if (!err) {
                printf("%s\n", serviceName.UTF8String);
                mach_port_deallocate(mach_task_self_, service_port);
            }
        }
    }
}

@end
