---
title: Hacksmiths - iOS App Specs
layout: project
author: Ryan Collins
permalink: /hacksmiths---ios-app-specs/
source-id: 1C-JAW75z8HA9AM8HyPurqMtXgK2VNwODwLmZ3DZyKyY
published: true
---
** **

**Hacksmiths App**

Implement an application for the iOS Platform that reads data from the Hacksmiths API.

### Prepared for

**    Development Team**

# **Overview: HackSmiths iOS App**

Rapidly design and implement prototypes for the Hacksmiths iOS app. The project will run with the following details:

## **Project 1**

* 3 sprints total

* Start: Saturday, Feb 6, 2016

* End: Sunday, Feb 28,  2016

## **Request - Current vs. Future State**

### Ryan Collins

*P1) iOS Hackmiths App*

*- What we have: We have the start of an API that serves endpoint data for the purposes of the Hacksmiths iOS Hackathon Coordinator App.*

*- What we need: We need an iOS app that consumes the endpoint data, showing a TabBar with various views.  The views should show as described below.  The app will allow any member of the Hacksmiths or guest to login to the Hacksmiths site, register for an account, or continue to view info as a Guest without signing in or registering.  *

*If viewing as a guest, the user will see 3 icons in the tabbar: Event, Info Community*

*If viewing as a member, the user will see an additional icon called Me and additionally, an Upcoming Events Tab.*

**_Sprint 1 - Due 2/18/2016: _**

*Build the app with working models, views and controllers.  Hook up the API.  Show that the app works, but focus on design later.  Have a functioning app to submit for Capstone and review in the App Store.*

**_Sprint 2 - Due 2/28/2016:_****_ _**

# *Work with design team on a total overhaul to match branding and deliver a polished product*

**_Sprint 3 - Due TBA:_**

*TBA*

# **Project Description**

## **iOS App - Hacksmiths**

* Able to login and manage your HackSmiths account, see events and RSVP.

* Runs on iOS 9+ for iPhone 5S+.

* Contains a profile section, an Event Section, Upcoming Events,  an Info Section and a Community Section.

* Shows data in a Table View for the Upcoming Events, Community, etc.  The Me and Event sections are custom designed and are fed from Network Data that we can update via the API.

* The API is build with NodeJS, running on the MEAN (or similar) stack on Digitial Ocean.

## **Design Specifications **

* Need an iOS icon created for all sized devices

* Need square and horizontal icons (font based & black for use as icons)

* Need icons and color scheme

* Design of event page for app and website

* Marketting material, branding, etc. for event and Info sections

## **Demos / Mockups**

* Put links to demos / mockups here

## **Sample Architecture**

## **Technical Considerations/Restrictions**

* Should run on any iOS Device (5S+)

* Detailed build instructions and release schedule from Day 1

* The app will use a custom built API client that will make requests to Localhost while in development.  it should ship with a test API so anyone can run this locally before the server is launched.

* The app will use Core Data for data persistence (See below)

* The app will have several custom classes (See below)

**Models**

* **Event**

* **Account**

* **Organization**

* **Person**

* **RSVP**

* **Schedule**

**Sample "Event" Object**

class Event {

    id: String

    title: String

    info: String

    date: Date;

    people: [Person]

}

**Other Models**

RSVP

Person

Etc.

## **Specification**

A sketched out spec goes here

### Capture Flow

1. App launches to Event page (center icon in tab bar)

2. User has option to login, or continue as guest (non obtrusive)

3. User can RSVP (sign up for event) from several areas once signed in

    * Me section

    * Event section

4. User / guest can see the people who are a part of the event in the Community section

    * Organizers are first

    * Team leaders

    * Other event participants

    * Other community members

5. Logic for showing the next Event will be as follows

    * The main event page will show the next chronological event

    * Below that is a UITableView with the next upcoming events

    * Drilling down into an event will show info about that event and allow for signup

    * Text changes from "Are you coming?" to “See you there!” after an RSVP

### Technical Flow

Super simple and easy to edit going forward.  For Sprint 1, we will want to keep it simple so that I can turn it into Udacity.  For the next two sprints, we will do total redesigns.

### Misc.  Facts

## **Device/Platform**

* iPhone 5S+, iOS 9.0+

## **Target Completion**

* ASAP:  3 weeks from start, February  25, 2016. 

* Release iterations as they become available - speed is important.

## **Team**

* Developer: Ryan Collins

* Designer: Sean Craig (Sprint 2 & 3)

