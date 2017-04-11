// Copyright 2015 InteraXon, Inc.

#import <Foundation/Foundation.h>
#import "Muse/api/IXNMuseFile.h"
#import "Muse/api/IXNMuseFileReader.h"
#import "Muse/api/IXNMuseFileWriter.h"

/**
 * Creates IXNMuseFileWriter, IXNMuseFileReader and IXNMuseFile objects.
 */
@interface IXNMuseFileFactory : NSObject

/**
 * Creates and returns IXNMuseFileWriter object based on provided path.
 * Interaxon's IXNMuseFile implementation is used in this case.
 * \param filePath The path of the file to write.
 * \return IXNMuseFileWriter
 */
+ (IXNMuseFileWriter *)museFileWriterWithPathString:(NSString*)filePath;

/**
 * Creates and returns IXNMuseFileReader object based on provided path.
 * Interaxon's IXNMuseFile implementation is used in this case.
 * \param filePath The path of the file to read.
 * \return IXNMuseFileReader
 */
+ (IXNMuseFileReader *)museFileReaderWithPathString:(NSString*)filePath;

/**
 * Returns a IXNMuseFile object, which uses Interaxon's implementation
 * \param filePath The path of the file.
 * \return IXNMuseFile
 */
+ (id<IXNMuseFile>)museFileWithPathString:(NSString*)filePath;

@end
