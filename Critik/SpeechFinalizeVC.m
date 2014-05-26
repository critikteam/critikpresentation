//
//  SpeechFinalizeVC.m
//  Critik
//
//  Created by Dalton Decker on 3/3/14.
//  Copyright (c) 2014 RedVelvet. All rights reserved.
//

#import "SpeechFinalizeVC.h"

@interface SpeechFinalizeVC () <DBRestClientDelegate>

@property NSArray *  QuickGrades;
@property NSArray * rightQuickGrades;
@property NSArray * leftQuickGrades;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation SpeechFinalizeVC
@synthesize restClient;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set app delegate and managedObject
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    //Set the text of points earned, penalty points, and total points
    self.pointsEarned.text = [NSString stringWithFormat:@"%@",self.currentStudentSpeech.pointsEarned];
    self.penaltyPoints.text = [NSString stringWithFormat:@"%@",self.currentStudentSpeech.penaltyPoints];
    self.totalPoints.text = [NSString stringWithFormat:@"%@ / %u",self.currentStudentSpeech.totalPoints,self.pointsPossible];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark PDF Generation
-(IBAction)generatePDF:(id)sender
{
    //Variables to store origin
    int originX = 20;
    int originY = 20;
    int contentSize = 0;
    int pageSize = 792;
    //file name
    NSString * fileName = [NSString stringWithFormat:@"%@-%@ %@.pdf",self.currentStudentSpeech.speech.speechType,self.currentStudent.firstName, self.currentStudent.lastName];
    //Get document directory path and create new file with given filename
    NSString *path = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:fileName];
    //create pdf context
    UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);
    //set pdf font
    UIFont * font = [UIFont fontWithName:@"Times" size:10];

    // Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    // Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    // Set text alignment
    paragraphStyle.alignment = NSTextAlignmentRight;

    //Set attributes based type of data
    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];

    //Images to use for Quick Grades
    UIImage * minusQG = [UIImage imageNamed:@"minusQuickGrade.png"];
    UIImage * okQG = [UIImage imageNamed:@"okQuickGrade.png"];
    UIImage * plusQG = [UIImage imageNamed:@"plusQuickGrade.png"];
    
    //Get the modules from current speech and organize them so they are in order
    NSArray * Modules = [self.currentStudentSpeech.speech.modules allObjects];
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderIndex" ascending:YES];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    Modules = [NSMutableArray arrayWithArray:[Modules sortedArrayUsingDescriptors:descriptors]];
    
    //Begin new page
    UIGraphicsBeginPDFPage();
    
    //Draw Student Name at top of document
    [ [NSString stringWithFormat:@"%@ Presentation - %@ %@",self.currentStudentSpeech.speech.speechType, self.currentStudent.firstName, self.currentStudent.lastName] drawAtPoint:CGPointMake(originX, originY) withAttributes:attributes];
    contentSize += 20;
    //Go to a new line
    originY += 20;
    
    //Iterate through each module to print out coresponding data
    for(int i = 0; i < [Modules count]-1; i ++)
    {
        if(!(contentSize < pageSize)){
            UIGraphicsBeginPDFPage();
            contentSize = 20;
            originX = 20;
            originY = 20;
        }
        //Current Module to print data from
        Module * currentModule = [Modules objectAtIndex:i];

        //Draw Module Name along with points earned out of total possible points
        [[NSString stringWithFormat:@"%@ - %d/%d pts",currentModule.moduleName, [currentModule.points intValue], [currentModule.pointsPossible intValue] ]drawInRect:CGRectMake(originX, originY, 550, 20) withAttributes:attributes]; //drawAtPoint:CGPointMake(originX, originY) withAttributes:moduleAttributes];
        contentSize += 20;

        //Increment Origins to a new line and indent
        originY += 20;
        originX += 20;

        //Get quick grades from current module and organize them so they are in order
        self.QuickGrades = [currentModule.quickGrade allObjects];
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"quickGradeDescription" ascending:YES];
        NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
        self.QuickGrades = [NSMutableArray arrayWithArray:[self.QuickGrades sortedArrayUsingDescriptors:descriptors]];

        //Split quickGrades into two arrays allowing for 2 equal columns on pdf
        [self splitQuickGradesArray];

        //Iterate through the QuickGrade arrays to print quickGrades
        for(int j = 0; j < [self.leftQuickGrades count]; j ++)
        {
            if(!(contentSize < pageSize)){
                UIGraphicsBeginPDFPage();
                contentSize = 20;
                originY = 20;
            }
            
            //Sets current QuickGrade
            QuickGrade * leftQuickGrade = [self.leftQuickGrades objectAtIndex:j];

            //Print QuickGrade Description
            [leftQuickGrade.quickGradeDescription drawInRect:CGRectMake(originX, originY, 200, 20) withAttributes:attributes];

            //Print QuickGrade Score image
            switch([leftQuickGrade.score intValue])
            {
                case 0: [minusQG drawInRect:CGRectMake(originX + 225, originY + 3, 40, 15)];
                    contentSize += 20;
                    break;
                case 1: [okQG drawInRect:CGRectMake(originX + 225, originY + 3, 40, 15)];
                    contentSize += 20;
                    break;
                case 2: [plusQG drawInRect:CGRectMake(originX + 225, originY + 3, 40, 15)];
                    contentSize += 20;
                    break;
            }
            
            if(j < [self.rightQuickGrades count]){
                //Sets current QuickGrade
                QuickGrade * rightQuickGrade = [self.rightQuickGrades objectAtIndex:j];
                
                //Print QuickGrade Description
                [rightQuickGrade.quickGradeDescription drawInRect:CGRectMake(originX + 300, originY, 200, 20) withAttributes:attributes];
                
                //Print QuickGrade Score image
                switch([rightQuickGrade.score intValue])
                {
                    case 0: [minusQG drawInRect:CGRectMake(originX + 500, originY + 3, 40, 15)];
                        break;
                    case 1: [okQG drawInRect:CGRectMake(originX + 500, originY + 3, 40, 15)];
                        break;
                    case 2: [plusQG drawInRect:CGRectMake(originX + 500, originY + 3, 40, 15)];
                        break;
                }
            }
            
            //Go to a new line
            originY += 20;
            contentSize += 20;
        }

        //Get preDefinedComments from current module and organize them so that they are in order
        NSArray * preDefinedComments = [currentModule.preDefinedComments allObjects];
        valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comment" ascending:YES];
        descriptors = [NSArray arrayWithObject:valueDescriptor];
        preDefinedComments = [NSMutableArray arrayWithArray:[preDefinedComments sortedArrayUsingDescriptors:descriptors]];

        //Iterate through the PredefinedComments and print on to page
        for(int a = 0; a < [preDefinedComments count]; a ++)
        {
            if(!(contentSize < pageSize)){
                UIGraphicsBeginPDFPage();
                contentSize = 20;
                originY = 20;
            }
            
            //Current PreDefinedComment to Print
            PreDefinedComments * currentComment = [preDefinedComments objectAtIndex:a];
            if([currentComment.isSelected boolValue]){
                //Draw PreDefinedComment
                [currentComment.comment drawAtPoint:CGPointMake(originX, originY) withAttributes:attributes];
                contentSize += 20;
                originY += 20;
            }
        }
        
        //Go to a new line and bring indention inward
        originY += 25;
        originX -= 20;
        contentSize += 25;
    }
    
    originY +=30;
    
    //Draw penalty points
    [[NSString stringWithFormat:@"Points Earned: %@",self.currentStudentSpeech.pointsEarned] drawInRect:CGRectMake(originX, originY, 150, 20) withAttributes:attributes];
    [[NSString stringWithFormat:@"Penalty Points: %@",self.currentStudentSpeech.penaltyPoints] drawInRect:CGRectMake(originX + 150, originY, 150, 20) withAttributes:attributes];
    originY += 20;
    contentSize += 20;
    if([self.currentStudentSpeech.isLate isEqualToString:@"true"]){
        [[NSString stringWithFormat:@"%@",@"**Presented Late**"] drawInRect:CGRectMake(originX, originY, 500, 20) withAttributes:attributes];
        originY += 20;
    }
    if([self.currentStudentSpeech.overTime isEqualToString:@"true"]){
        [[NSString stringWithFormat:@"%@",@"**Did not meet time constraints**"] drawInRect:CGRectMake(originX, originY, 500, 20) withAttributes:attributes];
        originY += 20;
    }
    
    //Draw total points
    [[NSString stringWithFormat:@"Total Points: %@",self.currentStudentSpeech.totalPoints] drawInRect:CGRectMake(originX, originY, 150, 20) withAttributes:attributes];
    originY += 20;
    
    int minutes = ([self.currentStudentSpeech.duration intValue] / 60.0);
    // We calculate the seconds.
    int seconds = ([self.currentStudentSpeech.duration intValue] - (minutes * 60));
    
    [[NSString stringWithFormat:@"Duration: %u:%02u",minutes, seconds]drawInRect:CGRectMake(originX, originY, 150, 20) withAttributes:attributes];
    originY += 40;
    [[NSString stringWithFormat:@"Additional Comments: \n%@",self.currentStudentSpeech.comments] drawInRect:CGRectMake(originX+10, originY, 550, 250) withAttributes:attributes];
    //close and save pdf context
    UIGraphicsEndPDFContext();
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        
    }else if( [[DBSession sharedSession] isLinked]){
        
        NSString *destPath = [NSString stringWithFormat:@"/Student Reports/%@/%@",self.currentStudent.section.sectionName,self.currentStudentSpeech.speech.speechType];
        [self.restClient loadMetadata:destPath];
        [self.restClient deletePath:[NSString stringWithFormat:@"%@/%@",destPath,fileName ]];
        [self.restClient uploadFile: fileName toPath: destPath withParentRev:nil fromPath:path];
    }
    
    self.currentStudentSpeech.hasBeenEvaluated = @"true";
    
    NSError * error;
    if(![self.managedObjectContext save:&error]){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Warning!" message: @"Presentation could not be saved."delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark QuickGrade Arrays
//Splits the quick grades into two separate arrays: left, right.
-(void) splitQuickGradesArray
{
    NSRange someRange;
    
    someRange.location = 0;
    someRange.length = [self.QuickGrades count] / 2;
    self. rightQuickGrades = [NSMutableArray arrayWithArray:[self.QuickGrades subarrayWithRange:someRange]];
    
    
    someRange.location = someRange.length;
    someRange.length = [self.QuickGrades count] - someRange.length;
    self.leftQuickGrades = [NSMutableArray arrayWithArray:[self.QuickGrades subarrayWithRange:someRange]];
}

//Retireves the path of Documents Directory
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - DropBox methods

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"File has been uploaded successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"File has been uploaded successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
