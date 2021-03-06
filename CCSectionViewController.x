//
//  CCSectionViewController.x
//  CCLoader
//
//  Created by Jonas Gessner on 04.01.2014.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "CCSectionViewController.h"
#import "CCSectionView.h"

#import <objc/runtime.h>
#include <substrate.h>

@interface CCSectionViewController ()

- (void)setBundle:(NSBundle *)bundle;

- (void)setSection:(id <CCSection>)section;
- (id <CCSection>)section;

@end

%subclass CCSectionViewController : SBControlCenterSectionViewController <CCSectionDelegate>

%new
- (id)initWithBundle:(NSBundle *)bundle {
    self = [self init];
    if (self) {
        [self setBundle:bundle];
        [self setSection:[[[self.bundle principalClass] alloc] init]];
        
        if ([self.section respondsToSelector:@selector(setDelegate:)]) {
            [self.section setDelegate:self];
        }
    }
    return self;
}

%new
- (void)setBundle:(NSBundle *)bundle {
    objc_setAssociatedObject(self, @selector(bundle), bundle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (NSBundle *)bundle {
    return objc_getAssociatedObject(self, @selector(bundle));
}

%new
- (void)setSection:(id <CCSection>)section {
    objc_setAssociatedObject(self, @selector(section), section, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (id <CCSection>)section {
    return objc_getAssociatedObject(self, @selector(section));
}

- (void)loadView {
    UIView *contentView = [self.section view];
    
    self.view = [[%c(CCSectionView) alloc] initWithContentView:contentView];
}


- (void)controlCenterWillPresent {
    %orig;
    
    if ([self.section respondsToSelector:@selector(controlCenterWillAppear)]) {
        [self.section controlCenterWillAppear];
    }
}

- (void)controlCenterDidDismiss {
    %orig;
    
    if ([self.section respondsToSelector:@selector(controlCenterDidDisappear)]) {
        [self.section controlCenterDidDisappear];
    }
}



- (NSString *)sectionIdentifier {
    return [self.bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (NSString *)sectionName {
    return [self.bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}



%new
- (CGFloat)height {
    return [self.section sectionHeight];
}

- (BOOL)enabledForOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

- (CGSize)contentSizeForOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(CGFLOAT_MAX, self.height);
}



- (NSUInteger)hash {
    return [self.sectionIdentifier hash];
}

- (BOOL)isEqual:(id)other {
    if ([other isKindOfClass:%c(SBControlCenterSectionViewController)] && [other hash] == self.hash) {
        return YES;
    }
    return NO;
}

%end
