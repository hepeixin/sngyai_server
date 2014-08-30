//
//  AppDelegate.m
//  LiZhuan
//
//  Created by sngyai on 14-8-27.
//
//

#import "AppDelegate.h"
#import "TaskTableViewController.h"
#import "RootViewController.h"
#import "PunchBoxAd.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    tabBar = [[RootViewController alloc] init];
    
	
    TaskTableViewController *viewController = [[[TaskTableViewController alloc] init] autorelease];
 
    tabBar.viewControllers = [NSArray arrayWithObjects:viewController, nil];
    self.window.rootViewController = tabBar;
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"HELLO, WORLD applicationDidEnterBackground");
    __block UIBackgroundTaskIdentifier background_task;
    //Create a task object
    background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
        while (TRUE) {
            [NSThread sleepForTimeInterval:1];
            NSLog(@"HELLO, WORLD running ~~~~~~~~~~~~~~~");
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
        }
        NSLog(@"exit~~~~~~~~~~~~~~~~~~ back ground !!!");
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    

//    __block UIBackgroundTaskIdentifier background_task;
//    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
//        
//        //Clean up code. Tell the system that we are done.
//        [application endBackgroundTask: background_task];
//        NSLog(@"Running out the background\n");
//        background_task = UIBackgroundTaskInvalid;
//    }];
//    
//    //To make the code block asynchronous
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        //### background task starts
//        NSLog(@"Running in the background\n");
//        while(TRUE)
//        {
//            NSLog(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
//            [NSThread sleepForTimeInterval:1]; //wait for 1 sec
//        }
//        //#### background task ends
//        
//        //Clean up code. Tell the system that we are done.
//        NSLog(@"Running out the background   0\n");
//        [application endBackgroundTask: background_task];
//        NSLog(@"Running out the background   1\n");
//        background_task = UIBackgroundTaskInvalid;
//    });
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"LocalNotification" message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
    NSDictionary* dic = [[NSDictionary alloc]init];
    //这里可以接受到本地通知中心发送的消息
    dic = notification.userInfo;
    NSLog(@"user info = %@",[dic objectForKey:@"key"]);
    
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"HELLO, WORLD applicationWillResignActive");
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

@end
