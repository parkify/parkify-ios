//
//  DirectionsControl.m
//  Parkify
//
//  Created by Me on 10/23/12.
//
//

#import "DirectionsControl.h"
#import "ExtraTypes.h"
#import "TBXML.h"


@interface DirectionsControl()

@property (strong, nonatomic) NSString* directionsString;
@property (weak, nonatomic) id<NameIdMappingDelegate> nameIdMapper;
@property int instructionCounter;

@end


@implementation DirectionsControl

@synthesize directionsString = _directionsString;
@synthesize nameIdMapper = _nameIdMapper;
@synthesize instructionCounter = _instructionCounter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withDirections:(NSString*)directionsString withResolutionDelegate:(id<NameIdMappingDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.nameIdMapper = delegate;
    self.directionsString = directionsString;
    self.instructionCounter = 0;
    return self;
}

- (NSString*)beginHtml {
    NSString* styleString = @"<style type='text/css'>"
    "body {background-color:transparent; font-family:'HelveticaNeue'; color:rgb(255,255,255);}"
    ".blue { color:rgb(97,189,250);}"
    ".stressed1 {font-family:'HelveticaNeue-Bold'; font-size:21px;}"
    ".stressed2 {font-family:'HelveticaNeue-Bold'; font-size:15px;}"
    ".stressed3 {font-family:'HelveticaNeue'; font-size:15px;}"
    ".smallspace {font-size:5;}"
    ".error {color:rgb(255,97,97);}"
    "img {border-width:4px; border-style:solid; border-color:rgb(97,189,250); float:left; width:150px; height:100px; margin-right:5px;}"
    ".direction {margin-top:7px; margin-bottom:3px;}"
    ".clearflt {clear:both;}"
    "</style>"
    ;
    return [NSString stringWithFormat:@"<!doctype html><HTML>"
                            "<HEAD>%@</HEAD>"
                            "<BODY>"
                            "<div id='content'>"
                            "<span class='stressed1 blue'>How to find your spot</span>"
                            "<br/>", styleString];
}

- (NSString*)endHtml {
    return @"</div><script>"
    /*
    
    "var animating = false;"
    
    "function do_change_size(elem) {"
    
    "    var width = elem.style.width;"
    
    "    function frame() {"
            "animating = true;"
    "        var increasing = img.getAttribute('size_changed');"
        
    
        
    "        if( increasing === 'true') {"
    "           width++;  // update parameters"
    "           elem.style.width = width + 'px'; // show frame"
    
    "           if (width >= 294) {  // check finish condition"
    "                   clearInterval(id);"
                        "animating = false;"
                        "window.location = 'yourscheme://callfunction/parameter1/parameter2?parameter3=value';"
                        
                "};"
            "} else {"
    "           width--;  // update parameters"
    "           elem.style.width = width + 'px'; // show frame"
                "if (width <= 150) {  // check finish condition"
    "                   clearInterval(id);"
                        "animating = false;"
                        "window.location = 'yourscheme://callfunction/parameter1/parameter2?parameter3=value';"
                "};"
            "};"
    
    "    };"
    
    "    var id = setInterval(frame, 10); // draw every 10ms"
    "};"

    "function change_size(x) {"
    
    
    "  var img = document.getElementById(x);"
    "  if(img.getAttribute('size_changed') === 'true')"
    "{"
    "  img.setAttribute('size_changed', 'false');"
    "} else {"
    "  img.setAttribute('size_changed', 'true');"
    "};"
    
    " if (animating === false)"
    "   do_change_size(img);"
    
    "};"
    "</script></BODY></HTML>";
    */
    
    "function change_size(x) {"
        "  var img = document.getElementById(x);"
        "  if(img.getAttribute('size_changed') === 'true')"
            "{"
            "  img.style.width = '150px';"
            "  img.style.height = '100px';"
            "  img.setAttribute('size_changed', 'false');"
            "} else {"
            "  img.style.width = '294px';"
            "  img.style.height = '197px';"
            "  img.setAttribute('size_changed', 'true');"
            "}"
            "window.location = 'yourscheme://callfunction/parameter1/parameter2?parameter3=value'"
            
        "};"
        "</script></BODY></HTML>";
     
}

- (NSString*)htmlForDirections {
    
    self.instructionCounter = 0;
    
    //READ IN STRING AS XML
    NSError *error;
    TBXML * tbxml = [[TBXML alloc] initWithXMLString:self.directionsString error:&error ];
    
    if (error) {
        NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
        return @"Sorry, something went wrong... contact Parkify for assistance.";
    } else {
        NSLog(@"%@", [TBXML elementName:tbxml.rootXMLElement]);
    }
    
    //TRAVERSE EACH DIRECTION (IF ANY)
    TBXMLElement * root = tbxml.rootXMLElement;
    NSString* midHtml = @"";
    if(root && root->firstChild) {
        midHtml = [self traverseDirections
                   :root->firstChild];
    }
    
   
    
    /*
    
    
    "<div class='direction'><img id=target src='%@'/>Text</div>"
                             
                             "</div>
                             styleString,
                             [NSString stringWithFormat:@"http://%@/images/%d?image_attachment=true&style=original", TARGET_SERVER, [[self.spot.imageIDs objectAtIndex:0] intValue]]];
    }


*/

    return [NSString stringWithFormat:@"%@%@%@",
        [self beginHtml],
        midHtml,
        [self endHtml]];

}

- (NSString*) traverseDirections:(TBXMLElement *)element {
    NSString* strToRtn = @"";
    do {
        if ([[TBXML elementName:element] isEqualToString:@"Direction"]) {
            strToRtn = [strToRtn stringByAppendingString:[self htmlForDirection:element]];
            self.instructionCounter++;
            
        }
    } while ((element = element->nextSibling));
    return strToRtn;
}

- (NSString*) htmlForDirection:(TBXMLElement *)element {
    
    //Extract any Image.
    NSString* imgTag = @"";
    
    TBXMLElement* img = [TBXML childElementNamed:@"Image" parentElement:element];
    if(img) {
        NSString* imgName = [TBXML valueOfAttributeNamed:@"name" forElement:img];
        if(imgName) {
            imgTag = [NSString stringWithFormat:@"<img id='target%d' src='%@'  onclick='change_size(\"target%d\")'/>",
                      self.instructionCounter,
                      [NSString stringWithFormat:@"http://%@/images/%d?image_attachment=true&style=original",
                       TARGET_SERVER,
                       [self.nameIdMapper idForName:imgName]],
                      self.instructionCounter];
        }
    }
    
    //Extract any Text.
    NSString* textStr = @"";
    TBXMLElement* text = [TBXML childElementNamed:@"Text" parentElement:element];
    if(text) {
        NSString * description = [TBXML textForElement:text];
        if(text) {
            textStr = description;
        }
    }
    
    NSString* toRtn = [NSString stringWithFormat:@"<div class='direction'>"
                       "%@"
                       "%@"
                       "<div class='clearflt'/></div>",
                       imgTag,
                       textStr]; 
    return toRtn;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
