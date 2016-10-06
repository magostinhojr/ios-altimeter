//
//  ViewController.m
//  Altitude Test
//
//  Created by Marcelo Agostinho on 06/10/2016.
//

#import <math.h>
#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>;

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *hintLabel;
@property (strong, nonatomic) IBOutlet UILabel *pressureOneLabel;
@property (strong, nonatomic) IBOutlet UILabel *pressureTwoLabel;
@property (strong, nonatomic) IBOutlet UILabel *relativeAltitudeLabel;

@property (strong, nonatomic) CMAltimeter *altimeter;

@property (strong, nonatomic) NSNumber *pressureOne;
@property (strong, nonatomic) NSNumber *pressureTwo;
@property (strong, nonatomic) NSNumber *relativeAltitude;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defaultLabelValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


#pragma mark - Getter / Setter

- (CMAltimeter *)altimeter {
    
    if (!_altimeter) {
        _altimeter = [[CMAltimeter alloc]init];
    }
    return _altimeter;
}



#pragma mark - IBAction

- (IBAction)trackAltitude {
    
    if([self checkBarometerAvailability]){
        [self.altimeter startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
            [self updateLabels:altitudeData];
        }];
    }
}

- (IBAction)clearTracking:(id)sender {
    [self defaultLabelValues];
}



#pragma mark - Alert

- (void)noBarometerAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"No Barometer"
                                                                        message:@"This device doesn't have a barometer, so we can't track how high you're flying here. Sorry, Cap'm!"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Damn Technology!"
                                                     style:UIAlertActionStyleDefault handler:nil];
    
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - Methods

- (BOOL)checkBarometerAvailability {
    
    if (![CMAltimeter isRelativeAltitudeAvailable]) {
        [self noBarometerAlert];
        
        return NO;
    } else {
        return YES;
    }
}



- (void)defaultLabelValues {
    self.hintLabel.text = @"Press 'Pressure' to capture \nthe current air pressure";
    self.pressureOneLabel.text = nil;
    self.pressureTwoLabel.text = nil;
    self.relativeAltitudeLabel.text = nil;
    
    self.pressureOne = nil;
    self.pressureTwo = nil;
    self.relativeAltitude = nil;
}

- (void)updateLabels:(CMAltitudeData *)altitudeData {
    
    [self.altimeter stopRelativeAltitudeUpdates];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.maximumFractionDigits = 2;
    formatter.minimumIntegerDigits = 1;
    
    NSNumber *pressure = altitudeData.pressure;
    
    if(self.pressureOne == nil){
        self.pressureOne = pressure;
        self.pressureOneLabel.text = [NSString stringWithFormat:@"%@", pressure];
    } else if(self.pressureTwo == nil){
        self.pressureTwo = pressure;
        self.pressureTwoLabel.text = [NSString stringWithFormat:@"%@", pressure];
    }
    
    if(self.pressureOne != nil && self.pressureTwo != nil){
        self.relativeAltitude = [NSNumber numberWithDouble:((pow(self.pressureOne.doubleValue/self.pressureTwo.doubleValue,1/5.257)-1)*(18.0+273.15))/0.0065];
        self.relativeAltitudeLabel.text = [NSString stringWithFormat:@"%@", self.relativeAltitude];
    }
    
}

@end
