#import "DockDataModelExporter.h"

@interface DockDataModelExporter ()
@property (strong, nonatomic) NSManagedObjectContext* context;
@property (strong, nonatomic) NSString* sourcePath;
@property (strong, nonatomic) NSString* packageName;
@property (strong, nonatomic) NSString* packageNameData;
@end

@implementation DockDataModelExporter

-(id)initWithContext:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self != nil) {
        _context = context;
        _packageName = @"com.funnyhatsoftware.spacedock";
        _packageNameData = [_packageName stringByAppendingString: @".data"];
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
        
        default:
            return @"void";
    }
    return @"void";
}

static NSString* attributeTypeToJavaConversion(NSAttributeType attrType)
{
    switch (attrType) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            return @"DataUtils.intValue";
            
        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
            return @"DataUtils.doubleValue";
            
        case NSBooleanAttributeType:
            return @"DataUtils.booleanValue";
            
        case NSDateAttributeType:
            return @"DataUtils.dateValue";
            
        case NSStringAttributeType:
            return @"DataUtils.stringValue";
            
        default:
            return @"";
    }
    return @"";
}

static NSString* attributeTypeToJavaComparison(NSAttributeType attrType, NSString* lhs, NSString* rhs)
{
    switch (attrType) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
        case NSBooleanAttributeType:
            return [NSString stringWithFormat: @"%@ != %@", lhs, rhs];
            
        case NSDateAttributeType:
        case NSStringAttributeType:
            return [NSString stringWithFormat: @"!DataUtils.compareObjects(%@, %@)", lhs, rhs];
            
        default:
            return @"false";
    }
    return @"false";
}

static NSString* entityNameToJavaClassName(NSString* entityName)
{
    return entityName;
}

static NSString* propertyNameToJavaGetterName(NSString* propertyName)
{
    NSString* upperFirst = [[propertyName substringToIndex: 1] uppercaseString];
    NSString* rest = [propertyName substringFromIndex: 1];
    return [@"get" stringByAppendingString: [upperFirst stringByAppendingString: rest]];
}

static NSString* propertyNameToJavaSetterName(NSString* propertyName)
{
    NSString* upperFirst = [[propertyName substringToIndex: 1] uppercaseString];
    NSString* rest = [propertyName substringFromIndex: 1];
    return [@"set" stringByAppendingString: [upperFirst stringByAppendingString: rest]];
}

static NSString* propertyNameToJavaInstanceName(NSString* propertyName)
{
    NSString* upperFirst = [[propertyName substringToIndex: 1] uppercaseString];
    NSString* rest = [propertyName substringFromIndex: 1];
    return [@"m" stringByAppendingString: [upperFirst stringByAppendingString: rest]];
}

static NSString* entityNameToJavaBaseClassName(NSString* entityName)
{
    return [entityNameToJavaClassName(entityName) stringByAppendingString: @"Base"];
}

static NSString* makeXmlKey(NSString* propertyName, NSString* entityName)
{
    if ([propertyName isEqualToString: @"externalId"]) {
        if ([entityName isEqualToString: @"Set"]) {
            return @"id";
        }
        return @"Id";
    }
    if ([propertyName isEqualToString: @"battleStations"]) {
        return @"Battlestations";
    }
    if ([propertyName isEqualToString: @"upType"]) {
        return @"Type";
    }

    NSString* upperFirst = [[propertyName substringToIndex: 1] uppercaseString];
    NSString* rest = [propertyName substringFromIndex: 1];
    return [upperFirst stringByAppendingString: rest];
}

void emitCastToTarget(NSString *javaClassName, NSMutableString *javaClass)
{
    [javaClass appendFormat: @"        %@ target = (%@)obj;\n", javaClassName, javaClassName];
}

-(BOOL)exportEntity:(NSString*)name error:(NSError**)error
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: name inManagedObjectContext: _context];
    NSEntityDescription* parent = [entity superentity];
    NSMutableString* javaClass = [[NSMutableString alloc] init];
    NSSet* parentAttributes = nil;
    NSSet* parentRelationships = nil;
    NSString* javaBaseClassName = entityNameToJavaBaseClassName(name);
    NSString* javaClassName = entityNameToJavaClassName(name);
    NSString* abstractString = @"";
    if (entity.isAbstract) {
        abstractString = @"abstract ";
    }
    if (parent) {
        parentAttributes = [NSSet setWithArray: [[parent attributesByName] allKeys]];
        parentRelationships = [NSSet setWithArray: [[parent relationshipsByName] allKeys]];
        [javaClass appendFormat: @"public %@class %@ extends %@ {\n", abstractString, javaBaseClassName, entityNameToJavaClassName(parent.name)];
    } else {
        [javaClass appendFormat: @"public %@class %@ extends Base {\n", abstractString, javaBaseClassName];
    }

    BOOL needsDate = NO;

    for (NSAttributeDescription* desc in [entity.attributesByName allValues]) {
        if (![parentAttributes containsObject: desc.name]) {
            NSString* instanceName = propertyNameToJavaInstanceName(desc.name);
            if (desc.attributeType == NSDateAttributeType) {
                needsDate = YES;
            }
            [javaClass appendFormat: @"    %@ %@;\n", attributeTypeToJavaType(desc.attributeType), instanceName];
            [javaClass appendFormat: @"    public %@ %@() { return %@; }\n",
                attributeTypeToJavaType(desc.attributeType), propertyNameToJavaGetterName(desc.name), instanceName];
            [javaClass appendFormat: @"    public %@ %@(%@ v) { %@ = v; return this;}\n",
                javaBaseClassName, propertyNameToJavaSetterName(desc.name), attributeTypeToJavaType(desc.attributeType), instanceName];
        }
    }
    
    BOOL needsArrayList = NO;
    
    for (NSRelationshipDescription* desc in [entity.relationshipsByName allValues]) {
        if (![parentRelationships containsObject: desc.name]) {
            NSString* instanceName = propertyNameToJavaInstanceName(desc.name);
            if (desc.isToMany) {
                NSString* destClassName = entityNameToJavaClassName(desc.destinationEntity.name);
                NSString* typeName = [NSString stringWithFormat: @"ArrayList<%@>", destClassName];
                needsArrayList = YES;
                [javaClass appendFormat: @"    %@ %@ = new %@();\n", typeName, instanceName, typeName];
                [javaClass appendString: @"    @SuppressWarnings(\"unchecked\")\n"];
                [javaClass appendFormat: @"    public %@ %@() { return (%@)%@.clone(); }\n",
                    typeName, propertyNameToJavaGetterName(desc.name), typeName, instanceName];
                [javaClass appendString: @"    @SuppressWarnings(\"unchecked\")\n"];
                [javaClass appendFormat: @"    public %@ %@(%@ v) { %@ = (%@)v.clone(); return this;}\n",
                    javaBaseClassName, propertyNameToJavaSetterName(desc.name), typeName, instanceName, typeName];
            } else {
                [javaClass appendFormat: @"    %@ %@;\n", entityNameToJavaClassName(desc.destinationEntity.name), instanceName];
                [javaClass appendFormat: @"    public %@ %@() { return %@; }\n",
                    entityNameToJavaClassName(desc.destinationEntity.name), propertyNameToJavaGetterName(desc.name), instanceName];
                [javaClass appendFormat: @"    public %@ %@(%@ v) { %@ = v; return this;}\n",
                    javaBaseClassName, propertyNameToJavaSetterName(desc.name),
                    entityNameToJavaClassName(desc.destinationEntity.name), instanceName];
            }
        }
    }
    
    // update
    [javaClass appendString: @"\n    public void update(Map<String,Object> data) {\n"];
    if (parent) {
        [javaClass appendString: @"        super.update(data);\n"];
    }
    for (NSAttributeDescription* desc in [entity.attributesByName allValues]) {
        NSString* instanceName = propertyNameToJavaInstanceName(desc.name);
        if (![parentAttributes containsObject: desc.name]) {
            NSString* attributeName = desc.name;
            if ([name isEqualToString: @"Maneuver"]) {
                attributeName = [attributeName lowercaseString];
            } else {
                attributeName = makeXmlKey(desc.name, name);
            }
            NSAttributeType attrType = desc.attributeType;
            switch (attrType) {
                case NSInteger16AttributeType:
                case NSInteger32AttributeType:
                case NSInteger64AttributeType:
                    [javaClass appendFormat: @"        %@ = %@((String)data.get(\"%@\"), %d);\n",
                     instanceName, attributeTypeToJavaConversion(desc.attributeType), attributeName, [desc.defaultValue intValue]];
                    
                    break;
                    
                case NSStringAttributeType:
                    [javaClass appendFormat: @"        %@ = %@((String)data.get(\"%@\"), \"%@\");\n",
                     instanceName, attributeTypeToJavaConversion(desc.attributeType), attributeName, [desc.defaultValue stringValue]];
                     break;
                default:
                    [javaClass appendFormat: @"        %@ = %@((String)data.get(\"%@\"));\n",
                     instanceName, attributeTypeToJavaConversion(desc.attributeType), attributeName];
                    break;
            }
        }
    }
    [javaClass appendString: @"    }\n\n"];

#if 0
    // equals
    [javaClass appendString: @"\n    public boolean equals(Object obj) {\n"];
    
    [javaClass appendString: @"        if (obj == null)\n"];
    [javaClass appendString: @"            return false;\n"];
    [javaClass appendString: @"        if (obj == this)\n"];
    [javaClass appendString: @"            return false;\n"];
    [javaClass appendFormat: @"        if (!(obj instanceof %@))\n", javaClassName];
    [javaClass appendString: @"            return false;\n"];
    
    BOOL emittedCast = NO;

    for (NSAttributeDescription* desc in [entity.attributesByName allValues]) {
        //NSString* instanceName = propertyNameToJavaInstanceName(desc.name);
        if (![parentAttributes containsObject: desc.name]) {
            if (!emittedCast) {
                emitCastToTarget(javaClassName, javaClass);
                emittedCast = YES;
            }
            
            NSString* instanceName = propertyNameToJavaInstanceName(desc.name);
            NSString* targetInstanceName = [@"target." stringByAppendingString: instanceName];
            [javaClass appendFormat: @"        if (%@)\n", attributeTypeToJavaComparison(desc.attributeType, targetInstanceName, instanceName)];
            [javaClass appendString: @"            return false;\n"];
        }
    }

    for (NSRelationshipDescription* desc in [entity.relationshipsByName allValues]) {
        if (![parentRelationships containsObject: desc.name]) {
            if (!emittedCast) {
                emitCastToTarget(javaClassName, javaClass);
                emittedCast = YES;
            }
            NSString* instanceName = propertyNameToJavaInstanceName(desc.name);
            NSString* targetInstanceName = [@"target." stringByAppendingString: instanceName];
            [javaClass appendFormat: @"        if (!DataUtils.compareObjects(%@, %@))\n", instanceName, targetInstanceName];
            [javaClass appendString: @"            return false;\n"];
        }
    }

    [javaClass appendString: @"        return true;\n"];
    [javaClass appendString: @"    }\n\n"];
#endif

    [javaClass appendString: @"}\n"];
    NSString* baseSourceFileName = [NSString stringWithFormat: @"%@.java", javaBaseClassName];
    NSString* baseClassFilePath = [_sourcePath stringByAppendingPathComponent: baseSourceFileName];
    NSString* sourceFileName = [NSString stringWithFormat: @"%@.java", javaClassName];
    NSString* classFilePath = [_sourcePath stringByAppendingPathComponent: sourceFileName];
    NSMutableString* js = [[NSMutableString alloc] init];
    [js appendString: @"// Generated code, any edits will be eventually lost.\n"];
    [js appendFormat: @"package %@;\n\n", _packageNameData];
    if (needsArrayList) {
        [js appendString: @"import java.util.ArrayList;\n"];
    }
    if (needsDate) {
        [js appendString: @"import java.util.Date;\n"];
    }
    [js appendString: @"import java.util.Map;\n\n"];

    [js appendString: javaClass];

    if (![js writeToFile: baseClassFilePath atomically: NO encoding: NSUTF8StringEncoding error: error]) {
        return NO;
    }
    
    BOOL isDir;
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath: classFilePath isDirectory: &isDir]) {
        NSMutableString* jsConc = [[NSMutableString alloc] init];
        [jsConc appendFormat: @"package %@;\n\n", _packageNameData];
        [jsConc appendFormat: @"public class %@ extends %@ {\n", javaClassName, javaBaseClassName];
        [jsConc appendString: @"}\n"];
        if (![jsConc writeToFile: classFilePath atomically: NO encoding: NSUTF8StringEncoding error: error]) {
            return NO;
        }
    }
    
    return YES;
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
    NSString* sourcePartialPath = [_packageNameData stringByReplacingOccurrencesOfString: @"." withString: @"/"];
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
