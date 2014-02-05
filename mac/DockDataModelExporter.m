#import "DockDataModelExporter.h"

@interface DockDataModelExporter ()
@property (strong, nonatomic) NSManagedObjectContext* context;
@property (strong, nonatomic) NSString* sourcePath;
@property (strong, nonatomic) NSString* packageName;
@end

@implementation DockDataModelExporter

-(id)initWithContext:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self != nil) {
        _context = context;
        _packageName = @"com.funnyhatsoftware.spacedock";
    }
    return self;
}

/*
    NSInteger32AttributeType = 200,
    NSInteger64AttributeType = 300,
    NSDecimalAttributeType = 400,
    NSDoubleAttributeType = 500,
    NSFloatAttributeType = 600,
    NSStringAttributeType = 700,
    NSBooleanAttributeType = 800,
    NSDateAttributeType = 900,
    NSBinaryDataAttributeType = 1000
*/
static NSString* attributeTypeToJavaType(NSAttributeType attrType)
{
    switch (attrType) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            return @"int";
            break;
            
        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
            return @"double";
            break;
            
        case NSBooleanAttributeType:
            return @"boolean";
            break;
            
        case NSDateAttributeType:
            return @"Date";
            break;
            
        case NSStringAttributeType:
            return @"String";
            break;
    }
    return @"void";
}

static NSString* entityNameToJavaClassName(NSString* entityName)
{
    return entityName;
}

-(BOOL)exportEntity:(NSString*)name error:(NSError**)error
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: name inManagedObjectContext: _context];
    NSEntityDescription* parent = [entity superentity];
    NSMutableString* javaClass = [[NSMutableString alloc] init];
    NSSet* parentAttributes = nil;
    NSSet* parentRelationships = nil;
    if (parent) {
        parentAttributes = [NSSet setWithArray: [[parent attributesByName] allKeys]];
        parentRelationships = [NSSet setWithArray: [[parent relationshipsByName] allKeys]];
        [javaClass appendFormat: @"class %@ extends %@ {\n", entityNameToJavaClassName(name), entityNameToJavaClassName(parent.name)];
    } else {
        [javaClass appendFormat: @"class %@ {\n", entityNameToJavaClassName(name)];
    }
    for (NSAttributeDescription* desc in [entity.attributesByName allValues]) {
        if (![parentAttributes containsObject: desc.name]) {
            [javaClass appendFormat: @"\t%@ %@;\n", attributeTypeToJavaType(desc.attributeType), desc.name];
        }
    }
    
    BOOL needsArrayList = NO;
    
    for (NSRelationshipDescription* desc in [entity.relationshipsByName allValues]) {
        if (![parentRelationships containsObject: desc.name]) {
            if (desc.isToMany) {
                NSString* destClassName = entityNameToJavaClassName(desc.destinationEntity.name);
                NSString* typeName = [NSString stringWithFormat: @"ArrayList<%@>", destClassName];
                needsArrayList = YES;
                [javaClass appendFormat: @"\t%@ %@ = new %@();\n", typeName, desc.name, typeName];
            } else {
                [javaClass appendFormat: @"\t%@ %@;\n", entityNameToJavaClassName(desc.destinationEntity.name), desc.name];
            }
        }
    }
    [javaClass appendString: @"}\n"];
    NSString* sourceFileName = [NSString stringWithFormat: @"%@.java", entityNameToJavaClassName(name)];
    NSString* classFilePath = [_sourcePath stringByAppendingPathComponent: sourceFileName];
    NSMutableString* js = [[NSMutableString alloc] init];
    [js appendFormat: @"package %@;\n\n", _packageName];
    if (needsArrayList) {
        [js appendString: @"import java.util.ArrayList;\n\n"];
    }
    [js appendString: javaClass];
    return [js writeToFile: classFilePath atomically: NO encoding: NSUTF8StringEncoding error: error];
}

-(BOOL)doExport:(NSString*)targetFolder error:(NSError**)error
{
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL exists = [fm fileExistsAtPath: targetFolder isDirectory: &isDir];
    if (!exists) {
        BOOL created = [fm createDirectoryAtPath: targetFolder withIntermediateDirectories: YES attributes: @{} error: error];
        if (!created) {
            return NO;
        }
    }
    NSString* sourcePartialPath = [_packageName stringByReplacingOccurrencesOfString: @"." withString: @"/"];
    _sourcePath = [targetFolder stringByAppendingPathComponent: sourcePartialPath];
    exists = [fm fileExistsAtPath: _sourcePath isDirectory: &isDir];
    if (!exists) {
        BOOL created = [fm createDirectoryAtPath: _sourcePath withIntermediateDirectories: YES attributes: @{} error: error];
        if (!created) {
            return NO;
        }
    }
    NSManagedObjectModel *managedObjectModel = [[_context persistentStoreCoordinator] managedObjectModel];
    NSArray* entities = managedObjectModel.entities;
    for (NSEntityDescription* desc in entities) {
        if (![self exportEntity: desc.name error: error]) {
            return NO;
        }
    }
    return YES;
}

@end
