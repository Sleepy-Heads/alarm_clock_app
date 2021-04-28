Original App Design Project - README Template
===

# Alarm Clock App (Name Pending)

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
An alarm clock app that requires a puzzle or math problem to turn it off. The purpose of this app is to wake the brain up a bit so you don't just hit snooze and go back to bed.

### App Evaluation
- **Category:** Productivity / Lifestyle / Health & Fitness
- **Mobile:** Mobile is essential for the location feature. App uses audio from alarm, and the camera
- **Story:** Tries to enable users to wake up more effectively
- **Market:** Anyone, especially those who have trouble waking up (sleepy heads)
- **Habit:** Daily at least, can be used multiple times a day (for those who take naps) 
- **Scope:** Small scope, initially trying to create simple ways (ex. math problems, simple puzzles) to turn off the alarm. Can become larger (ex. movement based, qr codes)

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

[ ] User can click "create an alarm"
[ ] User can create alarm
[ ] User can view their alarms
[ ] User can toggle alarm on or off
[ ] User can choose the puzzle and level of difficulty
[ ] User gets alarm pop-up, telling them to solve puzzle
[ ] User can edit their settings
[ ] User can solve the puzzle in order to turn off the alarm

**Optional Nice-to-have Stories**

* User can create account
* User can log in
* User can log out
* User can track sleep
* User can set a sleep schedule
* User can take pictures of QR codes
* User can walk a certain distance to turn off alarm
* User can select app theme (ex. light or dark mode)

### 2. Screen Archetypes

* Stream
   * User can click "create an alarm"
   * User can view their alarms
   * User can toggle alarm on or off
   * User gets alarm pop-up, telling them to solve puzzle
   
* Detail
   * User can create alarm
   * User can choose the puzzle and level of difficulty

* Detail
   * User can solve the puzzle in order to turn off the alarm

* Settings
   * User can edit their settings

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home - where the alarms live

**Flow Navigation** (Screen to Screen)

* Home Screen
   * Settings
   * Alarm Detail

* Alarm Notification Screen
   * Puzzle screen

* Puzzle screen
   * Home Screen


## Wireframes
![Imgur Image](https://i.imgur.com/3MXUtvC.png)

### [BONUS] Digital Wireframes & Mockups
<img src="https://media.discordapp.net/attachments/830466340887330816/830518532873125898/8951376c8780d1d529fc7c1ef2920fc2.png" width=400>

### [BONUS] Interactive Prototype
<img src='http://g.recordit.co/071Mwnjz57.gif' width='' alt='Interactive Prototype' />


## Schema 

### Models

#### Alarm

Property  | Type | Description
------------ | ------- | --------------|
name | String | The name for the alarm
time | DateTime | The time for the alarm to go off
flicker | Boolean | Whether an alarm is on or off
repeat | Array of Booleans | Whether to repeat the alarm and on what days
puzzle | Pointer to Puzzle | Type of puzzle user wants to solve
edit | Boolean | Whether we are on the edit page or not


#### Puzzle

Property  | Type | Description
------------ | ------- | --------------|
type | Array | What type of puzzle they will solve
difficulty | Array | What difficulty the puzzle will be

### Networking
* Home Screen
* Edit Alarm Screen
* Solve Alarm Screen
   * (Read/GET) Query one math equation where the difficulty is the same as alarms and the answer to the math equation
  ```swift
  let query = PFQuery(className:"MathEquation")
  query.whereKey("difficulty", equalTo: currentDifficulty)
  query.findObjectsInBackground { (mathequations: [PFObject]?, error: Error?) in
      if let error = error {
          // Log details of the failure
          print(error.localizedDescription)
      } else if let mathequations = mathequations {
          print("Successfully retrieved \(mathequations.question) and \(mathequations.answer).")
          // TODO: Do something with math equations
      }
  }
  ```
* Settings Screen


