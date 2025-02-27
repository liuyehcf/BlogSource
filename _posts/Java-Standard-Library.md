---
title: Java-Standard-Library
date: 2018-01-21 10:19:23
tags: 
- 摘录
categories: 
- Java
---

**阅读更多**

<!--more-->

# 1 java.time

## 1.1 Time Related Types

![time_types](/images/Java-Standard-Library/time_types.png)

* `Instance`: Represents a specific point in time on the UTC timeline (Coordinated Universal Time). It is often used for timestamps.
* `LocalDateTime`: Represents a date and time without a timezone. It is used for storing date and time information in a local context.
* `ZonedDateTime`: Represents a date and time with a timezone. It is used for storing date-time information that is associated with a specific timezone.

## 1.2 Parse time with local time zone and transfer to UTC timestamp

```java
String dateTimeStr = "2024-08-01 13:34:56";
LocalDateTime localDateTime = LocalDateTime.parse(dateTimeStr, java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

ZoneId currentZoneId = ZoneId.systemDefault();

ZonedDateTime zonedDateTime = localDateTime.atZone(currentZoneId);

Instant utcInstant = zonedDateTime.toInstant();
long utcTimestamp = utcInstant.getEpochSecond();
```

## 1.3 Parse UTC timestamp and transfer to time with local time zone

```java
long utcTimestamp = 1722490496L;

Instant utcInstant = Instant.ofEpochSecond(utcTimestamp);

ZoneId currentZoneId = ZoneId.systemDefault();

LocalDateTime localDateTime = LocalDateTime.ofInstant(utcInstant, currentZoneId);

DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
String formattedDateTime = localDateTime.format(formatter);
```

## 1.4 Transform between UTC and Local DateTime

```java
public static LocalDateTime normalizeToUTC(LocalDateTime localZonedDateTime) {
    Instant instant = localZonedDateTime.atZone(ZoneId.systemDefault()).toInstant();
    return LocalDateTime.ofInstant(instant, ZONE_UTC);
}

public static LocalDateTime localizeFromUTC(LocalDateTime utcDateTime) {
    Instant instant = utcDateTime.atZone(ZONE_UTC).toInstant();
    return LocalDateTime.ofInstant(instant, ZoneId.systemDefault());
}
```

## 1.5 Get Time offset

```java
ZoneOffset offset = ZonedDateTime.now(ZoneId.systemDefault()).getOffset();
```

## 1.6 Default timezone config load order

The priorities from high to low:

* `-Duser.timezone`: Jvm option
    * `java -Duser.timezone=America/New_York -jar yourApp.jar`
* `TZ`: Env
    * `export TZ=Asia/Tokyo`
* `/etc/timezone`
* `/etc/localtime`
