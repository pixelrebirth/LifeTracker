# LifeTracker
Personal Todo List App

# Notes
Reward
    CurrencyOptions
        ChronoTokens
            TimeEstimate
            Earned from Adding Tasklets/Rewardlets/Journlets/Habitlets
            Earned from Reading Time
            Earned from Automated Practice Module, Typing, Intervals, etc
        WillpowerTokens
            DopamineIndex
            Earned from Willpower IFTTT Button to do what is hard and difficult
            Earned from Struggle Switch turning off with Observation-Self and recommitment to values
            Earned from Meditation and Mindfulness
        TaskTokens
            TaskRequirement
            Earned from Closing Tasklets
            Earned from Writing Journlets [1pt per 2 words?]
            Earned from Doing Habitlets
            Earned from Marking Timelets [Used to document 15 minutes of time use every hour] <--- Use a toast in windows/text message.
    
    Elements
        Title:          40 Char
        TimeEstimate:   Fib. 1,2,3,5,8,13,21,34 (StaticCost)           - ChronoTokens
        DopamineIndex:  Fib. 1,2,3,5,8,13,21,34 (StaticCost)           - WillpowerTokens
        TaskRequirement:100 (DynamicCost)                              - TaskTokens
        
    Actions
        Reduce character Tokens by Cost
        Attack Boss with Cost
        If boss dies, generate a new one with Tasks remaining Priority as a guide and add BossTokens to character for later use


Boss
    Does daily damage to Dharma based on static % of tasks remaining Priority
    Next Boss is determined by remaining tasks Priority in queue

Character
    Name
    Class
    TaskTokens
    WillpowerTokens
    ChronoTokens
    BossTokens
    Dharma
    FinalFantasyMenu to Attack/Magic/Item

    

How does my not documenting time and tasks become bothersome, how can I make it obvious enough? Analytics are one way, and huge.
Database needs to have a simple transaction record with all LifeTracker events in it.

Can I somehow make the feeling of not updating upsetting --- making it a part of who I am -- making it part of my day to day.
I need to be addicted to documenting in this program, almost like a video game, how do video games become addictive..... 
scoring points and defeating foes

I need to make a MUD out of this... something just random and fun, dungeons, treasures, saved princesses, bosses, 
not a crafted story a random series of missions. This could be something I journal about. 

I need to incentivize learning more things by video and reading, think back to physics, astronomy, jets, I need to be that person again.
Finding inefficiencies in my day will be massively useful, particularly over long chunks of time.

My database will need to quickly stabalize or I will need to do more migrations as I move data from class change to class change.

Collectables are incentive to play a game, you could find parts to armor and weapons or something?
RPG Maker/Skyrim

Final Fantasy cmdlet style
-----
Read-Host Options? Keyboard Up/Down Options? Items? Magic? Weapons?

Melee
    Polearm
    Sabre
Magic
    Fire
    Fira
    Firaga
Special
    NinjaLazers
Items
    Potions
    Bombs

HP/MP/SP

Display will be the most tricky, menu selection options

Attack sequence with arrow keys UUDDLRLR to do menu actions, difficulty is based on current task metric. TYping "IjeuDkel" could be good way to do this too. Longer strings with more complex characters, you could also us a dictionary of words, or typing phrases from a book. These could be speed reading and speed typing exercises, speed read @200 wpm, retype <@40 wpm, this could be a variable based on LifeTracker increasing and decreasing combat efficiency in that you will make more mistakes and take more damage.

These mini games that determine damage in combat based on stats from LifeTracker can be modular and portable. We can make other mini games that slot in their place or maybe for different characters:
    Speed Reading
    Typing
    Interval Training
    Trivia
    Spelling
    Whatever



Item levels could be number of characters in a word you need to type, the faster you type it the more damage you do, accuracy is gated at 85% or miss and is variable based on accuracy and maybe time?

Enemies should attack us back, somehow-- Im not sure how at this time.
There could be a layer of 'effects' like final fantasy.... slow, haste, poison, etc

Could implement math facts? IQ tests? idk... plenty of shit we could do.

I love diablo esk item creation, final fantasy menu selection via keyboard/joystick binding, and needing to type or up/up/down/x/a/b.

Write in your own weapons, magic, items from pre-fabricated lists of items and ranks, like elder scrolls games

leather
glass
iron
steel
orc
elvish

where an item might be: Elven War Hammer of Lightning...

You could build a system like diablo where the abilities are added on and winning allows you to get experience that leads to skills... we could even directly model this after diablo since it is entirely just for me.
---
Tables, unfornately might be the only way. I will want to make this programmatically and take it from a csv I can generate from excel sheets. This will give me several different ways to maintain the data tables of the game. I definitely want to make the following tables.

Tables:

Weapons
Armor
Magic
Skills
Specials
Items

Everything takes one turn to use, these tables are level tables with % of generation.

I wonder if I can get some more on this. Id like a system of menus driven by keyboard input, (can I get joystick input?) up/down/left/right/sq/tr/cir/x. For a twist the story could be a choose your own adventure script.

I had an interesting idea about taking notes in a mindmap. I wonder if it is possible to take notes entirely in a mind map. Once I get internet back I am going to see if I can make that happen, it will take an online class from udemy or plurasight or youtube and just learn something while developing my mindmap agility.

Particularly if I can create a shortcut key quickness and be hands on at all times. The speed and efficiency at which I can write and document information both inbound and outbound the better. I might even be able to use that mind map like database-- the name escapes me (neo4j) but I might be able to look up graphing correlation database or something and find it. Id love to use that from docker or whatever. If I could get really good at that I may be able to map correlations between information very rapidly.

Can I somehow create a mindmap (maplets) integration with LifeTracker? Im not sure how that would work---- but there might be a way from an export or a mindmapping engine that is not dependant on xmind-- a file based on markdown possibly to make it easier? Make it like a journalet but stored and read differently... maybe count words and correlations for points in LifeTracker.

Defense could be active with quadrants of the screen interacting with letters on the keyboard. 

I want a game that teaches me how to type (Typelets). Maybe you need to type sentences from a fantasy story or something.. copy work at it's finest. This could be directly integrated with LifeTracker and give you some kind of Token (current preferably, created if necessary)

Maybe the game elements will correlate naturally when you use them

maybe--- maybe this is a better way to read? Could I integrate reading into LifeTracker? Fast-Reading certain books to build speed reading..that is really cool! I wonder if I can import a choose your own adventure book import? Call them Readlets

Could I create an AI that looks at correlations and asks simple word correlation questions.... Truck with Home = Rental for Junk Haul Tasklet Created ... this creates a Track -> Home correlation with a context Junk Hauling on the link. You skip a correlation if you cannot think of something within 10 seconds or something.

I will need to make a lot of notes within the system as well.
Neo4J like databases could be an instrumental part of this process of mindmapping effectively? it's an interesting idea anyway...

All metrics in the game will be based on LifeTracker.
Missions will be random encounters for the most part, but the story could expand and contract dynamically, say the linear pattern of the story has 20 stages, 10 on failure, 10 on success and the story receeds back and forth on failure and on success until completed. Could build expansion packs that add more scenarios to the blend.

RPG System
    Create a menu system of actions like FF but with direction and x/a/b/y
    Create proficiencies like baldurs gate on weapons and armor types
    Create weapon/armor model like diablo with abilities and names
    Create effects like FF, slow, haste, poison, stop, etc
    Create battle cadance and workflow, ie actions take typing/button combo
    Create reward system like diablo
    Create leveling workflow
    Create correlations with LifeTracker
    Have multiple characters like FF, each dealing same damage in different ways
    Create MP/SP/HP mechanism tied to LifeTracker somehow
    
Characters (Based on classic FF characters)
    BlackMage
    Fighter
    WhiteMage
    Rogue
    ...

Need to focus on the basic LifeTracker cycle before we can actually build this RPG game. Maybe the rewards are included in the RPG game rather than as a byproduct of the LifeTracker system directly. This would encourage playing the game, although it may discourage using the reward system.

The biggest bain of this system is simply taking rewards before earning them. This becomes tricky.

The GUI for the combat system will be difficult I believe as well.... have to consider the limitations on the powershell console.

To decouple the game from LifeTracker I need LifeTracker to simply have a Grant-Reward funciton of some sort I can shift around.
Id like to get the core pieces done and get rewards to work but in context of future development into a game. Abstracting the reward process may in fact be the only way to do this cleanly.

Master level distributes to characters like MTG? 

Analytics to do standard deviation of daily change to identify when I am on a strong or weak streak for alerting. This could be rewards taken vs data input where 0 is completely balanced, too many rewards is not enough work, too many tasks means under utilization of the reward system. This can be a 7 day rolling analytic and can be tied into notifications 

Embrace fibonacci and do math tests for how far in sequence before 5 minutes or 1 error occurs, you could also do multiples of 2 or 3 the same way

The ability to see patterns is a monumental difference between intelligent and non-intelligent analysis. This is to be proven.

Devops is about certain skills, packer, terraform, ansible, etc working in concert. In a new position of leadership I am going to offer everyone the list and have them choose, let them learn it in their own context. A tiger team is important as a target for people to get to. But everyone should be accountable for a single automation related yearly for review, no matter what level of IT--- automation is about saving our ass.

Timer happening ever 15th minute of the hour to see if you have added any timelets, penalty/reminders for missing it
# Game Loop
Area 10 start
    Do tasks to increase Dharma and Tokens
    Dharma increases attack and defense effectiveness (this is base level)
    Earn gold (needed to buy items in game) from defeating minions in interactive modular minigames ranked by Dharma
    Purchase items/equipment in game to defeat minions faster
    Must defeat minions to unluck stored Horded tokens
    Defeat Bosses by buying + using rewards with Horded tokens(no save for later)
    Advance Level
    
    or

    Regress Level because Boss beat you


# Timelet
[A 15 minute chunk of documented time]
Pull from previous items
Rewardlet style logging of information
New-
Add-

# Habitlet
[Positive or Negative Habits like Drinking Water, Exercise, Biting Nails]
Give Dharma everytime, grant tokens on positive, do nothing on negative
Analysis capable
Rewardlet style logging of information

# Journlet
[Journal Entries from life and work and love]
Transaction only database
Tokens on completion

# PlayerStats
[Build a Character Off of the Data]
Attack on taking rewards?
See above documentation on what that all means

# ConsolidateData
[Reduce Transaction Table by Summing All Columns and Rebuilding the Table]
OnMeasureCommand > 2000 milliseconds OR on >1000 records

Is there room for WANT vs NEED to be a guaging factor? Maybe WANTS cost rewards and NEEDS give TOKENS
I could write and algorithm that combines NEED gauge, WANT gauge and COMPLEXITY to create a Motivation quotient
(NEED+WANT) - COMPLEXITY = MOTIVATION

ex.
Working on John Shrudel
NEED: 5
WANT: 3
COMPLEXITY: 3
MOTIVATION = 5

Healthlet - A health tracker for whatever ---

https://www.bustle.com/life/11-weird-signs-your-body-might-not-tolerate-sugar-well-63401
Sugar, ask the 12 questions from the article and rate on fib.

Pain, track the kinds of pain in fib

Create a scheduler that runs a sum on the LifeTracker and stores it in a table, do this every {{ 4 }} hours
This can be used for analytics and AI to warn of behaviors and send action items

It is the baseline analytics that should drive the multipliers of the TransactionRatio set in the config
Ratio has 5 attributes each token, 1, 2, 3, 4, and 5 in the config file, no more no less

RestAPI portion should be installed during INSTALL and be highly abstracted to JSON Blob. I dont want to edit code every time I need a new API call--
THIS IS JUST FOR ME! I DO NOT WANT TO DISTRIBUTE THIS INSECURE POS WORK

Rewardlet Elements
---
Touch
Taste
Hearing
Sight
Smelling
Time

Take a hit
Touch: 1 (WillpowerToken)
Taste: 2 (TaskToken)
Hear:  0 (WillpowerToken)
Smell: 1 (TaskToken)
Sight: 2 (WillpowerToken)
Time:  3 (ChronoToken)

IFTTT a MUST for rewards to be useful

Step 1, create dopamine/senses based Rewardlet
Step 2, create API endpoint for IFTTT
Step 3, register IFTTT to API for each reward
Step 4, create analytics for checking trends
Step 5, gamify the rewards to 'deal damage' to 'boss' for 'bosstoken'
Step 6, create 'bosstoken' high end rewards

I should make a speedreading game where it has you type sentences from a book you want to read. Sentence pops up, `read-host | measure-command` ; you must type it correctly. Increase your time

All gamification bonuses need to be based on standard deviation of reward vs tasking metrics.

These include the following:
    +-(Reward - Tasking)(stddev) 3,5,8,13,21,34,55,89.... days per category of token

Tartus Mapping CODE Page
1. 

Timelet is marked when doing something worth doing time for, if you assume all good time is marked, you can assume the bad time--- while this might not be the strongest of analytics, it is in fact data to be evaluated

All timelets should be things we want to be doing, specfic things, not `work`, `IaC Policy Writing`