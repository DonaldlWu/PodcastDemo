About this app
---

# Product Target

Parsing RSS Feed data to present a Podcast epsiodes list ,description and have a player to play podcast audio file in iOS device.

> In here using [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer) to handle epsiode download from url and play the audio.

# Tasks

Separate the feature to three part

1. A list to present all epsiode.

2. A page with detail information of current epsiode.

3. A page with player to play epsiode.

# Design level

1. List view

    - A header with podcast image

    - A List with epsiodes(contain: image, epsiode title, pubDate)

    - Refresh to reload RSS feed

    - Show description page

2. Description

    - A header with current epsiode image.

    - A section of text to display description of current epsiode.

    - Show player page

3. Player

    - A player to play/pause audio.

    - A slider to control progress.

    - Handle next epsiode when have newer epsiode.

# Tools

Third part framework

- [Kinfisher](https://github.com/onevcat/Kingfisher) for image download and cache.

- [XMLCoder](https://github.com/CoreOffice/XMLCoder) for XML data parsing.

- UIKit and programming UI layout.

# Implementation

## Code typesetting

- UIKit related: 
    
    UI Conponment

    Key feature

    UILayout

## EpsiodeListViewController

	                                                 ┌─────────────┐        
	                                                 │  RSSLoader  │        
	                                                 └─────────────┘        
	                                                        ▲               
	                                                        │               
	                                                        │               
	┌────────────────────────────┐                          │               
	│ EpsiodeListFeatureComposer ├ ─ ─                      │               
	└────────────────────────────┘    │                     │               
	               │                Creation                │               
	                                  │                     │               
	               │                         ┌─────────────────────────────┐
	                                  └ ─ ─ ▶│  ListRefreshViewController  │
	               │                         └─────────────────────────────┘
	┌──────────────▼──────────────┐                         ▲               
	│  EpsiodeListViewController  │─────────────────────────┘               
	└──────────────┬──────────────┘────┐                                    
	               │                   │                                    
	               │                   │                                    
	               ▼                   │                                    
	┌─────────────────────────────┐    │                                    
	│    EpsiodeCellController    │    │                                    
	└─────────────────────────────┘    │                                    
	                                   │                                    
	                                   │                                    
	                                   │                                    
	                                   │     ┌────────────────────┐         
	                                   └────▶│  RSSFeedViewModel  │         
	                                         └────────────────────┘

- EpsiodeListFeatureComposer

    1. Create `ListRefreshViewController` with `RSSLoader`

    2. Create `EpsiodeListViewController` with `ListRefreshViewController`

    3. Forwording refreshed rss data to `EpsiodeListViewController` 

- EpsiodeListViewController 

    1. Receving `tableModel` as table view's data source

    1. As a table view controller to present epsiode list and header image.

    2. Create `EpsiodeCellController` to present cell detail.

    3. hold `ListRefreshViewController` and connect to refresh control to show indicator when reloading.

    4. Navigate to `PodcastDescriptionViewController` with created `RSSFeedViewModel`.


## PodcastDescriptionViewController

	                                              ┌─────────────┐       
	                                              │PlayerObject │       
	                                              └─────────────┘       
	                                                     ▲              
	                                ┌────────────────────┘              
	┌───────────────────────────────┴───┐                               
	│ PodcastDescriptionViewController  │                               
	└───────────────────────────────┬───┘                               
	                                └────────────────────────┐          
	                                                         ▼          
	                                              ┌────────────────────┐
	                                              │  RSSFeedViewModel  │
	                                              └────────────────────┘

- PodcastDescriptionViewController

    1. Create UI when receiving `RSSFeedViewModel`.

    2. Create `PlayerObject` and navigate to `PodcastPlayerViewController`.

    3. Observe `PodcastPlayerViewController` on epsiode change event to change UI to current epsiode.


## PodcastPlayerViewController

	                                              ┌─────────────┐       
	                                              │PlayerObject │       
	                                              └─────────────┘       
	                                                     ▲              
	                                ┌────────────────────┘              
	┌───────────────────────────────┴───┐                               
	│    PodcastPlayerViewController    │                               
	└───────────────────────────────┬───┘                               
	                                └────────────────────────┐          
	                                                         ▼          
	                                              ┌────────────────────┐
	                                              │  RSSFeedViewModel  │
	                                              └────────────────────┘

- PodcastPlayerViewController

    1. Create UI when receiving `RSSFeedViewModel` and config `PlayerObject`.

    2. Trigger prepareToPlay: Trigger `PlayerObject` to prepare player(download audio).

    2. Observe `PlayerObject` 3 event and action.

        - timeOnChange: To change current time label.

        - onPlayerReady: Trigger `onEpsiodeChange` to notified `PodcastDescriptionViewController` to change UI for current epsiode.

        - onEpEnd: Check if have newer epsiode.

            * YES: config next epsiode to play. <br>
            * NO: stop epsiode and reset UI.

## PlayerObject

A object to handle `AVPlayer` to play audio.

`PlayerObject` register three observer to observe play state, and have three closure to notify controller what event happen.

- observeValue: To observe is player is ready to play, using `onPlayerReady` to notify, and start to observe boundary time. 

- addPeriodicTimeObserver: To observe time change and using `timeOnChange` to forwording current time string.

- addBoundaryTimeObserver: To observe is current epsiode is over, and using `onEpEnd` to notify controller.

### Interaction with `PlayerObject`

- prepareToPlay(with url): Prepare player, and using `observeValue` to observ status.

- handleSliderWith(with value): Receive slider value to control play time.

- handlePlayPauseAndReturnIsPlaying: Check is avplayer playing.

- resetPlayer: Reset avplayer to start condition.

- getDuration: Get current epsiode duration and return time string.




