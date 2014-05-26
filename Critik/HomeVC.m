//
//  HomeVC.m
//  Critik
//
//  Created by Dalton Decker on 2/12/14.
//  Copyright (c) 2014 RedVelvet. All rights reserved.
//

#import "HomeVC.h"

@interface HomeVC ()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation HomeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = [appDelegate managedObjectContext];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonSelection:(id)sender
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSError* error;
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.managedObjectContext]];
    
    NSArray * students = [NSArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Speech" inManagedObjectContext:self.managedObjectContext]];
    NSArray * speeches = [NSArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    if([students count] == 0 || [speeches count] == 0)
    {
        if([students count] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Wait!" message: @"Don't get too excited! Please add a section and student first." delegate:self  cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Almost There!" message: @"You must also add something to speeches in order to evaluate" delegate:self  cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
            [alert show];
        }
    }else{

            SpeechSelectionVC * evaluate = [self.storyboard instantiateViewControllerWithIdentifier:@"Speech Selection"];
            
            [self.navigationController pushViewController:evaluate animated:YES];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)UnwindFromFinalizeToHome:(UIStoryboardSegue *)unwindSegue
{
    
}
@end
