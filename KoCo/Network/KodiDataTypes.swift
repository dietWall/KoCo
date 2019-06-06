//
//  KodiDataTypes.swift
//  KoCo
//
//  Created by admin on 04.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation


struct VersionObj : Codable {
    var version : Version
}

struct Version : Codable{
    var major : Int
    var minor : Int
    var patch : Int
}


struct ActivePlayer : Codable{
    var playerid : Int
    var type : String
}


enum Action : String,  Codable{
    case left
    case right
    case up
    case down
    case pageup
    case pagedown
    case select
    case highlight
    case parentdir
    case parentfolder
    case back
    case menu
    case previousmenu
    case info
    case pause
    case stop
    case skipnext
    case skipprevious
    case fullscreen
    case aspectratio
    case stepforward
    case stepback
    case bigstepforward
    case bigstepback
    case chapterorbigstepforward
    case chapterorbigstepback
    case osd
    case showsubtitles
    case nextsubtitle
    case cyclesubtitle
    case playerdebug
    case codecinfo
    case playerprocessinfo
    case nextpicture
    case previouspicture
    case zoomout
    case zoomin
    case playlist
    case queue
    case zoomnormal
    case zoomlevel1
    case zoomlevel2
    case zoomlevel3
    case zoomlevel4
    case zoomlevel5
    case zoomlevel6
    case zoomlevel7
    case zoomlevel8
    case zoomlevel9
    case nextcalibration
    case resetcalibration
    case analogmove
    case analogmovex
    case analogmovey
    case rotate
    case rotateccw
    case close
    case subtitledelayminus
    case subtitledelay
    case subtitledelayplus
    case audiodelayminus
    case audiodelay
    case audiodelayplus
    case subtitleshiftup
    case subtitleshiftdown
    case subtitlealign
    case audionextlanguage
    case verticalshiftup
    case verticalshiftdown
    case nextresolution
    case audiotoggledigital
    case number0
    case number1
    case number2
    case number3
    case number4
    case number5
    case number6
    case number7
    case number8
    case number9
    case smallstepback
    case fastforward
    case rewind
    case play
    case playpause
    case switchplayer
    case delete
    case copy
    case move
    case screenshot
    case rename
    case togglewatched
    case scanitem
    case reloadkeymaps
    case volumeup
    case volumedown
    case mute
    case backspace
    case scrollup
    case scrolldown
    case analogfastforward
    case analogrewind
    case moveitemup
    case moveitemdown
    case contextmenu
    case shift
    case symbols
    case cursorleft
    case cursorright
    case showtime
    case analogseekforward
    case analogseekback
    case showpreset
    case nextpreset
    case previouspreset
    case lockpreset
    case randompreset
    case increasevisrating
    case decreasevisrating
    case showvideomenu
    case enter
    case increaserating
    case decreaserating
    case setrating
    case togglefullscreen
    case nextscene
    case previousscene
    case nextletter
    case prevletter
    case jumpsms2
    case jumpsms3
    case jumpsms4
    case jumpsms5
    case jumpsms6
    case jumpsms7
    case jumpsms8
    case jumpsms9
    case filter
    case filterclear
    case filtersms2
    case filtersms3
    case filtersms4
    case filtersms5
    case filtersms6
    case filtersms7
    case filtersms8
    case filtersms9
    case firstpage
    case lastpage
    case guiprofile
    case red
    case green
    case yellow
    case blue
    case increasepar
    case decreasepar
    case volampup
    case volampdown
    case volumeamplification
    case createbookmark
    case createepisodebookmark
    case settingsreset
    case settingslevelchange
    case stereomode
    case nextstereomode
    case previousstereomode
    case togglestereomode
    case stereomodetomono
    case channelup
    case channeldown
    case previouschannelgroup
    case nextchannelgroup
    case playpvr
    case playpvrtv
    case playpvrradio
    case record
    case togglecommskip
    case showtimerrule
    case leftclick
    case rightclick
    case middleclick
    case doubleclick
    case longclick
    case wheelup
    case wheeldown
    case mousedrag
    case mousemove
    case tap
    case longpress
    case pangesture
    case zoomgesture
    case rotategesture
    case swipeleft
    case swiperight
    case swipeup
    case swipedown
    case error
    case noop
}

struct ActionParam : Codable{
    let action : Action
}
