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
#define KSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define KSLog(format, ...)
#endif

#endif //__KSLOG_H__