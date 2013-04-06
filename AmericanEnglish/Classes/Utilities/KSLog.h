/*
 *  KSLog.h
 *  AmericanEnglish
 *
 *  Created by kesalin on 7/19/11.
 *  Copyright 2011 kesalin@gmail.com. All rights reserved.
 *
 */

#ifndef __KSLOG_H__
#define __KSLOG_H__


#ifdef KSDEBUG
#define KSLog(format, ...) NSLog(format", file:%s, line:%d, function:%s.", ##__VA_ARGS__, __FILE__, __LINE__, __FUNCTION__)
#define KSTrace(format, ...) NSLog(@"--- %s "format"---", __FUNCTION__, ##__VA_ARGS__)
#else
#define KSLog(format, ...)
#define KSTrace(format, ...)
#endif

#endif //__KSLOG_H__